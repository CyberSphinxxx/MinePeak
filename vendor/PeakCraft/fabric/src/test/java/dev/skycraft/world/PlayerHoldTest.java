package dev.skycraft.world;

import java.util.UUID;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

class PlayerHoldTest {
    private final UUID local = UUID.randomUUID();
    private final UUID other = UUID.randomUUID();
    @AfterEach void release() { PlayerHold.clear(); }

    @Test void targetDoesNotApplyToAnotherPlayer() {
        PlayerHold.set(local, 12, -511, 4);
        assertNull(PlayerHold.get(other));
        assertEquals(-511, PlayerHold.get(local).y());
    }

    @Test void replacementDoesNotMutateAReaderSnapshot() {
        PlayerHold.set(local, 1, 2, 3);
        var before = PlayerHold.get(local);
        PlayerHold.set(local, 4, 5, 6);
        assertEquals(1, before.x());
        assertEquals(4, PlayerHold.get(local).x());
    }

    @Test void clearReleasesPlayerPhysics() {
        PlayerHold.set(local, 1, 2, 3);
        PlayerHold.clear();
        assertNull(PlayerHold.get(local));
    }

    @Test void invalidTargetDoesNotReplaceValidTarget() {
        PlayerHold.set(local, 1, 2, 3);
        assertThrows(IllegalArgumentException.class, () -> PlayerHold.set(local, Double.NaN, 0, 0));
        assertThrows(IllegalArgumentException.class, () -> PlayerHold.set(local, 0, Double.POSITIVE_INFINITY, 0));
        assertThrows(IllegalArgumentException.class, () -> PlayerHold.set(null, 0, 0, 0));
        assertEquals(1, PlayerHold.get(local).x());
    }
}
