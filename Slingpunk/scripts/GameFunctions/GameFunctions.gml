// Utility functions
function spawn_particles(_x, _y, _color, _count, _speed, _radius) {
    if (_count <= 0) return;

    var controller = instance_find(obj_Game, 0);
    if (controller == noone) return;

    var dt = 1 / 60;

    with (controller) {
        for (var i = 0; i < _count; i++) {
            var angle = random(360);
            var distance = random_range_value(0, max(0, _radius * 0.2));
            var part_speed = random_range_value(_speed * 0.4, _speed);
            var life = random_range_value(0.35, 0.85);

            var particle = {
                x: _x + lengthdir_x(distance, angle),
                y: _y + lengthdir_y(distance, angle),
                vx: lengthdir_x(part_speed, angle) * dt,
                vy: lengthdir_y(part_speed, angle) * dt,
                life: life,
                max_life: life,
                size: random_range_value(4, 10),
                color: _color,
                friction: random_range_value(0.85, 0.93)
            };

            array_push(particles, particle);
        }
    }
}

function spawn_impact_wave(_x, _y, _max_radius, _duration, _color) {
    var controller = instance_find(obj_Game, 0);
    if (controller == noone) return;

    with (controller) {
        var wave = {
            x: _x,
            y: _y,
            life: _duration,
            max_life: _duration,
            max_radius: _max_radius,
            color: _color
        };
        array_push(impact_waves, wave);
    }
}

function compute_orb_damage(_orb, _enemy, _modifiers, _combo_heat, _difficulty) {
    if (!instance_exists(_orb) || !instance_exists(_enemy)) return 0;

    var damage = _orb.orb_damage;

    if (!is_undefined(_modifiers)) {
        damage *= _modifiers.damageMultiplier;

        // Combo heat damage bonus
        if (_modifiers.comboHeatDamagePercent > 0) {
            var combo_multiplier = 1 + max(0, _combo_heat) * _modifiers.comboHeatDamagePercent;
            damage *= combo_multiplier;
        }

        // Bounce damage bonus
        if (_modifiers.bounceDamagePercent > 0 && _orb.orb_bounce_count > 0) {
            damage *= 1 + _orb.orb_bounce_count * _modifiers.bounceDamagePercent;
        }

        // Boss damage multiplier
        if ((_enemy.enemy_is_boss || _enemy.enemy_is_elite) && _modifiers.bossDamageMultiplier > 1) {
            damage *= _modifiers.bossDamageMultiplier;
        }

        // Wall hit damage bonus
        if (_orb.orb_pending_wall_damage_bonus > 0) {
            damage *= 1 + _orb.orb_pending_wall_damage_bonus;
            _orb.orb_pending_wall_damage_bonus = 0;
        }

        // Tier damage bonus (flat addition per tier)
        var tier = floor(_combo_heat / 5);
        damage += tier * _modifiers.comboDamagePerTier;
    }

    if (!is_undefined(_difficulty)) {
        damage *= _difficulty.playerDamageMultiplier;
    }

    return damage;
}

// Enemy behavior function (to be overridden)
function enemy_behavior() {
    // Basic downward movement
    velocity_y = base_speed;
}


// Helper functions for drawing different enemy types
function draw_enemy_organic(_x, _y, _radius, _hp_ratio) {
    var spikes = spikes_count * 2;
    var wobble = 0.16 + (1 - _hp_ratio) * 0.08;

    draw_set_color(secondary_color);
    draw_circle(_x, _y, _radius, false);

    draw_set_color(accent_color);
    draw_circle(_x, _y, _radius * 0.8, false);

    draw_set_color(core_color);
    var pulse_radius = _radius * (0.32 + sin(elapsed_time * 3.4) * 0.08);
    draw_circle(_x, _y, pulse_radius, false);
}

function draw_enemy_mechanical(_x, _y, _radius, _hp_ratio) {
    // Draw hexagonal body
    draw_set_color(secondary_color);
    draw_circle(_x, _y, _radius, false);

    draw_set_color(accent_color);
    draw_circle(_x, _y, _radius * 0.55, false);

    draw_set_color(core_color);
    draw_circle(_x, _y, _radius * 0.3, false);

    // Draw crosshair
    draw_set_color(c_white);
    draw_set_alpha(0.4);
    var arm = _radius * 0.78;
    draw_line(_x - arm, _y, _x + arm, _y);
    draw_line(_x, _y - arm, _x, _y + arm);
    draw_set_alpha(1);
}

function draw_enemy_crystal(_x, _y, _radius, _hp_ratio) {
    // Star shape
    draw_set_color(secondary_color);
    draw_circle(_x, _y, _radius, false);

    draw_set_color(accent_color);
    draw_circle(_x, _y, _radius * 0.7, false);

    draw_set_color(core_color);
    draw_circle(_x, _y, _radius * 0.46, false);
}

function draw_circle_arc(_x, _y, _radius, _start_angle, _end_angle, _thickness) {
    // Helper function to draw arc - GameMaker doesn't have built-in arc
    var steps = max(8, abs(_end_angle - _start_angle) / 5);
    var angle_step = (_end_angle - _start_angle) / steps;

    for (var i = 0; i < steps; i++) {
        var angle1 = _start_angle + i * angle_step;
        var angle2 = _start_angle + (i + 1) * angle_step;

        var x1 = _x + lengthdir_x(_radius, angle1);
        var y1 = _y + lengthdir_y(_radius, angle1);
        var x2 = _x + lengthdir_x(_radius, angle2);
        var y2 = _y + lengthdir_y(_radius, angle2);

        draw_line_width(x1, y1, x2, y2, _thickness);
    }
}

function draw_background() {
    // Gradient background
    draw_set_color(c_black);
    draw_rectangle(0, 0, room_width, room_height, false);

    // Stars
    for (var i = 0; i < array_length(background_stars); i++) {
        var star = background_stars[i];
        var twinkle = (sin(current_time * 0.001 * star.twinkle_speed + star.twinkle_phase) + 1) * 0.5;

        var star_x = star.x_percent * room_width - screen_shake_x * (1 - star.parallax);
        var star_y = star.y_percent * (room_height - BOTTOM_SAFE_ZONE * 0.4) - screen_shake_y * (1 - star.parallax);
        var radius = star.radius * (0.6 + twinkle * 0.7);

        draw_set_alpha(0.25 + twinkle * 0.65);
        draw_set_color(star.color);
        draw_circle(star_x, star_y, radius, false);
    }

    // Grid lines
    draw_set_alpha(0.08);
    draw_set_color(c_blue);
    var grid_bottom = room_height - BOTTOM_SAFE_ZONE;
    for (var grid_y = grid_bottom; grid_y >= 0; grid_y -= 100) {
        draw_line(0, grid_y, room_width, grid_y);
    }

    draw_set_alpha(1);
}

function draw_aim_line() {
    if (!pointer_dragging) return;

    var drag_x = cannon_x - pointer_x;
    var drag_y = cannon_y - pointer_y;
    var length_pixels = clamp_value(point_distance(0, 0, drag_x, drag_y), 0, 280);
    var dir = point_direction(0, 0, drag_x, drag_y);

    draw_set_alpha(0.6);
    draw_set_color(c_aqua);
    var end_x = cannon_x + lengthdir_x(length_pixels * 0.6, dir);
    var end_y = cannon_y + lengthdir_y(length_pixels * 0.6, dir);

    // Dashed line effect
    var segments = 8;
    var segment_length = point_distance(cannon_x, cannon_y, end_x, end_y) / segments;

    for (var i = 0; i < segments; i += 2) {
        var start_dist = i * segment_length;
        var end_dist = min((i + 1) * segment_length, point_distance(cannon_x, cannon_y, end_x, end_y));

        var seg_start_x = cannon_x + lengthdir_x(start_dist, dir);
        var seg_start_y = cannon_y + lengthdir_y(start_dist, dir);
        var seg_end_x = cannon_x + lengthdir_x(end_dist, dir);
        var seg_end_y = cannon_y + lengthdir_y(end_dist, dir);

        draw_line_width(seg_start_x, seg_start_y, seg_end_x, seg_end_y, 4);
    }

    draw_set_alpha(1);
}

function draw_cannon() {
    var width = 100;
    var height = 80;

    draw_set_color(c_dkgray);
    draw_rectangle(cannon_x - width/2, cannon_y, cannon_x + width/2, cannon_y + height, false);

    // Cannon glow
    draw_set_alpha(0.3);
    draw_set_color(c_aqua);
    draw_circle(cannon_x, cannon_y, 38, false);

    draw_set_alpha(0.5);
    draw_set_color(c_lime);
    draw_circle(cannon_x, cannon_y + 8, 24, false);

    draw_set_alpha(1);
}

function draw_particles() {
    // Simplified particle rendering
    for (var i = 0; i < array_length(particles); i++) {
        var particle = particles[i];
        var ratio = max(0, particle.life / particle.max_life);

        draw_set_alpha(ratio);
        draw_set_color(particle.color);
        draw_circle(particle.x, particle.y, particle.size * ratio, false);
    }
    draw_set_alpha(1);
}

function draw_floating_text() {
    // Simplified floating text rendering
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);

    for (var i = 0; i < array_length(floating_texts); i++) {
        var text = floating_texts[i];
        var ratio = max(0, text.life / text.max_life);

        draw_set_alpha(ratio);
        draw_set_color(text.color);
        draw_text(text.x, text.y, text.value);
    }

    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_alpha(1);
}

function draw_impact_waves() {
    // Simplified impact wave rendering
    for (var i = 0; i < array_length(impact_waves); i++) {
        var wave = impact_waves[i];
        var progress = 1 - wave.life / wave.max_life;
        var alpha = max(0, wave.life / wave.max_life);
        var radius = wave.max_radius * progress;

        draw_set_alpha(alpha * 0.85);
        draw_set_color(wave.color);
        draw_circle(wave.x, wave.y, radius, true);
    }
    draw_set_alpha(1);
}

function draw_ui() {
    // Simple UI overlay
    var ui_y = 30;
    draw_set_color(c_white);
    draw_text(30, ui_y, "Score: " + string(score));
    draw_text(30, ui_y + 30, "Lives: " + string(lives));
    draw_text(30, ui_y + 60, "Wave: " + string(wave_number));
    draw_text(30, ui_y + 90, "Focus: " + string(round(focus)));
    draw_text(30, ui_y + 120, "Combo: " + string(round(combo_heat)));

    // Nova charge bar
    var nova_progress = nova_charge / nova_charge_max;
    var bar_width = 200;
    var bar_height = 20;
    var bar_x = room_width - bar_width - 30;
    var bar_y = 30;

    draw_set_color(c_dkgray);
    draw_rectangle(bar_x, bar_y, bar_x + bar_width, bar_y + bar_height, false);

    if (nova_progress >= 1) {
        draw_set_color(c_lime);
    } else {
        draw_set_color(c_aqua);
    }
    draw_rectangle(bar_x, bar_y, bar_x + bar_width * nova_progress, bar_y + bar_height, false);

    draw_set_color(c_white);
    draw_rectangle(bar_x, bar_y, bar_x + bar_width, bar_y + bar_height, true);
    draw_text(bar_x, bar_y - 25, nova_name);

    if (wave_preview_text != "" && (wave_intro_delay > 0 || wave_break_timer > 0)) {
        draw_set_halign(fa_center);
        draw_text(room_width / 2, bar_y + 70, "Next Wave: " + wave_preview_text);
        draw_set_halign(fa_left);
    }
}

function handle_input() {
    // Mouse/touch input for aiming and launching
    if (mouse_check_button_pressed(mb_left) && launch_cooldown <= 0) {
        pointer_dragging = true;
        pointer_x = mouse_x;
        pointer_y = mouse_y;
    }

    if (pointer_dragging) {
        pointer_x = mouse_x;
        pointer_y = mouse_y;
    }

    if (mouse_check_button_released(mb_left) && pointer_dragging) {
        pointer_dragging = false;
        launch_orb();
    }

    // Pause toggle
    if (keyboard_check_pressed(vk_space) || keyboard_check_pressed(ord("P"))) {
        toggle_pause();
    }

    // Special ability
    if (keyboard_check_pressed(ord("Q")) || mouse_check_button_pressed(mb_right)) {
        try_activate_nova_pulse();
    }
}

function launch_orb() {
    var drag_x = cannon_x - pointer_x;
    var drag_y = cannon_y - pointer_y;
    var Power = point_distance(0, 0, drag_x, drag_y);

    if (Power < 20 || launch_cooldown > 0 || lives <= 0) {
        return;
    }

    // Create particles at launch
    spawn_particles(cannon_x, cannon_y, c_aqua, 10, 200, 70);

    var Direction = point_direction(0, 0, drag_x, drag_y);
    var Speed = (550 + clamp_value(Power, 0, 280) * 3.2) * 3;

    var launch_count = modifiers.tripleLaunch ? 3 : 1;
    var spread = 13; // degrees

    for (var i = 0; i < launch_count; i++) {
        var angle_offset = 0;
        if (launch_count == 3) {
            angle_offset = (i - 1) * spread; // -spread, 0, spread
        }

        var orb = instance_create_layer(cannon_x, cannon_y, "Instances", obj_Orb);
        orb.velocity_x = lengthdir_x(Speed, Direction + angle_offset);
        orb.velocity_y = lengthdir_y(Speed, Direction + angle_offset);
        orb.orb_radius = 16 * modifiers.orbSizeMultiplier;
        orb.orb_split_on_impact = modifiers.splitOnImpact;
    }

    launch_cooldown = .35 * 60; // Convert to frames
    focus = clamp_value(focus - 5, 0, 100);
}

function toggle_pause() {
    game_paused = !game_paused;
}

function try_activate_nova_pulse() {
    if (!game_running || game_paused || lives <= 0) return;
    if (nova_charge < nova_charge_max - 0.01) return;

    activate_nova_pulse();
}

function activate_nova_pulse() {
    // Create nova burst effect
    spawn_impact_wave(cannon_x, cannon_y, 280, 0.75, c_aqua);
    spawn_particles(cannon_x, cannon_y, c_aqua, 26, 260, 220);

    nova_charge = 0;

    // Affect all enemies
    with (obj_Enemy) {
        if (enemy_alive) {
            // Push enemies back and slow them
            var capped_y = min(y, room_height - BOTTOM_SAFE_ZONE - 80);
            y = max(40, capped_y - 200);
            velocity_y = min(velocity_y, -420);
            // Apply knockback and slow (would need enemy methods)
        }
    }

    add_screen_shake(9, 0.55);
}

function init_wave_manager() {
    wave_blueprints = build_wave_blueprints();
    wave_spawn_events = [];
    wave_spawn_index = 0;
    wave_elapsed = 0;
    wave_break_timer = 0.75;
    current_wave_state = undefined;
    wave_preview_text = "";
    wave_intro_delay = 0;
}

function build_wave_blueprints() {
    var waves = [];

    var opening = WaveBlueprint("Opening Salvo", 1.0, [
        WaveEnemyConfig(EnemyKind.GLOOB_ZIGZAG, 3, [2, 3, 4, 5], 6, 0.45, 1, 0),
        WaveEnemyConfig(EnemyKind.SPLITTER_GLOOB, 4, [3, 4], 2, 1.4, 0.9, 0.05, 0.6)
    ]);
    array_push(waves, opening);

    var splitters = WaveBlueprint("Splitter Sweep", 1.2, [
        WaveEnemyConfig(EnemyKind.SPLITTER_GLOOB, 5, [2, 5], 3, 1.1, 0.85, 0.08, 0.2),
        WaveEnemyConfig(EnemyKind.GLOOB_ZIGZAG, 4, [1, 3, 4, 6], 4, 0.6, 1.05, 0)
    ]);
    array_push(waves, splitters);

    var spores = WaveBlueprint("Spore Drift", 1.4, [
        WaveEnemyConfig(EnemyKind.SPORE_PUFF, 5, [2, 3, 5], 3, 1.6, 0.7, 0.12, 0.4),
        WaveEnemyConfig(EnemyKind.SPLITTERLING, 2, -1, 6, 0.35, 1.1, 0)
    ]);
    array_push(waves, spores);

    var shields = WaveBlueprint("Shield Wall", 1.5, [
        WaveEnemyConfig(EnemyKind.SHIELDY_GLOOB, 7, [3, 4], 3, 1.3, 0.8, 0.15, 0.3),
        WaveEnemyConfig(EnemyKind.BULWARK_GLOOB, 9, [2, 5], 2, 2.0, 0.65, 0.2, 0.8)
    ]);
    array_push(waves, shields);

    var flux = WaveBlueprint("Flux Field", 1.3, [
        WaveEnemyConfig(EnemyKind.MAGNETRON, 6, [2, 3, 4, 5], 4, 0.8, 0.9, 0.12, 0.2),
        WaveEnemyConfig(EnemyKind.WARP_STALKER, 6, -1, 3, 1.1, 1.1, 0.18, 0.6)
    ]);
    array_push(waves, flux);

    var guardians = WaveBlueprint("Guardian Phalanx", 1.6, [
        WaveEnemyConfig(EnemyKind.AEGIS_SENTINEL, 8, [3, 4], 2, 1.6, 0.75, 0.22, 0.4),
        WaveEnemyConfig(EnemyKind.BULWARK_GLOOB, 10, [2, 5], 3, 1.8, 0.7, 0.28, 0.9),
        WaveEnemyConfig(EnemyKind.SPORE_PUFF, 6, [1, 6], 2, 1.8, 0.7, 0.14, 0.6)
    ]);
    array_push(waves, guardians);

    return waves;
}

function build_dynamic_wave(_wave_number) {
    var pool = [
        EnemyKind.GLOOB_ZIGZAG,
        EnemyKind.SPLITTER_GLOOB,
        EnemyKind.SHIELDY_GLOOB,
        EnemyKind.MAGNETRON,
        EnemyKind.SPORE_PUFF,
        EnemyKind.BULWARK_GLOOB,
        EnemyKind.WARP_STALKER,
        EnemyKind.AEGIS_SENTINEL
    ];
    array_shuffle_ext(pool);

    var group_count = clamp(2 + floor((_wave_number - 1) / 2), 2, 6);
    var configs = [];

    for (var i = 0; i < group_count; i++) {
        var type_index = i % array_length(pool);
        var enemy_type = pool[type_index];
        var lane_pattern = choose(-1, [2, 3, 4, 5], [2, 5], [3, 4], "edges", "center");
        var base_hp = 4 + round(_wave_number * 0.9);
        var cadence = max(0.35, 1.2 - _wave_number * 0.05);
        var count = clamp(3 + floor(_wave_number * 0.45), 3, 12);
        var speed_scale = 1;
        var elite_chance = 0.08 + min(0.3, _wave_number * 0.01);

        switch (enemy_type) {
            case EnemyKind.BULWARK_GLOOB:
                base_hp += 6;
                cadence += 0.5;
                count = max(2, floor(count * 0.6));
                speed_scale = 0.7;
                elite_chance += 0.1;
                break;

            case EnemyKind.SPORE_PUFF:
                base_hp -= 2;
                cadence += 0.4;
                count += 1;
                speed_scale = 0.75;
                break;

            case EnemyKind.MAGNETRON:
                speed_scale = 0.85;
                break;

            case EnemyKind.WARP_STALKER:
                speed_scale = 1.15;
                cadence += 0.2;
                break;

            case EnemyKind.AEGIS_SENTINEL:
                base_hp += 4;
                cadence += 0.6;
                count = max(2, floor(count * 0.5));
                elite_chance += 0.12;
                break;
        }

        var config = WaveEnemyConfig(enemy_type, base_hp, lane_pattern, count, cadence, speed_scale, elite_chance, i * 0.4);
        array_push(configs, config);
    }

    var name = "Endless Pattern " + string(_wave_number);
    var intro = clamp(1.0 + (group_count - 2) * 0.1, 0.8, 1.8);
    return WaveBlueprint(name, intro, configs);
}

function prepare_wave_events(_blueprint) {
    var events = [];
    var scaling = enemy_scaling;

    for (var i = 0; i < array_length(_blueprint.enemies); i++) {
        var config = _blueprint.enemies[i];
        var spawn_time = max(0, config.spawnOffset);
        var cadence = max(0.18, config.cadence);
        if (scaling.cadenceMultiplier > 0) {
            cadence = max(0.12, cadence / scaling.cadenceMultiplier);
        }

        var count = max(1, round(config.count * scaling.countMultiplier));

        for (var j = 0; j < count; j++) {
            var event_lane = resolve_wave_lane(config.lane, j);
            var event = {
                time: spawn_time,
                type: config.type,
                lane: event_lane,
                hp: max(1, round((config.hp + scaling.hpBonus) * scaling.hpMultiplier)),
                speedMultiplier: max(0.4, config.speedScale) * scaling.speedMultiplier,
                elite: (config.eliteChance > 0) && (random(1) < config.eliteChance),
                jitter: random_range_value(-18, 18)
            };
            array_push(events, event);
            spawn_time += cadence;
        }
    }

    var event_count = array_length(events);
    for (var a = 0; a < event_count - 1; a++) {
        for (var b = a + 1; b < event_count; b++) {
            if (events[a].time > events[b].time) {
                var tmp = events[a];
                events[a] = events[b];
                events[b] = tmp;
            }
        }
    }

    return events;
}

function resolve_wave_lane(_lane, _index) {
    if (is_array(_lane)) {
        var lane_array = _lane;
        if (array_length(lane_array) > 0) {
            var lane_count = array_length(lane_array);
            var lane_index = _index mod lane_count;
            return clamp_value(lane_array[lane_index], 1, 6);
        }
    }

    if (is_string(_lane)) {
        switch (_lane) {
            case "edges":
                return choose(1, 6);
            case "center":
                return choose(3, 4);
            case "inner":
                return choose(2, 5);
        }
    }

    if (!is_real(_lane) || _lane <= 0) {
        return irandom_range(1, 6);
    }

    return clamp_value(round(_lane), 1, 6);
}

function spawn_enemy_from_event(_event) {
    var spawn_pos = lane_to_world(_event.lane, room_width);
    spawn_pos.x += _event.jitter;

    var enemy = instance_create_layer(spawn_pos.x, spawn_pos.y, "Instances", obj_Enemy);
    enemy.enemy_type = _event.type;
    enemy.enemy_hp = _event.hp;
    enemy.enemy_max_hp = _event.hp;
    enemy.enemy_speed = BASE_ENEMY_SPEED * _event.speedMultiplier;
    enemy.base_speed = enemy.enemy_speed;
    enemy.enemy_is_elite = _event.elite;
    enemy.type_configured = false;

    enemy_apply_type_profile(enemy);

    if (_event.elite) {
        enemy.enemy_hp = ceil(enemy.enemy_hp * 1.35);
        enemy.enemy_max_hp = enemy.enemy_hp;
        if (enemy.enemy_shield > 0) {
            enemy.enemy_shield = ceil(enemy.enemy_shield * 1.2) + 1;
        }
        enemy.base_speed *= 1.05;
    }
}

function announce_wave(_wave_number, _blueprint) {
    spawn_floating_text("Wave " + string(_wave_number), room_width / 2, 120, c_white);
    if (_blueprint.waveId != "") {
        var detail = _blueprint.waveId;
        spawn_floating_text(detail, room_width / 2, 150, c_aqua);
    }
}

function start_next_wave() {
    var target_wave = completed_waves + 1;
    var blueprint = undefined;

    if (target_wave <= array_length(wave_blueprints)) {
        blueprint = wave_blueprints[target_wave - 1];
    } else {
        blueprint = build_dynamic_wave(target_wave);
    }

    wave_spawn_events = prepare_wave_events(blueprint);
    wave_spawn_index = 0;
    wave_elapsed = 0;
    wave_preview_text = blueprint.waveId;
    current_wave_state = {
        blueprint: blueprint,
        wave_number: target_wave,
        cleared: false
    };

    wave_intro_delay = max(0.5, blueprint.spawnSeconds);
    wave_break_timer = 0;
    wave_number = target_wave;

    announce_wave(target_wave, blueprint);
}

function update_wave_manager() {
    var dt = 1 / 60;

    if (wave_break_timer > 0) {
        wave_break_timer = max(0, wave_break_timer - dt);
        if (wave_break_timer <= 0) {
            start_next_wave();
        }
        return;
    }

    if (is_undefined(current_wave_state)) {
        start_next_wave();
        return;
    }

    if (wave_intro_delay > 0) {
        return;
    }

    wave_elapsed += dt;

    while (wave_spawn_index < array_length(wave_spawn_events)) {
        var event = wave_spawn_events[wave_spawn_index];
        if (wave_elapsed + 0.0001 < event.time) {
            break;
        }

        spawn_enemy_from_event(event);
        wave_spawn_index += 1;
    }

    if (!current_wave_state.cleared) {
        if (wave_spawn_index >= array_length(wave_spawn_events) && instance_number(obj_Enemy) == 0) {
            complete_current_wave();
        }
    }
}

function complete_current_wave() {
    if (is_undefined(current_wave_state)) return;

    current_wave_state.cleared = true;
    completed_waves += 1;
    wave_number = completed_waves + 1;

    spawn_floating_text("Wave " + string(current_wave_state.wave_number) + " cleared!", room_width / 2, 120, c_lime);
    focus = clamp_value(focus + 12, 0, 100);
    nova_charge = clamp_value(nova_charge + 12, 0, nova_charge_max);
    add_screen_shake(4, 0.25);

    current_wave_state = undefined;
    wave_spawn_events = [];
    wave_spawn_index = 0;
    wave_elapsed = 0;
    wave_preview_text = "";
    wave_intro_delay = 0;
    wave_break_timer = max(0.9, 1.4 - enemy_scaling.level * 0.05);

    update_enemy_scaling();
}

function update_enemy_scaling() {
    enemy_scaling.level += 1;
    enemy_scaling.hpMultiplier = min(3.25, enemy_scaling.hpMultiplier + 0.08);
    enemy_scaling.hpBonus = min(18, enemy_scaling.hpBonus + 0.6);
    enemy_scaling.speedMultiplier = min(2, enemy_scaling.speedMultiplier + 0.03);
    enemy_scaling.countMultiplier = min(3.2, enemy_scaling.countMultiplier + 0.05);
    enemy_scaling.cadenceMultiplier = min(2.6, enemy_scaling.cadenceMultiplier + 0.04);
}

function update_particles() {
    // Simplified particle update
    for (var i = array_length(particles) - 1; i >= 0; i--) {
        var particle = particles[i];
        particle.life -= 1/60;
        particle.x += particle.vx;
        particle.y += particle.vy;
        particle.vx *= particle.friction;
        particle.vy *= particle.friction;
        if (particle.life <= 0) {
            array_delete(particles, i, 1);
        }
    }
}

function update_floating_text() {
    // Simplified floating text update
    for (var i = array_length(floating_texts) - 1; i >= 0; i--) {
        var text = floating_texts[i];
        text.life -= 1/60;
        text.y += text.velocity_y * (1/60);
        if (text.life <= 0) {
            array_delete(floating_texts, i, 1);
        }
    }
}

function update_impact_waves() {
    // Simplified impact wave update
    for (var i = array_length(impact_waves) - 1; i >= 0; i--) {
        var wave = impact_waves[i];
        wave.life -= 1/60;
        if (wave.life <= 0) {
            array_delete(impact_waves, i, 1);
        }
    }
}

function update_screen_shake() {
    if (screen_shake_timer > 0) {
        screen_shake_timer -= 1/60;
        var ratio = screen_shake_timer / 60; // Assuming 1 second duration
        var magnitude = screen_shake_intensity * ratio * ratio;
        screen_shake_x = (random(2) - 1) * magnitude;
        screen_shake_y = (random(2) - 1) * magnitude;

        if (screen_shake_timer <= 0) {
            screen_shake_x = 0;
            screen_shake_y = 0;
            screen_shake_intensity = 0;
        }
    }
}

function add_screen_shake(_intensity, _duration) {
    if (_intensity <= 0 || _duration <= 0) return;
    screen_shake_intensity = min(28, screen_shake_intensity + _intensity);
    screen_shake_timer = max(screen_shake_timer, _duration * 60); // Convert to frames
}

function handle_game_over() {
    game_over = true;
    game_running = false;
    // Show game over message, restart after delay
    alarm[0] = 2 * 60; // 2 seconds
}


function spawn_floating_text(_text, _x, _y, _color) {
    var floating_text = {
        x: _x,
        y: _y,
        velocity_y: -120,
        life: 0.8,
        max_life: 0.8,
        value: _text,
        color: _color
    };
    array_push(floating_texts, floating_text);
}

function start_game() {
    if (game_running) return;

    reset_game();
    game_running = true;
    game_paused = false;
    game_over = false;
    wave_manager_active = true;
}

function reset_game() {
    score = 0;
    combo_heat = 0;
    combo_timer = 0;
    focus = 70;
    lives = MAX_LIVES;
    wave_number = 1;
    completed_waves = 0;
    nova_charge = 0;

    // Clear all game objects
    with (obj_Orb) instance_destroy();
    with (obj_Enemy) instance_destroy();

    // Reset modifiers
    modifiers = ModifierState();

    // Clear effects
    particles = [];
    floating_texts = [];
    impact_waves = [];

    screen_shake_x = 0;
    screen_shake_y = 0;
    screen_shake_timer = 0;
    screen_shake_intensity = 0;

    init_wave_manager();
}

function init_background() {
    // Create starfield
    var star_count = 80;
    background_stars = [];

    for (var i = 0; i < star_count; i++) {
        var star = {
            x_percent: random(1),
            y_percent: random(1),
            radius: random_range_value(1.1, 2.6),
            twinkle_speed: random_range_value(0.35, 1.15),
            twinkle_phase: random(2 * pi),
            parallax: random_range_value(0.3, 1),
            color: choose(c_aqua, c_fuchsia, c_lime)
        };
        array_push(background_stars, star);
    }
}

function enemy_apply_type_profile(_enemy) {
    if (!instance_exists(_enemy)) return;

    with (_enemy) {
        if (type_configured) return;

        zigzag_phase = random(360);
        zigzag_speed = 0;
        zigzag_amplitude = 0;
        magnet_strength = 0;
        magnet_range = 0;
        shield_arc = 0;
        shield_facing = 270;
        split_children_count = 0;

        switch (enemy_type) {
            case EnemyKind.GLOOB_ZIGZAG:
                visual_kind = "organic";
                accent_color = c_fuchsia;
                enemy_radius = max(enemy_radius, 28);
                zigzag_amplitude = 90;
                zigzag_speed = 360;
                base_speed = max(base_speed, BASE_ENEMY_SPEED * 0.9);
                if (enemy_max_hp <= 1) {
                    enemy_max_hp = 4;
                    enemy_hp = enemy_max_hp;
                }
                break;

            case EnemyKind.SPLITTER_GLOOB:
                visual_kind = "organic";
                accent_color = make_color_rgb(255, 170, 80);
                enemy_radius = max(enemy_radius, 30);
                zigzag_amplitude = 70;
                zigzag_speed = 280;
                base_speed = max(base_speed, BASE_ENEMY_SPEED * 0.85);
                split_children_count = 2;
                if (enemy_max_hp <= 1) {
                    enemy_max_hp = 5;
                    enemy_hp = enemy_max_hp;
                }
                break;

            case EnemyKind.SPLITTERLING:
                visual_kind = "organic";
                accent_color = make_color_rgb(255, 180, 110);
                enemy_radius = max(18, enemy_radius * 0.65);
                zigzag_amplitude = 56;
                zigzag_speed = 340;
                base_speed = max(base_speed, BASE_ENEMY_SPEED * 1.1);
                enemy_max_hp = max(1, enemy_max_hp);
                enemy_hp = max(1, enemy_hp);
                break;

            case EnemyKind.SHIELDY_GLOOB:
                visual_kind = "mechanical";
                accent_color = c_aqua;
                secondary_color = c_dkgray;
                enemy_radius = max(enemy_radius, 34);
                shield_arc = 140;
                shield_facing = 270;
                enemy_shield = max(enemy_shield, 3);
                base_speed = max(base_speed, BASE_ENEMY_SPEED * 0.9);
                if (enemy_max_hp <= 1) {
                    enemy_max_hp = 6;
                    enemy_hp = enemy_max_hp;
                }
                break;

            case EnemyKind.MAGNETRON:
                visual_kind = "mechanical";
                accent_color = c_lime;
                secondary_color = c_dkgray;
                enemy_radius = max(enemy_radius, 32);
                zigzag_amplitude = 48;
                zigzag_speed = 220;
                magnet_range = 220;
                magnet_strength = 360;
                base_speed = max(base_speed, BASE_ENEMY_SPEED * 0.75);
                if (enemy_max_hp <= 1) {
                    enemy_max_hp = 6;
                    enemy_hp = enemy_max_hp;
                }
                break;

            case EnemyKind.SPORE_PUFF:
                visual_kind = "organic";
                accent_color = make_color_rgb(140, 210, 255);
                secondary_color = make_color_rgb(80, 140, 200);
                enemy_radius = max(enemy_radius, 30);
                zigzag_amplitude = 70;
                zigzag_speed = 200;
                base_speed = max(base_speed, BASE_ENEMY_SPEED * 0.65);
                spore_interval = random_range_value(2.6, 4.4);
                spore_timer = random_range_value(spore_interval * 0.4, spore_interval);
                if (enemy_max_hp <= 1) {
                    enemy_max_hp = 5;
                    enemy_hp = enemy_max_hp;
                }
                break;

            case EnemyKind.BULWARK_GLOOB:
                visual_kind = "mechanical";
                accent_color = make_color_rgb(200, 220, 255);
                secondary_color = c_dkgray;
                enemy_radius = max(enemy_radius, 38);
                enemy_shield = max(enemy_shield, 6);
                shield_arc = 220;
                shield_spin = random_range_value(28, 46);
                base_speed = max(base_speed, BASE_ENEMY_SPEED * 0.72);
                if (enemy_max_hp <= 1) {
                    enemy_max_hp = 10;
                    enemy_hp = enemy_max_hp;
                }
                break;

            case EnemyKind.WARP_STALKER:
                visual_kind = "crystal";
                accent_color = make_color_rgb(170, 120, 255);
                secondary_color = make_color_rgb(60, 40, 120);
                enemy_radius = max(enemy_radius, 28);
                base_speed = max(base_speed, BASE_ENEMY_SPEED * 1.05);
                warp_interval = random_range_value(2.2, 4.2);
                warp_timer = random_range_value(1.0, warp_interval);
                warp_flash_timer = 0;
                break;

            case EnemyKind.AEGIS_SENTINEL:
                visual_kind = "mechanical";
                accent_color = make_color_rgb(255, 215, 120);
                secondary_color = make_color_rgb(120, 90, 50);
                enemy_radius = max(enemy_radius, 36);
                enemy_shield = max(enemy_shield, 4);
                shield_arc = max(shield_arc, 160);
                base_speed = max(base_speed, BASE_ENEMY_SPEED * 0.82);
                support_interval = random_range_value(2.2, 3.4);
                support_timer = support_interval * 0.5;
                support_flash = 0;
                if (enemy_max_hp <= 1) {
                    enemy_max_hp = 9;
                    enemy_hp = enemy_max_hp;
                }
                break;

            default:
                base_speed = max(base_speed, enemy_speed);
        }

        base_speed = max(base_speed, 40);
        if (enemy_is_elite) {
            accent_color = merge_color(accent_color, c_white, 0.35);
            secondary_color = merge_color(secondary_color, c_white, 0.2);
            enemy_radius += 2;
        }
        type_configured = true;
    }
}

function enemy_spawn_splitlings(_enemy) {
    if (!instance_exists(_enemy)) return;

    with (_enemy) {
        if (split_children_count <= 0) return;

        var spread = max(20, enemy_radius);
        for (var i = 0; i < split_children_count; i++) {
            var offset = (i - (split_children_count - 1) * 0.5) * spread * 0.6;
            var child = instance_create_layer(x + offset, y, "Instances", obj_Enemy);
            child.enemy_type = EnemyKind.SPLITTERLING;
            child.enemy_hp = 1;
            child.enemy_max_hp = 1;
            child.enemy_speed = BASE_ENEMY_SPEED * 1.2;
            child.enemy_radius = max(16, enemy_radius * 0.6);
            child.type_configured = false;
            enemy_apply_type_profile(child);
        }
    }
}