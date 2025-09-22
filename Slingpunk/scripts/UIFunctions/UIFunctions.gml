function draw_hud() {
    var margin = 20;
    var line_height = 25;
    var y_pos = margin;

    // Set font properties
    draw_set_font(-1); // Default font
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);

    // Score
    draw_set_color(c_white);
    draw_text(margin, y_pos, "Score: " + string(hud_data.score));
    y_pos += line_height;

    // Lives
    draw_set_color(c_red);
    draw_text(margin, y_pos, "Lives: " + string(hud_data.lives));
    y_pos += line_height;

    // Wave
    draw_set_color(c_aqua);
    draw_text(margin, y_pos, "Wave: " + string(hud_data.wave));
    y_pos += line_height;

    // Focus
    draw_set_color(c_yellow);
    draw_text(margin, y_pos, "Focus: " + string(round(hud_data.focus)));
    y_pos += line_height;

    // Combo
    draw_set_color(c_lime);
    var combo_text = "Combo: " + string(round(hud_data.combo_heat));
    if (hud_data.combo_tier > 0) {
        combo_text += " (Tier " + string(hud_data.combo_tier) + ")";
    }
    draw_text(margin, y_pos, combo_text);

    // Special ability bar (Nova Pulse)
    draw_special_bar();

    // Last modifier indicator
    if (!is_undefined(hud_data.last_modifier)) {
        draw_last_modifier();
    }
}

function draw_special_bar() {
    var bar_width = 200;
    var bar_height = 20;
    var bar_x = display_get_gui_width() - bar_width - 20;
    var bar_y = 20;

    var progress = hud_data.special_charge / hud_data.special_max;

    // Background
    draw_set_color(c_dkgray);
    draw_rectangle(bar_x, bar_y, bar_x + bar_width, bar_y + bar_height, false);

    // Fill
    if (hud_data.special_ready) {
        draw_set_color(c_lime);
    } else {
        draw_set_color(c_aqua);
    }
    draw_rectangle(bar_x, bar_y, bar_x + bar_width * progress, bar_y + bar_height, false);

    // Border
    draw_set_color(c_white);
    draw_rectangle(bar_x, bar_y, bar_x + bar_width, bar_y + bar_height, true);

    // Label
    draw_set_halign(fa_center);
    draw_text(bar_x + bar_width/2, bar_y - 25, hud_data.special_name);
    draw_set_halign(fa_left);

    // Ready indicator
    if (hud_data.special_ready) {
        draw_set_color(c_lime);
        draw_text(bar_x + bar_width + 10, bar_y + 2, "READY!");
    }
}

function draw_last_modifier() {
    // Simple indicator showing last picked modifier
    var text = "Last: " + get_modifier_name(hud_data.last_modifier);
    draw_set_color(c_lime);
    draw_set_halign(fa_right);
    draw_text(display_get_gui_width() - 20, display_get_gui_height() - 40, text);
    draw_set_halign(fa_left);
}

function draw_toast_messages() {
    var toast_x = display_get_gui_width() / 2;
    var toast_y = 100;
    var toast_spacing = 35;

    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);

    for (var i = 0; i < array_length(toast_messages); i++) {
        var toast = toast_messages[i];
        var alpha = min(1, toast.life / min(1, toast.max_life));

        draw_set_alpha(alpha);
        draw_set_color(c_white);

        // Background
        var text_width = string_width(toast.message);
        var text_height = string_height(toast.message);
        draw_set_color(c_black);
        draw_set_alpha(alpha * 0.7);
        draw_rectangle(toast_x - text_width/2 - 10, toast_y + i * toast_spacing - text_height/2 - 5,
                      toast_x + text_width/2 + 10, toast_y + i * toast_spacing + text_height/2 + 5, false);

        // Text
        draw_set_color(c_white);
        draw_set_alpha(alpha);
        draw_text(toast_x, toast_y + i * toast_spacing, toast.message);
    }

    draw_set_alpha(1);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}

function draw_pause_overlay() {
    // Semi-transparent overlay
    draw_set_alpha(0.7);
    draw_set_color(c_black);
    draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);

    // Pause text
    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_text(display_get_gui_width()/2, display_get_gui_height()/2, "PAUSED");
    draw_text(display_get_gui_width()/2, display_get_gui_height()/2 + 40, "Press SPACE to resume");

    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}

function draw_power_draft() {
    // Modal background
    draw_set_alpha(0.8);
    draw_set_color(c_black);
    draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);

    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);

    var center_x = display_get_gui_width() / 2;
    var center_y = display_get_gui_height() / 2;

    // Title
    draw_text(center_x, center_y - 150, draft_title);
    draw_text(center_x, center_y - 120, draft_subtitle);

    // Options
    var option_width = 200;
    var option_height = 80;
    var option_spacing = 220;
    var start_x = center_x - (array_length(draft_options) - 1) * option_spacing / 2;

    for (var i = 0; i < array_length(draft_options); i++) {
        var option = draft_options[i];
        var option_x = start_x + i * option_spacing;
        var option_y = center_y;

        // Selection highlight
        if (draft_selection == i) {
            draw_set_color(c_lime);
            draw_rectangle(option_x - option_width/2 - 5, option_y - option_height/2 - 5,
                          option_x + option_width/2 + 5, option_y + option_height/2 + 5, false);
        }

        // Option background
        draw_set_color(c_dkgray);
        draw_rectangle(option_x - option_width/2, option_y - option_height/2,
                      option_x + option_width/2, option_y + option_height/2, false);

        // Option border
        draw_set_color(c_white);
        draw_rectangle(option_x - option_width/2, option_y - option_height/2,
                      option_x + option_width/2, option_y + option_height/2, true);

        // Option text
        draw_set_color(c_white);
        draw_text(option_x, option_y - 15, option.name);
        draw_text(option_x, option_y + 15, option.description);
    }

    draw_text(center_x, center_y + 150, "Use arrow keys to select, ENTER to confirm");

    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}

function get_modifier_name(_modifier_id) {
    // Simple name lookup for modifiers
    switch (_modifier_id) {
        case RunModifierId.DAMAGE_BOOST: return "Damage Boost";
        case RunModifierId.BULWARK_CORE: return "Bulwark Core";
        case RunModifierId.CRYO_COATING: return "Cryo Coating";
        case RunModifierId.RESTORE_HEART: return "Heart Capsule";
        default: return "Unknown";
    }
}

function show_toast(_message, _duration = 2000) {
    var toast = {
        message: _message,
        life: _duration / 1000, // Convert to seconds
        max_life: _duration / 1000,
        y_offset: 0
    };
    array_push(toast_messages, toast);
}

function update_hud_data(_data) {
    hud_data = _data;
}

function show_power_draft(_options, _title, _subtitle) {
    power_draft_active = true;
    draft_options = _options;
    draft_title = _title;
    draft_subtitle = _subtitle;
    draft_selection = -1;
}

function hide_power_draft() {
    power_draft_active = false;
    draft_options = [];
    draft_selection = -1;
}

function show_pause_overlay() {
    pause_overlay_active = true;
}

function hide_pause_overlay() {
    pause_overlay_active = false;
}