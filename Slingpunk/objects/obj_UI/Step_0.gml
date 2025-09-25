// UI Step Event

var controller = instance_find(obj_Game, 0);
if (controller != noone) {
    var last_modifier = hud_data.last_modifier;
    var data = {
        score: controller.score,
        combo_heat: controller.combo_heat,
        combo_tier: floor(controller.combo_heat / 5),
        combo_progress: (controller.combo_heat mod 5) / 5,
        focus: controller.focus,
        lives: controller.lives,
        wave: controller.wave_number,
        last_modifier: last_modifier,
        special_charge: controller.nova_charge,
        special_max: controller.nova_charge_max,
        special_ready: controller.nova_charge >= controller.nova_charge_max,
        special_name: controller.nova_name
    };
    update_hud_data(data);
}

if (power_draft_active) {
    var option_count = array_length(draft_options);
    if (option_count > 0 && draft_selection < 0) {
        draft_selection = 0;
    }

    var selection_index = draft_selection;
    var confirm_selection = false;

    if (option_count > 0) {
        if (keyboard_check_pressed(vk_left) || keyboard_check_pressed(ord("A")) || keyboard_check_pressed(ord("J"))) {
            selection_index = ((selection_index - 1 + option_count) mod option_count);
        }

        if (keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord("D")) || keyboard_check_pressed(ord("L"))) {
            selection_index = ((selection_index + 1) mod option_count);
        }

        if (keyboard_check_pressed(vk_up) || keyboard_check_pressed(vk_down)) {
            selection_index = ((selection_index + option_count) mod option_count);
        }

        for (var key_idx = 0; key_idx < option_count && key_idx < 9; key_idx++) {
            var key_code = ord(string(key_idx + 1));
            if (keyboard_check_pressed(key_code)) {
                selection_index = key_idx;
                confirm_selection = true;
            }
        }
    }

    draft_selection = selection_index;

    var gui_mouse_x = device_mouse_x_to_gui(0);
    var gui_mouse_y = device_mouse_y_to_gui(0);

    if (option_count > 0) {
        var center_x = display_get_gui_width() / 2;
        var center_y = display_get_gui_height() / 2;
        var option_width = 260;
        var option_height = 160;
        var option_spacing = option_width + 40;
        var start_x = center_x - (option_count - 1) * option_spacing / 2;

        var hovered_index = -1;
        for (var i = 0; i < option_count; i++) {
            var option_x = start_x + i * option_spacing;
            var card_lift = (draft_selection == i) ? 12 : 0;
            var option_y = center_y - card_lift;
            var left = option_x - option_width / 2;
            var right = option_x + option_width / 2;
            var top = option_y - option_height / 2;
            var bottom = option_y + option_height / 2;

            if (gui_mouse_x >= left && gui_mouse_x <= right && gui_mouse_y >= top && gui_mouse_y <= bottom) {
                hovered_index = i;
            }
        }

        if (hovered_index != -1) {
            draft_selection = hovered_index;
            selection_index = hovered_index;
            if (mouse_check_button_pressed(mb_left)) {
                confirm_selection = true;
            }
        }
    }

    if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_numpad_enter)) {
        confirm_selection = true;
    }

    if (confirm_selection && option_count > 0 && draft_selection >= 0) {
        var chosen_index = draft_selection;
        with (obj_Game) {
            confirm_modifier_choice(other.chosen_index);
        }
    }
}

