package dev.skycraft.mixin;

import dev.skycraft.SkyCraft;
import dev.skycraft.combat.SkyCombat;
import dev.skycraft.combat.SkyrimActorEntity;
import dev.skycraft.link.Proto;
import dev.skycraft.link.SkyLink;
import net.minecraft.world.damagesource.DamageSource;
import net.minecraft.world.entity.Entity;
import net.minecraft.server.level.ServerPlayer;
import org.spongepowered.asm.mixin.Mixin;
import org.spongepowered.asm.mixin.injection.At;
import org.spongepowered.asm.mixin.injection.Inject;
import org.spongepowered.asm.mixin.injection.callback.CallbackInfo;
import org.spongepowered.asm.mixin.injection.callback.CallbackInfoReturnable;
import dev.skycraft.world.PlayerHold;
import net.minecraft.server.level.ServerLevel;
import net.minecraft.tags.DamageTypeTags;
import net.minecraft.world.phys.Vec3;

@Mixin(ServerPlayer.class)
public abstract class ServerPlayerMixin {
    // Resetting LocalPlayer alone does not stop integrated-server gravity or damage.
    @Inject(method = {"tick", "doTick"}, at = @At("HEAD"))
    private void minepeak$holdBeforeTick(CallbackInfo ci) { minepeak$applyHold(); }

    @Inject(method = {"tick", "doTick"}, at = @At("TAIL"))
    private void minepeak$holdAfterTick(CallbackInfo ci) { minepeak$applyHold(); }

    private void minepeak$applyHold() {
        ServerPlayer self = (ServerPlayer) (Object) this;
        PlayerHold.Target target = PlayerHold.get(self.getUUID());
        if (target != null && self.isAlive()) {
            self.setPos(target.x(), target.y(), target.z());
            self.setDeltaMovement(Vec3.ZERO);
            self.resetFallDistance();
        }
    }

    @Inject(method = "isInvulnerableTo", at = @At("HEAD"), cancellable = true)
    private void minepeak$protectParkedPlayer(ServerLevel level, DamageSource source, CallbackInfoReturnable<Boolean> cir) {
        ServerPlayer self = (ServerPlayer) (Object) this;
        if (PlayerHold.get(self.getUUID()) != null && !source.is(DamageTypeTags.BYPASSES_INVULNERABILITY)) {
            cir.setReturnValue(true);
        }
    }

	/** Critical hits on a Skyrim actor are flagged so Skyrim can play them up. */
	@Inject(method = "crit", at = @At("HEAD"))
	private void skycraft$critSkyrim(Entity entity, CallbackInfo ci) {
		if (entity instanceof SkyrimActorEntity proxy) {
			proxy.markCritical();
		}
	}

	/** Dying in Minecraft is dying in Skyrim: the host's through the link, a guest's through theirs. */
	@Inject(method = "die", at = @At("HEAD"))
	private void skycraft$diesInSkyrim(DamageSource source, CallbackInfo ci) {
		ServerPlayer self = (ServerPlayer) (Object) this;
		int attacker = SkyCombat.attackerFormId(source);
		if (!dev.skycraft.net.SkyNet.isHost(self)) {
			if (net.fabricmc.fabric.api.networking.v1.ServerPlayNetworking.canSend(self, dev.skycraft.net.SkyNet.Died.TYPE)) {
				net.fabricmc.fabric.api.networking.v1.ServerPlayNetworking.send(self, new dev.skycraft.net.SkyNet.Died(attacker));
			}
			SkyCraft.LOG.info("SkyCraft: guest {} died ({}); telling their Skyrim", self.getPlainTextName(), source.getMsgId());
			return;
		}
		if (SkyLink.active()) {
			SkyLink.pushEvent(Proto.EV_PLAYER_DIED, attacker, 0, 0, 0, 0, 0);
			SkyCraft.LOG.info("SkyCraft: player died ({}); telling Skyrim", source.getMsgId());
		}
	}
}
