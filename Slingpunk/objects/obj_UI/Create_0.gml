// UI Controller Create Event

// Toast message system
toast_messages = [];

// HUD data cache
hud_data = {
    score: 0,
    combo_heat: 0,
    combo_tier: 0,
    combo_progress: 0,
    focus: 70,
    lives: 3,
    wave: 1,
    last_modifier: undefined,
    special_charge: 0,
    special_max: 100,
    special_ready: false,
    special_name: "Nova Pulse"
};

// Modal/overlay states
power_draft_active = false;
pause_overlay_active = false;

// Modifier draft options
draft_options = [];
draft_title = "";
draft_subtitle = "";
draft_selection = -1;
