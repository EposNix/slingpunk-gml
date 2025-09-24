// Game Controller Create Event

// Game state
game_running = false;
game_paused = false;
game_over = false;
launch_cooldown = 0;

// Scoring and progression
score = 0;
combo_heat = 0;
combo_timer = 0;
focus = 70;
lives = MAX_LIVES;
wave_number = 1;
completed_waves = 0;

// Special ability
nova_charge = 0;
nova_charge_max = NOVA_CHARGE_MAX;
nova_charge_per_kill = NOVA_CHARGE_PER_KILL;
nova_name = "Nova Pulse";

// Cannon position
cannon_x = room_width / 2;
cannon_y = room_height - BOTTOM_SAFE_ZONE / 2;

// Input handling
pointer_dragging = false;
pointer_x = 0;
pointer_y = 0;
aftertouch_active = false;
aftertouch_direction = 0;

// Particle systems
particles = [];
floating_texts = [];
impact_waves = [];
background_stars = [];

// Modifiers system
modifiers = ModifierState();

// Wave management
wave_manager_active = false;
wave_intro_delay = 0;
wave_blueprints = [];
wave_spawn_events = [];
wave_spawn_index = 0;
wave_elapsed = 0;
wave_break_timer = 0;
current_wave_state = undefined;
wave_preview_text = "";

// Screen effects
screen_shake_x = 0;
screen_shake_y = 0;
screen_shake_timer = 0;
screen_shake_intensity = 0;

// Performance profile
performance_profile = detect_performance_profile();
game_set_speed(60, gamespeed_fps);

// Enemy scaling
enemy_scaling = EnemyWaveScaling(0, 1, 0, 1, 1, 1);

// Difficulty settings (default)
difficulty = DifficultyDefinition("normal", "Normal", "Balanced challenge",
    "Standard damage and enemy health", 1.0, 1.0, true);

// Initialize background
init_background();

// Setup wave data
init_wave_manager();

// Start the game
start_game();