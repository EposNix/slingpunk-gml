// User Event 1 - Enemy Breach
lives = max(0, lives - 1);
combo_heat = 0;

spawn_floating_text("Breach! -1 Heart", room_width / 2, room_height / 2, c_red);

if (lives <= 0) {
    handle_game_over();
}