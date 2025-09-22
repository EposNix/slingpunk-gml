// UI Draw GUI Event

// Update toast messages
for (var i = array_length(toast_messages) - 1; i >= 0; i--) {
    var toast = toast_messages[i];
    toast.life -= 1/60;
    if (toast.life <= 0) {
        array_delete(toast_messages, i, 1);
    }
}

// Draw HUD
draw_hud();

// Draw toast messages
draw_toast_messages();

// Draw overlays
if (pause_overlay_active) {
    draw_pause_overlay();
}

if (power_draft_active) {
    draw_power_draft();
}
