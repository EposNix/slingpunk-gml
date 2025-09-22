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

// Wall collisions
var radius = orb_radius;

// Left wall
if (x < radius) {
    x = radius;
    velocity_x = abs(velocity_x) * 0.95;
    orb_wall_bounce();
}
// Right wall
else if (x > room_width - radius) {
    x = room_width - radius;
    velocity_x = -abs(velocity_x) * 0.95;
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

/// Orb Step Event (replace your update block with this)

var dt = 1/room_speed;

// 1) Apply forces
velocity_y += 1400 * dt;
velocity_x *= 1 - 0.02 * dt;

// 2) Compute desired displacement this frame
var dx_total = velocity_x * dt;
var dy_total = velocity_y * dt;

// How far are we trying to move?
var travel = point_distance(0, 0, dx_total, dy_total);

// Choose a step size. Smaller = safer. 1 px is safest; using radius/2 is often enough.
var step_size = 1; //max(1, orb_radius * 0.5);

// Number of micro-steps to cover the distance
var steps = max(1, ceil(travel / step_size));

// Per-step displacement
var dx = dx_total / steps;
var dy = dy_total / steps;

// (Optional) allow multiple hits in one frame, but cap to avoid infinite loops
var bounces_left = 3;

repeat (bounces_left) {
    var collided = false;

    for (var i = 0; i < steps; i++) {
        // Propose next position
        var nx = x + dx;
        var ny = y + dy;

        // Check collisions at the next micro-position
        var enemy = collision_circle(nx, ny, orb_radius, obj_Enemy, false, true);

        if (enemy != noone && enemy.enemy_alive) {
            // Binary search to stop right at contact
            var lo = 0;     // no move
            var hi = 1;     // full micro-step
            var px = x;
            var py = y;

            // A few iterations is enough (6~8)
            repeat (7) {
                var mid = (lo + hi) * 0.5;
                var tx = x + dx * mid;
                var ty = y + dy * mid;

                if (collision_circle(tx, ty, orb_radius, obj_Enemy, false, true)) {
                    // still overlapping -> move less
                    hi = mid;
                } else {
                    // not overlapping -> we can move up to here
                    lo = mid;
                    px = tx;
                    py = ty;
                }
            }

            // Land just before the overlap
            x = px;
            y = py;

            // Tell your game logic about the hit (bounce/damage/etc)
            orb_hit_enemy(enemy);

            // After orb_hit_enemy() you probably adjusted velocity_x/velocity_y.
            // Recompute the *remaining* motion for this frame using the unused fraction.
            // We used i+1 micro-steps out of 'steps' in this pass:
            var fraction_left = max(0, 1 - (i + 1) / steps);

            // Prepare another pass for the remaining distance in this same frame
            dx_total = (velocity_x * dt) * fraction_left;
            dy_total = (velocity_y * dt) * fraction_left;

            travel = point_distance(0, 0, dx_total, dy_total);
            steps  = max(1, ceil(travel / step_size));
            dx     = (steps == 0) ? 0 : dx_total / steps;
            dy     = (steps == 0) ? 0 : dy_total / steps;

            collided = true;
            break; // break the for-loop; repeat() will run another pass if we still have travel
        } else {
            // No collision, commit movement
            x = nx;
            y = ny;
        }
    }

    if (!collided) {
        // We finished all steps with no collision—done for this frame
        break;
    }
}
