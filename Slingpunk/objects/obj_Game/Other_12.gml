// User Event 2 - Orb Out of Bounds
// Check if we have any active orbs left
var has_active_orbs = false;
with (obj_Orb) {
    if (orb_alive) {
        has_active_orbs = true;
        break;
    }
}

if (!has_active_orbs && lives > 0) {
    spawn_floating_text("Reloaded", cannon_x, cannon_y - 50, c_lime);
}
