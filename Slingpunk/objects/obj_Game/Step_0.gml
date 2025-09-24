// Game Controller Step Event

if (!game_running || game_paused) exit;

// Update timers
launch_cooldown = max(0, launch_cooldown - 1);
combo_timer += 1/60;
wave_intro_delay = max(0, wave_intro_delay - 1/60);

// Update modifier timers
if (!is_undefined(modifiers.chainLightning)) {
    modifiers.chainLightning.cooldown = max(0, modifiers.chainLightning.cooldown - 1/60);
}

// Handle input
handle_input();

// Update screen shake
update_screen_shake();

// Update combo heat decay
if (combo_timer > 2 && combo_heat > 0) {
    combo_heat = max(0, combo_heat - (1/60) * 2);
}

// Update aftertouch
if (aftertouch_active && focus > 0) {
    var force = aftertouch_direction * 680 * (1/60);
    with (obj_Orb) {
        if (orb_alive) {
            velocity_x += force;
        }
    }
    focus = clamp_value(focus - 20 * (1/60), 0, 100);
}

// Update particles
update_particles();

// Update floating text
update_floating_text();

// Update impact waves
update_impact_waves();

// Wave management
if (wave_manager_active) {
    update_wave_manager();
}

// Check for game over
if (lives <= 0 && !game_over) {
    handle_game_over();
}

