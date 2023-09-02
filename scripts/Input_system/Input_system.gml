/*
// Example of how to create an input
var _input = {
	left : [vk_left,ord("A"),gp_padl],
	right : [vk_right,ord("D"),gp_padr],
	attack : ord("O"),
	block : [ord("I"),gp_face1,mb_middle]
}
input_create(0,_input);
*/

global.__GAMEPADS = [];
room_instance_add(room_first,0,0,oInput);

enum INPUT_AXIS {
	AXIS_L_UP = 50000,
	AXIS_L_LEFT = 50001,
	AXIS_L_RIGHT = 50002,
	AXIS_L_DOWN = 50003,
	AXIS_R_UP = 50004,
	AXIS_R_LEFT = 50005,
	AXIS_R_RIGHT = 50006,
	AXIS_R_DOWN = 50007,
}

//========================================
///@function input_create(input number, keys struct, [deadzone])
function input_create(_inputNum,_keys, _deadzone = 0.4) {
	
	if (!variable_global_exists("__INPUT")) global.__INPUT = array_create(1);
	
	var _gamepad = 0;
	if (array_length(global.__GAMEPADS) > 0) _gamepad = global.__GAMEPADS[0];
	
	var _verbs = variable_struct_get_names(_keys);
	var _struct = {
		verbs : _verbs, 
		keys : [],
		buffer : [],
		stutter : [],
		axisl_last : [false,false,false,false],
		axisr_last : [false,false,false,false],
		gamepad : _gamepad,
		deadzone : _deadzone,
		m_x : 0,
		m_y : 0,
		mg_x : 0,
		mg_y : 0,
		gp_any : 0
	};
	
	var _verbs_num = array_length(_verbs);
		
	for (var i = 0; i < _verbs_num; i++) {
		
		//Check if an axis was bound to a verb along other input
		if (is_array(_keys[$ _verbs[i]])) {
			for (var n = 0; n < array_length(_keys[$ _verbs[i]]); n++) {
				var _const = _keys[$ _verbs[i]][n];
				if (_const >= gp_axislh and _const <= gp_axisrv) {
					show_message("Can't bind axis input along other input to the same variable.\nUse input_gamepad_axis_add() or one of the INPUT. constants for that.");
					array_delete(_keys[$ _verbs[i]],n,1);
					n--;
				}
				//if (_const >= INPUT_AXIS.AXIS_L_UP and _const <= INPUT_AXIS.AXIS_R_DOWN) {
				//	variable_struct_set(_struct,_verbs[i]+"_axis_last",false);
				//}
			}
		}
		
		array_push(_struct.keys, _keys[$ _verbs[i]]);
		variable_struct_set(_struct,_verbs[i],false);
		variable_struct_set(_struct,_verbs[i]+"_pressed",false);
		variable_struct_set(_struct,_verbs[i]+"_released",false);
	}
	
	global.__INPUT[_inputNum] = _struct;
}

///@function input_get(input number)
function input_get(_inputNum) {
	var _struct = global.__INPUT[_inputNum];
	var _verbs = _struct.verbs;
	var l = array_length(_verbs);
	var _keys = _struct.keys;
	_struct.gp_any = 0;
	
	for (var i = 0; i < l; i++) {
		if (is_array(_keys[i])) {
			var n = 0;
			
			repeat(array_length(_keys[i])) {
				var _key = _keys[i][n];
				if (_key <= 5) {
					_struct[$ _verbs[i]] = mouse_check_button(_key);
					_struct[$ _verbs[i]+"_pressed"] =  mouse_check_button_pressed(_key);
					_struct[$ _verbs[i]+"_released"] = mouse_check_button_released(_key);
				}
				else if (_key >= 32769) {
					if (_key >= INPUT_AXIS.AXIS_L_UP) {
						if (_key == INPUT_AXIS.AXIS_L_UP) {
							_key = (gamepad_axis_value(_struct.gamepad,gp_axislv) <= -_struct.deadzone ? 1 : 0);
							_struct.gp_any = _struct.gp_any | _key;
							_struct[$ _verbs[i]] = _key;
							_struct[$ _verbs[i]+"_pressed"] = _struct.axisl_last[0] == false and _struct[$ _verbs[i]] == true;
							_struct[$ _verbs[i]+"_released"] = _struct.axisl_last[0] == true and _struct[$ _verbs[i]] == false;
							_struct.axisl_last[0] = _struct[$ _verbs[i]];
						}else if (_key == INPUT_AXIS.AXIS_L_DOWN) {
							_key = (gamepad_axis_value(_struct.gamepad,gp_axislv) >= _struct.deadzone ? 1 : 0);
							_struct.gp_any = _struct.gp_any | _key;
							_struct[$ _verbs[i]] = _key;
							_struct[$ _verbs[i]+"_pressed"] = _struct.axisl_last[3] == false and _struct[$ _verbs[i]] == true;
							_struct[$ _verbs[i]+"_released"] = _struct.axisl_last[3] == true and _struct[$ _verbs[i]] == false;
							_struct.axisl_last[3] = _struct[$ _verbs[i]];
						}else if (_key == INPUT_AXIS.AXIS_L_LEFT) {
							_key = (gamepad_axis_value(_struct.gamepad,gp_axislh) <= -_struct.deadzone ? 1 : 0);
							_struct.gp_any = _struct.gp_any | _key;
							_struct[$ _verbs[i]] = _key;
							_struct[$ _verbs[i]+"_pressed"] = _struct.axisl_last[1] == false and _struct[$ _verbs[i]] == true;
							_struct[$ _verbs[i]+"_released"] = _struct.axisl_last[1] == true and _struct[$ _verbs[i]] == false;
							_struct.axisl_last[1] = _struct[$ _verbs[i]];
						}else if (_key == INPUT_AXIS.AXIS_L_RIGHT) {
							_key = (gamepad_axis_value(_struct.gamepad,gp_axislh) >= _struct.deadzone ? 1 : 0);
							_struct.gp_any = _struct.gp_any | _key;
							_struct[$ _verbs[i]] = _key;
							_struct[$ _verbs[i]+"_pressed"] = _struct.axisl_last[2] == false and _struct[$ _verbs[i]] == true;
							_struct[$ _verbs[i]+"_released"] = _struct.axisl_last[2] == true and _struct[$ _verbs[i]] == false;
							_struct.axisl_last[2] = _struct[$ _verbs[i]];
						}else if (_key == INPUT_AXIS.AXIS_R_UP) {
							_key = (gamepad_axis_value(_struct.gamepad,gp_axisrv) <= -_struct.deadzone ? 1 : 0);
							_struct.gp_any = _struct.gp_any | _key;
							_struct[$ _verbs[i]] = _key;
							_struct[$ _verbs[i]+"_pressed"] = _struct.axisr_last[0] == false and _struct[$ _verbs[i]] == true;
							_struct[$ _verbs[i]+"_released"] = _struct.axisr_last[0] == true and _struct[$ _verbs[i]] == false;
							_struct.axisr_last[0] = _struct[$ _verbs[i]];
						}else if (_key == INPUT_AXIS.AXIS_R_DOWN) {
							_key = (gamepad_axis_value(_struct.gamepad,gp_axisrv) >= _struct.deadzone ? 1 : 0);
							_struct.gp_any = _struct.gp_any | _key;
							_struct[$ _verbs[i]] = _key;
							_struct[$ _verbs[i]+"_pressed"] = _struct.axisr_last[3] == false and _struct[$ _verbs[i]] == true;
							_struct[$ _verbs[i]+"_released"] = _struct.axisr_last[3] == true and _struct[$ _verbs[i]] == false;
							_struct.axisr_last[3] = _struct[$ _verbs[i]];
						}else if (_key == INPUT_AXIS.AXIS_R_LEFT) {
							_key = (gamepad_axis_value(_struct.gamepad,gp_axisrh) <= -_struct.deadzone ? 1 : 0);
							_struct.gp_any = _struct.gp_any | _key;
							_struct[$ _verbs[i]] = _key;
							_struct[$ _verbs[i]+"_pressed"] = _struct.axisr_last[1] == false and _struct[$ _verbs[i]] == true;
							_struct[$ _verbs[i]+"_released"] = _struct.axisr_last[1] == true and _struct[$ _verbs[i]] == false;
							_struct.axisr_last[1] = _struct[$ _verbs[i]];
						}else if (_key == INPUT_AXIS.AXIS_R_RIGHT) {
							_key = (gamepad_axis_value(_struct.gamepad,gp_axisrh) >= _struct.deadzone ? 1 : 0);
							_struct.gp_any = _struct.gp_any | _key;
							_struct[$ _verbs[i]] = _key;
							_struct[$ _verbs[i]+"_pressed"] = _struct.axisr_last[2] == false and _struct[$ _verbs[i]] == true;
							_struct[$ _verbs[i]+"_released"] = _struct.axisr_last[2] == true and _struct[$ _verbs[i]] == false;
							_struct.axisr_last[2] = _struct[$ _verbs[i]];
						}
					}else {
						var _k = gamepad_button_check(_struct.gamepad,_key);
						_struct.gp_any = _struct.gp_any | _k;
						_struct[$ _verbs[i]] = _k;
						_struct[$ _verbs[i]+"_pressed"] = gamepad_button_check_pressed(_struct.gamepad,_key);
						_struct[$ _verbs[i]+"_released"] = gamepad_button_check_released(_struct.gamepad,_key);
					}
				}
				else {
					_struct[$ _verbs[i]] = keyboard_check(_key);
					_struct[$ _verbs[i]+"_pressed"] = keyboard_check_pressed(_key);
					_struct[$ _verbs[i]+"_released"] = keyboard_check_released(_key);
				}
				if (_struct[$ _verbs[i]] == true) break;
				if (_struct[$ _verbs[i]+"_released"] == true) break;
				n++;
			}
		}else {
			if (_keys[i] <= 5) {
				_struct[$ _verbs[i]] = mouse_check_button(_keys[i]);
				_struct[$ _verbs[i]+"_pressed"] = mouse_check_button_pressed(_keys[i]);
				_struct[$ _verbs[i]+"_released"] = mouse_check_button_released(_keys[i]);
			}
			else if (_keys[i] >= 32769) {
				if (_keys[i] >= gp_axislh and _keys[i] <= gp_axisrv) {
					_struct[$ _verbs[i]] = gamepad_axis_value(_struct.gamepad,_keys[i]);
					if (abs(_struct[$ _verbs[i]]) >= _struct.deadzone) _struct.gp_any = 1;
				}
				else {
					_struct[$ _verbs[i]] = gamepad_button_check(_struct.gamepad,_keys[i]);
					if (_struct[$ _verbs[i]]) _struct.gp_any = 1;
					_struct[$ _verbs[i]+"_pressed"] = gamepad_button_check_pressed(_struct.gamepad,_keys[i]);
					_struct[$ _verbs[i]+"_released"] = gamepad_button_check_released(_struct.gamepad,_keys[i]);
				}
			}
			else {
				_struct[$ _verbs[i]] = keyboard_check(_keys[i]);
				_struct[$ _verbs[i]+"_pressed"] = keyboard_check_pressed(_keys[i]);
				_struct[$ _verbs[i]+"_released"] = keyboard_check_released(_keys[i]);
			}
		}
	}
	_struct.m_x = mouse_x;
	_struct.m_y = mouse_y;
	_struct.mg_x = device_mouse_x_to_gui(0);
	_struct.mg_y = device_mouse_y_to_gui(0);
	
	// Checking buffer inputs
	var i = 0;
	repeat (array_length(_struct.buffer)) {
		var _verb = _struct.buffer[i][0];
		var _buffer = _struct.buffer[i][1];
		
		if (_struct[$ _verb+"_pressed"] == true) {
			_struct[$ _verb+"_count"] = _buffer;
		}
		if (_struct[$ _verb+"_count"] > 0) {
			_struct[$ _verb+"_count"] -= 1;
			_struct[$ _verb+"_buffer"] = true;
		}
		else _struct[$ _verb+"_buffer"] = false;
		i++;
	}
	
	//Checking Stutter
	i = 0;
	repeat (array_length(_struct.stutter)) {
		var _verb = _struct.stutter[i][0],
			_delay = _struct.stutter[i][1],
			_stutter = _struct.stutter[i][2];
		
		if (_struct[$ _verb+"_pressed"] == true) {
			_struct[$ _verb+"_count"] = 0;
		}
		else if (_struct[$ _verb] == true) {
			var _count = ++_struct[$ _verb+"_count"];
			if (_count < _delay) _struct[$ _verb] = false;
			else if ((_count - _delay) % _stutter != 0) _struct[$ _verb] = false;
		}
		i++;
	}
	
	return _struct;
}

///@function input_gamepad_assign(input number, gamepad number)
function input_gamepad_assign(_inputNum,_gamepad_index) {
	if (!variable_global_exists("__INPUT")) return;
	if (_inputNum+1 <= array_length(global.__INPUT)) {
		if (_gamepad_index+1 > array_length(global.__GAMEPADS)) {
			show_message("Gamepad number not found");
		}else {
			global.__INPUT[_inputNum].gamepad = global.__GAMEPADS[_gamepad_index];
		}
	}else {
		show_message("Input number not found");
	}
}

///@function input_key_change(input number, verb, keys)
function input_key_change(_inputNum, _verb, _keys) {
	if (_inputNum+1 <= array_length(global.__INPUT)) {
		var l = array_length(global.__INPUT[_inputNum].verbs);
		for (var i = 0; i < l; i++) {
			if (global.__INPUT[_inputNum].verbs[i] == _verb) {
				global.__INPUT[_inputNum].keys[i] = _keys;
				exit;
			}
		}
		show_message("Verb not found");
	}else {
		show_message("Input number not found");
	}
}

///@function input_buffer_add(input number, verb, buffer frames)
function input_buffer_add(_inputNum, _verb, _buffer) {
	if (_inputNum+1 <= array_length(global.__INPUT)) {
		var l = array_length(global.__INPUT[_inputNum].verbs);
		for (var i = 0; i < l; i++) {
			if (global.__INPUT[_inputNum].verbs[i] == _verb) {
				array_push(global.__INPUT[_inputNum].buffer,[_verb,_buffer]);
				global.__INPUT[_inputNum][$ _verb+"_count"] = 0;
				global.__INPUT[_inputNum][$ _verb+"_buffer"] = false;
				exit;
			}
		}
		show_message("Verb not found");
	}else {
		show_message("Input number not found");
	}
}

///@function input_stutter_add(input number, verb, delay, stutter frames)
function input_stutter_add(_inputNum, _verb, _delay, _stutter) {
	if (_inputNum+1 <= array_length(global.__INPUT)) {
		var l = array_length(global.__INPUT[_inputNum].verbs);
		for (var i = 0; i < l; i++) {
			if (global.__INPUT[_inputNum].verbs[i] == _verb) {
				array_push(global.__INPUT[_inputNum].stutter,[_verb,_delay,_stutter]);
				global.__INPUT[_inputNum][$ _verb+"_count"] = 0;
				exit;
			}
		}
		show_message("Verb not found");
	}else {
		show_message("Input number not found");
	}
}

///@function input_deadzone(Input number, deadzone)
function input_deadzone(_inputNum, _deadzone) {
	global.__INPUT[_inputNum].deadzone = _deadzone;
}

//Useless function at the moment
function input_gamepad_axis_add(_inputNum, _verb, _axis,_direction, _deadzone = 0.4) {
	if (_inputNum+1 <= array_length(global.__INPUT)) {
		global.__INPUT[_inputNum].deadzone = _deadzone;
		var l = array_length(global.__INPUT[_inputNum].verbs);
		for (var i = 0; i < l; i++) {
			if (global.__INPUT[_inputNum].verbs[i] == _verb) {
				if (is_string(_direction)) {
					if (_direction == "up") {
						array_push(global.__INPUT[_inputNum].keys[i],INPUT.AXIS_L_UP);
					}else if (_direction == "down") {
						array_push(global.__INPUT[_inputNum].keys[i],INPUT.AXIS_L_DOWN);
					}else if (_direction == "left") {
						array_push(global.__INPUT[_inputNum].keys[i],INPUT.AXIS_L_LEFT);
					}else if (_direction == "right") {
						array_push(global.__INPUT[_inputNum].keys[i],INPUT.AXIS_L_RIGHT);
					}else show_message("direction string invalid");
				}else {
					if (is_real(_direction) and _direction >= INPUT.AXIS_L_UP) {
						array_push(global.__INPUT[_inputNum].keys[i],_direction);
					}
					else show_message("direction value invalid");
				}
				exit;
			}
		}
		show_message("Verb not found");
	}else {
		show_message("Input number not found");
	}
}

// MIMPY's INPUT ===================

/* EXAMPLE
input = new InputManager(,0.45);

jump = input.create_input();
jump.add_keyboard_key(vk_space).add_gamepad_button(gp_face1);
#macro key_jump oSystem.jump.check()
#macro keyp_jump oSystem.jump.check_pressed()
#macro keyp_jump_buffer oSystem.jump.check_pressed(true)
*/
//room_instance_add(room_first,-50,-50,oInput);
/*
function InputManager(_gamepad = 0, _deadzone = 0.3) constructor {
    __inputs = []; // total inputs
    gamepad = _gamepad; // gamepad number
    deadzone = _deadzone; // gamepad axis deadzone
    buffer = 1; // how many frames of wiggle room buffered checks get

    // Call in step to update manager
    run = function() {
        var len = array_length(__inputs);
        for (var i = 0; i < len; i++)
            __inputs[i].__update();
    }

    create_input = function() {
        var _input = new Input(self);
        array_push(__inputs, _input);
        return _input;
    }
}

enum INPUT_AXIS {
    right,
    up,
    left,
    down
}

function Input(_manager) constructor {
    __manager = _manager;
    __time = 0;
    __keys = [];

    // Called by input manager's run method
    __update = function() {
        var active = false;

        var len = array_length(__keys);
        for (var i = 0; i < len; i++) {
            if (__keys[i].check()) {
                active = true;
                break;
            }
        }

        if (active)
            __time++;
        else if (__time > 0)
            __time = -__manager.buffer;
        else
            __time = min(__time + 1, 0);
    }

    add_keyboard_key = function(_key) {
        var key = {
            button: _key
        };
        key.check = method(key, function() {
            return keyboard_check(button);
        });

        array_push(__keys, key);
        return self;
    }
	
	add_mouse_button = function(_button) {
		var key = {
			button: _button,
			check: function() { return mouse_check_button(button); }
		};
		
		array_push(__keys, key);
		return self;
	}

    add_gamepad_button = function(_button) {
        var key = {
            creator: other,
            button: _button
        };
        key.check = method(key, function() {
            return gamepad_button_check(creator.__manager.gamepad, button);
        });

        array_push(__keys, key);
        return self;
    }

    add_gamepad_left_stick = function(_direction) {
        var key = {
            creator: other,
            axis: _direction == INPUT_AXIS.right || _direction == INPUT_AXIS.left ?
                gp_axislh :
                gp_axislv,
            dir: _direction == INPUT_AXIS.right || _direction == INPUT_AXIS.down ?
                1 :
                -1
        };
        key.check = method(key, function() {
            return gamepad_axis_value(creator.__manager.gamepad, axis) * dir >= creator.__manager.deadzone;
        });

        array_push(__keys, key);
        return self;
    }

    add_gamepad_right_stick = function(_direction) {
        var key = {
            creator: other,
            axis: _direction == INPUT_AXIS.right || _direction == INPUT_AXIS.left ?
                gp_axisrh :
                gp_axisrv,
            dir: _direction == INPUT_AXIS.right || _direction == INPUT_AXIS.down ?
                1 :
                -1
        };
        key.check = method(key, function() {
            return gamepad_axis_value(creator.__manager.gamepad, axis) * dir >= creator.__manager.deadzone;
        });

        array_push(__keys, key);
        return self;
    }

    // Check for a hold
    check = function() {
        return __time > 0;
    }

    // Check for a press
    check_pressed = function(_buffered = false) {
        if (_buffered)
               return __time > 0 && __time <= __manager.buffer;
        return __time == 1;
    }

    // Check for a release
    check_released = function(_buffered = false) {
        if (_buffered)
            return __time < 0;
        return __time == -__manager.buffer;
    }

    // Check for sporadic presses over intervals of time
    check_stutter = function(_initial_delay, _interval) {
        if (__time == 1)
            return true;

        return __time - _initial_delay > 0 && (__time - _initial_delay) % _interval == 0;
    }

    // Sets input to a state that a buffered press check does not find true
    fully_press = function() {
        __time = __manager.buffer + 1;
    }

    // Sets input to a state that a buffered release check does not find true
    fully_release = function() {
        __time = 0;
    }
}*/