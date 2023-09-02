///@desc loads gamepad
if (async_load[? "event_type"] == "gamepad discovered") {
	var gamepad = async_load[? "pad_index"];
	array_push(global.__GAMEPADS,gamepad);
	if (array_length(global.__GAMEPADS) == 1) input_gamepad_assign(0,0);
}

if (async_load[? "event_type"] == "gamepad lost") {
	var gamepad = async_load[? "pad_index"];
	var l = array_length(global.__GAMEPADS);
	var n = 0;
	repeat (l) {
		if (global.__GAMEPADS[n] == gamepad) {
			array_delete(global.__GAMEPADS,n,1);
			break;
		}
		n++;
	}
}