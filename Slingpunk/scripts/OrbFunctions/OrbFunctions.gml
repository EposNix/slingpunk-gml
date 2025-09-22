
function orb_wall_bounce() {
    orb_bounce_count += 1;
    // Apply wall damage bonus if available
    if (instance_exists(obj_Game)) {
        var wall_bonus = obj_Game.modifiers.wallHitDamageBonusPercent;
        if (wall_bonus > 0) {
            orb_pending_wall_damage_bonus = wall_bonus;
        }

        // Create particles at impact point
        spawn_particles(x, y, c_aqua, 5, 40, 120);
    }
}

function orb_hit_enemy(_enemy) {
    // Calculate damage
    var damage = orb_damage;
    if (instance_exists(obj_Game)) {
        with obj_Game damage = compute_orb_damage(other.id, _enemy);
    }

    // Deal damage to enemy
    _enemy.enemy_hp -= (damage);

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