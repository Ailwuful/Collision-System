step();

if (hspeed > 0) image_xscale = 1;
if (hspeed < 0) image_xscale = -1;

if (keyboard_check_released(ord("Q"))) game_end();
if (keyboard_check_pressed(ord("R"))) game_restart();
//if (keyboard_check_pressed(ord("M"))) room_goto_next();
//if (keyboard_check_pressed(ord("N"))) room_goto_previous();