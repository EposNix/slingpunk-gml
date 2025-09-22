// Orb Step Event
if (!orb_alive) exit;

// Homing behavior
var homing_strength = 0; // Get from game modifiers
if (instance_exists(obj_Game)) {
    homing_strength = obj_Game.modifiers.homingStrength;
}

if (homing_strength > 0) {
    var nearest_enemy = instance_nearest(x, y, obj_Enemy);
    if (instance_exists(nearest_enemy) && nearest_enemy.enemy_alive) {
        var dx = nearest_enemy.x - x;
        var dy = nearest_enemy.y - y;
        var dir = vector2_normalize(Vector2(dx, dy));
        velocity_x += dir.x * homing_strength * (1/60);
        velocity_y += dir.y * homing_strength * (1/60);
    }
}

// Apply gravity and drag
velocity_y += 1400 * (1/60);
velocity_x *= 1 - 0.02 * (1/60);

// Update position
x += velocity_x * (1/60);
y += velocity_y * (1/60);

// Wall collisions
var radius = orb_radius;

// Left wall
if (x < radius) {
    x = radius;
    velocity_x = abs(velocity_x) * 0.9;
    orb_wall_bounce();
}
// Right wall
else if (x > room_width - radius) {
    x = room_width - radius;
    velocity_x = -abs(velocity_x) * 0.9;
    orb_wall_bounce();
}

// Top wall
if (y < radius + 40) {
    y = radius + 40;
    velocity_y = abs(velocity_y) * 0.85;
    orb_wall_bounce();
}

// Bottom boundary (out of bounds)
if (y - radius > room_height + 120) {
    orb_alive = false;
    // Signal to game controller
    with (obj_Game) {
        event_user(2); // User Event 2 for orb out of bounds
    }
    instance_destroy();
}

// Check collisions with enemies
var enemy = instance_place(x, y, obj_Enemy);
if (enemy != noone && enemy.enemy_alive) {
    // Calculate collision distance
    var dist = point_distance(x, y, enemy.x, enemy.y);
    if (dist <= orb_radius + enemy.enemy_radius) {
        orb_hit_enemy(enemy);
    }
}