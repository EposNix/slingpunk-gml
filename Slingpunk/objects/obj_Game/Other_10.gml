// User Event 0 - Enemy Killed
var enemy = other;

if (instance_exists(enemy)) {
    var base_score = 100 + enemy.enemy_max_hp * 15;
    var tier = floor(combo_heat / 5);
    var multiplier = 1 + tier * 0.1;
    var delta = round(base_score * multiplier);

    score += delta;
    combo_heat += 1;
    combo_timer = 0;
    focus = clamp_value(focus + 10, 0, 100);

    // Charge nova pulse
    var was_ready = nova_charge >= nova_charge_max - 0.01;
    nova_charge = clamp_value(nova_charge + nova_charge_per_kill, 0, nova_charge_max);
    var is_ready = nova_charge >= nova_charge_max - 0.01;

    if (!was_ready && is_ready) {
        // Nova ready effect
        spawn_impact_wave(cannon_x, cannon_y, 220, 0.6, c_lime);
        spawn_particles(cannon_x, cannon_y, c_lime, 18, 180, 140);
    }

    // Create floating text for score
    spawn_floating_text("+" + string(delta), enemy.x, enemy.y, c_yellow);

    // Screen shake for big kills
    if (delta >= 400) {
        var magnitude = min(24, 6 + delta / 70);
        add_screen_shake(magnitude, 0.45);
    }
}