function player_ground() {
	
	static step = function() {
		var move = input.right - input.left;
		var accel = 0.4 * ground_acceleration;
		var drift = accel * 0.5;

		if (move != 0) {
			hspeed = clamp(hspeed + accel * move, -run_speed * ground_speed, run_speed * ground_speed);
		}else {
			hspeed = lerp(hspeed, 0, drift);
		}
		if (input.up_buffer) {
			jump();
		}
		else if (input.down_pressed and ground_bit == col_bit.platform) {
			y += 1;
			yprevious += 1;
			fall();
		}
	}
	
	static end_step = function() {
		collision_check();
		collision_ground_check();
		collision_move("move_ground");
		
		if (ground_bit == col_bit.none) fall();
	}
}
player_ground(); //We have to call the function once in the game to initialize the static methods

function player_air() {
	
	static step = function() {
		var move = input.right - input.left;
		var accel = 0.25;
		var decel = 0.02

		if (move != 0) {
			hspeed = clamp(hspeed + accel * move, -run_speed, run_speed);
		}else {
			hspeed = lerp(hspeed, 0, decel);
		}
		
		//Coyote Time
		if (coyote > 0) {
			coyote--;
			if (input.up_pressed) {
				coyote = 0;
				jump();
			}
		}
	}
	
	static end_step = function() {
		collision_check();
		
		var _collided = 0;
		var _vspeed = vspeed;
		vspeed += GRAVITY;
		if (_vspeed < 0) {
			collision_move("move_air_up");
			if (_vspeed > -2) wall_jump();
		}
		if (_vspeed >= 0) {
			_collided = collision_move("move_air_down");
			if (_collided & COLLIDED.DOWN == COLLIDED.DOWN) land();
			if (_collided == COLLIDED.NONE or _collided == COLLIDED.RIGHT or _collided == COLLIDED.LEFT) {
				wall_jump();
				ledge_grab();
			}
		}
	}
}
player_air();

function player_ledgehang() {
	static step = function() {
		if (input.up_pressed) jump();
		else if (input.down_pressed) {
			fall();
			can_grab = false;
			alarm[0] = 10;
		}
	}
	
	static end_step = function() {
		
	}
}
player_ledgehang();