// Enemy Step Event
if (!enemy_alive) exit;

var dt = 1/60;
elapsed_time += dt;

if (warp_flash_timer > 0) warp_flash_timer = max(0, warp_flash_timer - dt);
if (support_flash > 0) support_flash = max(0, support_flash - dt);

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

    case EnemyKind.SPORE_PUFF:
        zigzag_phase += zigzag_speed * dt;
        velocity_y = base_speed * (0.85 + sin(elapsed_time * 1.6) * 0.08);
        velocity_x = dsin(zigzag_phase) * zigzag_amplitude;
        apply_damping = false;

        if (spore_interval > 0) {
            spore_timer -= dt;
            if (spore_timer <= 0 && y < room_height - BOTTOM_SAFE_ZONE - 60) {
                spore_timer = random_range_value(spore_interval * 0.6, spore_interval * 1.15);
                if (instance_number(obj_Enemy) < 120) {
                    var offset = random_range_value(-18, 18);
                    var spore = instance_create_layer(x + offset, y + enemy_radius, "Instances", obj_Enemy);
                    spore.enemy_type = EnemyKind.SPLITTERLING;
                    spore.enemy_hp = 1;
                    spore.enemy_max_hp = 1;
                    spore.enemy_speed = BASE_ENEMY_SPEED * 1.15;
                    spore.enemy_radius = 18;
                    spore.base_speed = spore.enemy_speed;
                    spore.type_configured = false;
                    enemy_apply_type_profile(spore);
                }
                spawn_particles(x, y, accent_color, 6, 180, enemy_radius + 16);
            }
        }
        break;

    case EnemyKind.BULWARK_GLOOB:
        velocity_y = base_speed;
        shield_facing = (shield_facing + shield_spin * dt) mod 360;
        enemy_shield = min(8, enemy_shield + dt * 0.9);
        break;

    case EnemyKind.WARP_STALKER:
        velocity_y = base_speed;
        warp_timer -= dt;
        if (warp_timer <= 0 && y < room_height - BOTTOM_SAFE_ZONE - 40) {
            warp_timer = random_range_value(max(0.8, warp_interval * 0.55), max(1.4, warp_interval));
            warp_flash_timer = 0.3;
            var new_lane = irandom_range(1, 6);
            var target = lane_to_world(new_lane, room_width);
            spawn_particles(x, y, accent_color, 10, 240, enemy_radius + 22);
            x = target.x + random_range_value(-12, 12);
            spawn_particles(x, y, accent_color, 12, 260, enemy_radius + 28);
        }
        break;

    case EnemyKind.AEGIS_SENTINEL:
        velocity_y = base_speed;
        shield_facing = (shield_facing + 120 * dt) mod 360;
        support_timer -= dt;
        if (support_timer <= 0) {
            support_timer = random_range_value(max(1.0, support_interval * 0.6), max(1.6, support_interval * 1.1));
            var ally = instance_nearest(x, y, obj_Enemy);
            if (instance_exists(ally) && ally.id != id && ally.enemy_alive && ally.enemy_type != EnemyKind.SPLITTERLING) {
                ally.enemy_shield = max(ally.enemy_shield, ceil(3 + ally.enemy_max_hp * 0.1));
                ally.shield_arc = max(ally.shield_arc, 160);
                ally.enemy_hp = min(ally.enemy_max_hp, ally.enemy_hp + 2);
                spawn_particles(ally.x, ally.y, accent_color, 8, 220, ally.enemy_radius + 26);
                spawn_particles(x, y, accent_color, 6, 200, enemy_radius + 20);
                support_flash = 0.35;
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
