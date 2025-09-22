// Enemy Create Event
enemy_type = EnemyKind.GLOOB_ZIGZAG;
enemy_hp = 1;
enemy_max_hp = 1;
enemy_shield = 0;
enemy_radius = 32;
enemy_speed = BASE_ENEMY_SPEED;
enemy_alive = true;
enemy_is_elite = false;
enemy_is_boss = false;

// Movement
velocity_x = 0;
velocity_y = 0;
base_speed = enemy_speed;

// Status effects
slow_timer = 0;
slow_factor = 1;
knockback = 0;
elapsed_time = 0;

// Visual properties
visual_kind = "organic"; // organic, mechanical, crystal
accent_color = c_aqua;
secondary_color = c_dkgray;
core_color = c_white;
spikes_count = 6;
sides_count = 6;