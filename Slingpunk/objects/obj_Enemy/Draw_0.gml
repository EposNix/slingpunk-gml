// Enemy Draw Event
if (!enemy_alive) exit;

var hp_ratio = max(0, min(1, enemy_hp / enemy_max_hp));
var radius = enemy_radius;

// Elite/Boss aura
if (enemy_is_elite || enemy_is_boss) {
    draw_set_alpha(enemy_is_boss ? 0.4 : 0.28);
    draw_set_color(enemy_is_boss ? c_orange : c_yellow);
    draw_circle(x, y, radius * (enemy_is_boss ? 1.8 : 1.55), false);
    draw_set_alpha(1);
}

// Draw based on visual kind
switch (visual_kind) {
    case "organic":
        draw_enemy_organic(x, y, radius, hp_ratio);
        break;
    case "mechanical":
        draw_enemy_mechanical(x, y, radius, hp_ratio);
        break;
    case "crystal":
        draw_enemy_crystal(x, y, radius, hp_ratio);
        break;
}

// Health ring background
draw_set_color(c_dkgray);
draw_set_alpha(0.55);
draw_circle(x, y, radius + 10, true);

// Health ring foreground
draw_set_color(accent_color);
draw_set_alpha(1);
var start_angle = -90;
var end_angle = start_angle + 360 * hp_ratio;
draw_circle_arc(x, y, radius + 10, start_angle, end_angle, 5);

// Shield effect
if (enemy_shield > 0) {
    var shield_alpha = 0.4 + min(1, enemy_shield / 6) * 0.5;
    draw_set_alpha(shield_alpha);
    draw_set_color(c_aqua);
    draw_circle(x, y, radius + 16, true);

    if (shield_arc > 0) {
        draw_set_alpha(shield_alpha + 0.1);
        draw_circle_arc(x, y, radius + 20, shield_facing - shield_arc * 0.5, shield_facing + shield_arc * 0.5, 6);
    }
}

// Slow effect
if (slow_timer > 0) {
    var slow_ratio = min(1, slow_timer);
    draw_set_alpha(0.2 + slow_ratio * 0.45);
    draw_set_color(c_blue);
    draw_circle(x, y, radius + 20, true);
}

// Magnetron field hint
if (enemy_type == EnemyKind.MAGNETRON && magnet_range > 0) {
    draw_set_alpha(0.05);
    draw_set_color(c_lime);
    draw_circle(x, y, magnet_range, true);
}

draw_set_alpha(1);