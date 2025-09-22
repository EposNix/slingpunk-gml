
function orb_wall_bounce() {
    orb_bounce_count += 1;
    // Apply wall damage bonus if available
    var controller = instance_find(obj_Game, 0);
    if (controller != noone) {
        var wall_bonus = controller.modifiers.wallHitDamageBonusPercent;
        if (wall_bonus > 0) {
            orb_pending_wall_damage_bonus = wall_bonus;
        }

        with (controller) {
            spawn_particles(other.x, other.y, c_aqua, 5, 40, 120);
        }
    }
}

function orb_hit_enemy(_enemy) {
    if (!instance_exists(_enemy) || !_enemy.enemy_alive) return;

    var controller = instance_find(obj_Game, 0);
    var modifiers_struct = undefined;
    var difficulty_struct = undefined;
    var combo_value = 0;

    if (controller != noone) {
        modifiers_struct = controller.modifiers;
        difficulty_struct = controller.difficulty;
        combo_value = controller.combo_heat;
    }

    // Calculate damage
    var damage = compute_orb_damage(id, _enemy, modifiers_struct, combo_value, difficulty_struct);

    // Shield handling for Shieldy enemies
    if (_enemy.enemy_shield > 0) {
        var shield_arc = 0;
        var shield_dir = 270;
        if (variable_instance_exists(_enemy, "shield_arc")) shield_arc = _enemy.shield_arc;
        if (variable_instance_exists(_enemy, "shield_facing")) shield_dir = _enemy.shield_facing;

        if (shield_arc > 0) {
            var approach_angle = point_direction(_enemy.x, _enemy.y, x, y);
            var shield_diff = angle_difference(shield_dir, approach_angle);
            if (abs(shield_diff) <= shield_arc * 0.5) {
                _enemy.enemy_shield = max(0, _enemy.enemy_shield - max(1, damage));

                if (controller != noone) {
                    var shield_fx_x = _enemy.x;
                    var shield_fx_y = _enemy.y;
                    var shield_fx_radius = _enemy.enemy_radius + 24;
                    var shield_wave_radius = _enemy.enemy_radius + 30;
                    with (controller) {
                        spawn_particles(shield_fx_x, shield_fx_y, c_aqua, 12, 280, shield_fx_radius);
                        spawn_impact_wave(shield_fx_x, shield_fx_y, shield_wave_radius, 0.22, c_aqua);
                    }
                }

                orb_bounce_count += 1;
                var bounce_speed = max(220, vector2_length(Vector2(velocity_x, velocity_y)) * 0.6);
                var bounce_dir = point_direction(_enemy.x, _enemy.y, x, y) + 180;
                velocity_x = lengthdir_x(bounce_speed, bounce_dir);
                velocity_y = lengthdir_y(bounce_speed, bounce_dir);

                if (_enemy.enemy_shield <= 0 && controller != noone) {
                    var break_x = _enemy.x;
                    var break_y = _enemy.y;
                    with (controller) {
                        spawn_floating_text("Shield Break!", break_x, break_y, c_aqua);
                    }
                }

                return;
            }
        }
    }

    // Deal damage to enemy
    _enemy.enemy_hp -= damage;

    if (!is_undefined(modifiers_struct)) {
        // Apply slow effect
        if (!is_undefined(modifiers_struct.slowEffect)) {
            _enemy.slow_timer = max(_enemy.slow_timer, modifiers_struct.slowEffect.duration);
            _enemy.slow_factor = min(_enemy.slow_factor, modifiers_struct.slowEffect.factor);
        }

        // Apply knockback
        if (modifiers_struct.knockbackForce > 0) {
            _enemy.knockback = max(_enemy.knockback, modifiers_struct.knockbackForce);
        }

        // Explosion effect
        if (!is_undefined(modifiers_struct.explosion)) {
            if (controller != noone) {
                var explosion_x = _enemy.x;
                var explosion_y = _enemy.y;
                var explosion_radius = modifiers_struct.explosion.radius;
                with (controller) {
                    spawn_impact_wave(explosion_x, explosion_y, explosion_radius, 0.4, c_orange);
                    spawn_particles(explosion_x, explosion_y, c_orange, 18, 360, explosion_radius);
                }
            }

            var explosion_radius = modifiers_struct.explosion.radius;
            var explosion_damage = modifiers_struct.explosion.damage;
            var source_enemy = _enemy;

            with (obj_Enemy) {
                if (!enemy_alive) continue;
                if (id == source_enemy.id) continue;

                var dist = point_distance(x, y, source_enemy.x, source_enemy.y);
                if (dist <= explosion_radius) {
                    enemy_hp -= explosion_damage;
                }
            }
        }

        // Chain lightning effect
        if (!is_undefined(modifiers_struct.chainLightning) && instance_number(obj_Enemy) > 1) {
            var lightning = modifiers_struct.chainLightning;
            if (lightning.cooldown <= 0) {
                var lightning_range = lightning.range;
                var range_sq = lightning_range * lightning_range;
                var lightning_damage = lightning.damage;
                var origin_enemy = _enemy;

                with (obj_Enemy) {
                    if (!enemy_alive) continue;
                    if (id == origin_enemy.id) continue;

                    var dx = x - origin_enemy.x;
                    var dy = y - origin_enemy.y;
                    if (dx * dx + dy * dy <= range_sq) {
                        enemy_hp -= lightning_damage;
                        if (controller != noone) {
                            var fx_x = x;
                            var fx_y = y;
                            with (controller) {
                                spawn_particles(fx_x, fx_y, c_aqua, 10, 280, lightning_range * 0.35);
                            }
                        }
                    }
                }

                lightning.cooldown = lightning.interval;
            }
        }
    }

    if (controller != noone) {
        var impact_x = _enemy.x;
        var impact_y = _enemy.y;
        var impact_radius = _enemy.enemy_radius + 12;
        var impact_wave_radius = _enemy.enemy_radius + 20;
        with (controller) {
            spawn_particles(impact_x, impact_y, orb_color, 10, 320, impact_radius);
            spawn_impact_wave(impact_x, impact_y, impact_wave_radius, 0.3, orb_color);
        }
    }

    // Handle split on impact
    if (orb_split_on_impact) {
        orb_split();
        return;
    }

    // Bounce off enemy
    var dx = x - _enemy.x;
    var dy = y - _enemy.y;
    var dir = vector2_normalize(Vector2(dx, dy));
    var Speed = vector2_length(Vector2(velocity_x, velocity_y)) * 0.7 + 320;
    velocity_x = dir.x * Speed;
    velocity_y = dir.y * Speed;
}

function orb_split() {
    var Speed = vector2_length(Vector2(velocity_x, velocity_y));
    var angle = point_direction(0, 0, velocity_x, velocity_y);
    var spread = 16; // degrees

    // Create two split orbs
    var split_angles = [angle - spread, angle + spread];

    for (var i = 0; i < 2; i++) {
        var split_orb = instance_create_layer(x, y, "Instances", obj_Orb);
        split_orb.velocity_x = lengthdir_x(Speed, split_angles[i]);
        split_orb.velocity_y = lengthdir_y(Speed, split_angles[i]);
        split_orb.orb_radius = orb_radius;
        split_orb.orb_color = orb_color;
        split_orb.orb_damage = orb_damage;
        split_orb.orb_split_on_impact = false; // Split orbs don't split further
        split_orb.orb_bounce_count = orb_bounce_count;
        split_orb.orb_pending_wall_damage_bonus = orb_pending_wall_damage_bonus;
    }

    // Destroy original orb
    orb_alive = false;
    instance_destroy();
}

// Initialize with default values - these will be set by the launcher
function orb_init(_pos_x, _pos_y, _vel_x, _vel_y, _options = {}) {
    x = _pos_x;
    y = _pos_y;
    velocity_x = _vel_x;
    velocity_y = _vel_y;

    if (struct_exists(_options, "radius")) orb_radius = _options.radius;
    if (struct_exists(_options, "color")) orb_color = _options.color;
    if (struct_exists(_options, "damage")) orb_damage = _options.damage;
    if (struct_exists(_options, "splitOnImpact")) orb_split_on_impact = _options.splitOnImpact;
}