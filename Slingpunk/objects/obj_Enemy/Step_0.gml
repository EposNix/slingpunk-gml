// Enemy Step Event
if (!enemy_alive) exit;

elapsed_time += 1/60; // Assuming 60 FPS

// Update behavior (virtual function - override in child objects)
enemy_behavior();

// Handle knockback
if (knockback > 0) {
    velocity_y -= knockback;
    knockback = max(0, knockback - (1/60) * 240);
}

// Handle slow effect
if (slow_timer > 0) {
    velocity_x *= slow_factor;
    velocity_y *= slow_factor;
    slow_timer = max(0, slow_timer - 1/60);
    if (slow_timer == 0) {
        slow_factor = 1;
    }
}

// Apply movement
x += velocity_x * (1/60);
y += velocity_y * (1/60);

// Damp horizontal velocity
velocity_x *= 1 - min(0.12, (1/60) * 2);

// Check if enemy breached bottom
if (y - enemy_radius > room_height - BOTTOM_SAFE_ZONE) {
    enemy_alive = false;
    // Signal breach to game controller
    with (obj_Game) {
        event_user(1); // User Event 1 for enemy breach
    }
    instance_destroy();
}
