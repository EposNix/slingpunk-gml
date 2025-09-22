// Orb Draw Event
if (!orb_alive) exit;

var Speed = vector2_length(Vector2(velocity_x, velocity_y));
var momentum = clamp_value(Speed / 1600, 0, 1);
var heading = point_direction(0, 0, velocity_x, velocity_y);
var radius = orb_radius;

// Draw tail
var tail_length = radius * (2.2 + momentum * 5.2);
var tail_width = radius * (0.8 + momentum * 0.35);

draw_set_alpha(0.45 + momentum * 0.4);

// Simplified tail - just a stretched ellipse
var tail_x = x - lengthdir_x(tail_length * 0.7, heading);
var tail_y = y - lengthdir_y(tail_length * 0.7, heading);

// Draw tail gradient effect using multiple overlapping circles
for (var i = 0; i < 5; i++) {
    var tail_alpha = (0.8 - i * 0.15) * (0.45 + momentum * 0.4);
    var tail_pos_x = lerp_value(tail_x, x, i / 4.0);
    var tail_pos_y = lerp_value(tail_y, y, i / 4.0);
    var tail_radius = lerp_value(tail_width, radius, i / 4.0);

    draw_set_alpha(tail_alpha);
    draw_set_color(orb_color);
    draw_circle(tail_pos_x, tail_pos_y, tail_radius, false);
}

// Draw main orb body
draw_set_alpha(1);

// Outer glow
draw_set_color(orb_color);
draw_circle(x, y, radius * 1.2, false);

// Core
draw_set_color(c_white);
draw_circle(x, y, radius, false);

// Inner core
draw_set_color(orb_color);
draw_circle(x, y, radius * 0.7, false);

// Highlight
draw_set_alpha(0.3 + momentum * 0.45);
draw_set_color(c_white);
draw_circle(x + radius * 0.15, y - radius * 0.2, radius * 0.4, false);

draw_set_alpha(1);
draw_self();