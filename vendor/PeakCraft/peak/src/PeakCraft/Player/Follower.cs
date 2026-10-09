using System.Collections.Generic;
using PeakCraft.Link;
using PeakCraft.World;
using UnityEngine;
using Zorro.Core;

namespace PeakCraft.Player;

/// <summary>
/// Keeps PEAK's character where Minecraft's player is. The character is a hidden, kinematic
/// follower (not a driven ragdoll), so PEAK's triggers, fog and campfires keep seeing a character
/// at the right spot. See docs/PEAK-NOTES.md for the PEAK members used.
/// </summary>
internal sealed class Follower
{
    private readonly PeakLink link;
    private Character? held;
    private readonly List<Renderer> hidden = new();
    private readonly List<Vector3> bodyPositions = new();

    public Follower(PeakLink link)
    {
        this.link = link;
    }

    /// <summary>Minecraft's interpolated feet this frame, in Unity space.</summary>
    public Vector3 Feet { get; private set; }

    /// <summary>Minecraft's eye height above the feet this frame.</summary>
    public float EyeHeight { get; private set; } = 1.62f;

    /// <summary>Where PEAK's own character stands (its feet), in Unity space.</summary>
    public static Vector3 PeakFeet(Character character) => character.Center - Vector3.up * Coords.CenterAboveFeet;

    /// <summary>Call every frame with the current ownership.</summary>
    public void Update(Ownership ownership, in Proto.GuestState guest)
    {
        Character character = Character.localCharacter;
        bool follow = ownership.BodyFollows && character != null;
        if (held != null && (!follow || held != character))
        {
            Release();
        }
        if (!follow)
        {
            return;
        }
        if (held == null)
        {
            Take(character!);
        }
        Interpolate(guest);
        Place(character!, guest);
    }

    private void Take(Character character)
    {
        held = character;
        character.refs.climbing.StopAnyClimbing();
        character.refs.items.EquipSlot(Optionable<byte>.None);
        character.refs.ragdoll.HaltBodyVelocity();
        character.refs.ragdoll.ToggleKinematic(enableKinematic: true);
        bodyPositions.Clear();
        hidden.Clear();
        foreach (Renderer renderer in character.GetComponentsInChildren<Renderer>(includeInactive: true))
        {
            if (renderer.enabled)
            {
                renderer.enabled = false;
                hidden.Add(renderer);
            }
        }
        Plugin.Log.LogInfo($"follower: took PEAK's character ({hidden.Count} renderers hidden, ragdoll kinematic, {character.refs.ragdoll.rigidbodies.Count} rigidbodies)");
    }

    /// <summary>Hands the body back to PEAK's own physics, standing where it is.</summary>
    public void Release()
    {
        if (held == null)
        {
            return;
        }
        foreach (Renderer renderer in hidden)
        {
            if (renderer != null)
            {
                renderer.enabled = true;
            }
        }
        hidden.Clear();
        // A destroyed character (scene change) compares equal to null.
        if (held != null)
        {
            held.refs.ragdoll.ToggleKinematic(enableKinematic: false);
            held.refs.ragdoll.HaltBodyVelocity();
            held.data.sinceGrounded = 0f;
            held.input.itemSwitchBlocked = false;
        }
        held = null;
        Plugin.Log.LogInfo("follower: released PEAK's character");
    }

    // Same idea as Minecraft's renderer: blend the last two 20 Hz physics ticks on our own frame
    // clock, so the two games' frame phases don't beat against each other.
    private void Interpolate(in Proto.GuestState guest)
    {
        Vector3 reported = Coords.ToUnity(guest.x, guest.y, guest.z);
        float eye = guest.eyeHeight > 0.1f ? guest.eyeHeight : 1.62f;
        if (guest.tickQpc != 0 && guest.tickMs > 1f)
        {
            double ageMs = (PeakLink.Qpc() - guest.tickQpc) * 1000.0 / link.QpcFrequency;
            if (ageMs >= 0 && ageMs < 250)
            {
                float t = Mathf.Clamp01((float)(ageMs / guest.tickMs));
                Vector3 previous = Coords.ToUnity(guest.prevX, guest.prevY, guest.prevZ);
                Vector3 current = Coords.ToUnity(guest.curX, guest.curY, guest.curZ);
                Vector3 blended = Vector3.Lerp(previous, current, t);
                // After a teleport the tick pair is stale for a moment; trust the reported position then.
                if ((blended - reported).sqrMagnitude < 4f)
                {
                    reported = blended;
                    eye = Mathf.Lerp(guest.tickEyeO, guest.tickEye, t);
                }
            }
        }
        Feet = reported;
        EyeHeight = eye;
    }

    private void Place(Character character, in Proto.GuestState guest)
    {
        // Read the physics pose: Unity may not update the visible transform until simulation.
        Bodypart torso = character.GetBodypart(BodypartType.Torso);
        Vector3 physicalFeet = (torso.rig != null ? torso.rig.position : character.Center)
            - Vector3.up * Coords.CenterAboveFeet;
        Vector3 delta = Feet - physicalFeet;
        MoveBody(character, delta);
        // PEAK's own ground checks are off (CharacterMovement.FixedUpdate is skipped): tell it what
        // Minecraft knows, so nothing downstream thinks the character is in a long fall.
        CharacterData data = character.data;
        data.isGrounded = true;
        data.sinceGrounded = 0f;
        data.fallSeconds = 0f;
        data.isSprinting = false;
        data.isCrouching = false;
        character.input.itemSwitchBlocked = true;
    }

    private void MoveBody(Character character, Vector3 delta)
    {
        if (delta.sqrMagnitude > 1e-10f && delta.sqrMagnitude < 1e12f)
        {
            // Snapshot all world positions before writing any of them. The bones are parented,
            // but each has its own physics body: moving only a root leaves child physics poses
            // stale; moving children from their already-shifted transforms applies delta twice.
            var bodies = character.refs.ragdoll.rigidbodies;
            bodyPositions.Clear();
            foreach (Rigidbody body in bodies)
            {
                bodyPositions.Add(body != null ? body.position : Vector3.zero);
            }
            for (int i = 0; i < bodies.Count; i++)
            {
                if (bodies[i] != null)
                {
                    bodies[i].position = bodyPositions[i] + delta;
                }
            }
        }
    }
}
