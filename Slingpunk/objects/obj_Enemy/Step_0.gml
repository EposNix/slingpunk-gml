// Enemy Step Event
if (!enemy_alive) exit;

var dt = 1/60;
elapsed_time += dt;

if (!type_configured) {
    enemy_apply_type_profile(id);
}

var apply_damping = true;

switch (enemy_type) {
    case EnemyKind.GLOOB_ZIGZAG:
        zigzag_phase += zigzag_speed * dt;
        velocity_y = base_speed;
        velocity_x = dsin(zigzag_phase) * zigzag_amplitude;
        apply_damping = false;
        break;

    case EnemyKind.SPLITTER_GLOOB:
        zigzag_phase += zigzag_speed * dt;
        velocity_y = base_speed;
        velocity_x = dsin(zigzag_phase) * zigzag_amplitude;
        apply_damping = false;
        break;

    case EnemyKind.SPLITTERLING:
        zigzag_phase += zigzag_speed * dt;
        velocity_y = base_speed;
        velocity_x = dsin(zigzag_phase) * zigzag_amplitude;
        apply_damping = false;
        break;

    case EnemyKind.SHIELDY_GLOOB:
        velocity_y = base_speed;
        var focus_orb = instance_nearest(x, y, obj_Orb);
        if (instance_exists(focus_orb) && focus_orb.orb_alive) {
            var desired_angle = point_direction(x, y, focus_orb.x, focus_orb.y);
            shield_facing = lerp_value(shield_facing, desired_angle, 0.18);
        } else {
            shield_facing = lerp_value(shield_facing, 270, 0.12);
        }
        break;

    case EnemyKind.MAGNETRON:
        zigzag_phase += zigzag_speed * dt;
        velocity_y = base_speed;
        velocity_x = dsin(zigzag_phase) * zigzag_amplitude;
        apply_damping = false;

        if (magnet_range > 0 && magnet_strength > 0) {
            var range_sq = magnet_range * magnet_range;
            with (obj_Orb) {
                if (!orb_alive) continue;
                var dx = other.x - x;
                var dy = other.y - y;
                var dist_sq = dx * dx + dy * dy;
                if (dist_sq <= range_sq) {
                    var dist = max(16, sqrt(dist_sq));
                    var pull = other.magnet_strength / max(80, dist_sq);
                    var pull_step = min(pull, other.magnet_strength * 0.02);
                    velocity_x += dx / dist * pull_step;
                    velocity_y += dy / dist * pull_step;
                }
            }
        }
        break;

    default:
        enemy_behavior();
}

// Handle knockback
if (knockback > 0) {
    velocity_y -= knockback;
    knockback = max(0, knockback - dt * 240);
}

// Handle slow effect
if (slow_timer > 0) {
    velocity_x *= slow_factor;
    velocity_y *= slow_factor;
    slow_timer = max(0, slow_timer - dt);
    if (slow_timer == 0) {
        slow_factor = 1;
    }
}

// Apply movement
x += velocity_x * dt;
y += velocity_y * dt;

// Damp horizontal velocity for non-oscillating enemies
if (apply_damping) {
    velocity_x *= 1 - min(0.12, dt * 2);
}

// Check if enemy breached bottom
if (y - enemy_radius > room_height - BOTTOM_SAFE_ZONE) {
    enemy_alive = false;
    // Signal breach to game controller
    with (obj_Game) {
        event_user(1); // User Event 1 for enemy breach
    }
    instance_destroy();
    exit;
}

// Handle death
if (enemy_hp <= 0) {
    enemy_alive = false;
    spawn_particles(x, y, accent_color, 16, 260, enemy_radius + 12);
    spawn_impact_wave(x, y, enemy_radius + 28, 0.35, accent_color);

    if (enemy_type == EnemyKind.SPLITTER_GLOOB && !split_spawned) {
        split_spawned = true;
        enemy_spawn_splitlings(id);
    }

    with (obj_Game) {
        event_user(0); // Enemy killed
    }

    instance_destroy();
}
