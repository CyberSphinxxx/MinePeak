package dev.skycraft.world;

import java.util.UUID;

/** Immutable cross-thread parking target for this client's integrated-server player only. */
public final class PlayerHold {
    public record Target(UUID player, double x, double y, double z) {}
    private static volatile Target target;

    private PlayerHold() {}

    public static void set(UUID player, double x, double y, double z) {
        if (player == null || !Double.isFinite(x) || !Double.isFinite(y) || !Double.isFinite(z)) {
            throw new IllegalArgumentException("A parking target requires a player and finite coordinates");
        }
        target = new Target(player, x, y, z);
    }

    public static Target get(UUID player) {
        Target snapshot = target;
        return snapshot != null && snapshot.player().equals(player) ? snapshot : null;
    }

    public static void clear() { target = null; }
}
