collision_actor_init();
input = -1;
run_speed = 2.4;
coyote = 0;
state_active = playerState.ground;

enum playerState {
	ground,
	air,
	ledgeHang
}

state = function(_state) {
	switch(_state) {
		case playerState.ground:
			state_active = playerState.ground;
			step = player_ground.step;
			end_step = player_ground.end_step;
		break;
		case playerState.air:
			state_active = playerState.air;
			step = player_air.step;
			end_step = player_air.end_step;
		break;
		case playerState.ledgeHang:
			state_active = playerState.ledgeHang;
			step = player_ledgehang.step;
			end_step = player_ledgehang.end_step;
		break;
	}
}

state(playerState.ground);

land = function() {
	vspeed = 0;
	state(playerState.ground);
	collision_ground_check();
}

jump = function(_speed = 6) {
	vspeed = -_speed;
	state(playerState.air);
}

fall = function() {
	state(playerState.air);
	coyote = 5;
}

can_grab = true;
ledge_grab = function() {
	if (!can_grab) return;
	
	var i = 0;
	var ledge = noone;
	// If there is stuff in collision array, check if one of them is a ledge grab collision
	repeat (array_length(collision_array)) {
		if (collision_array[i].object_index == oCollision and collision_array[i].image_index == COLLISION_TILE.LEDGE_GRAB) {
			ledge = collision_array[i];
			break;
		}
	}
	// if there isn't any, check for instances next to the player
	if (ledge == noone) {
		if (image_xscale == 1) ledge = instance_position(bbox_right + 4, bbox_top+10, oCollision);
		else ledge = instance_position(bbox_left - 4, bbox_top+10, oCollision);
		if (ledge != noone and ledge.object_index == oCollision and ledge.image_index == COLLISION_TILE.LEDGE_GRAB) i = 0; // The i = 0 is just dummy code, I only need the else
		else return;
	}
	
	if (ledge != noone) {
		if (x >= ledge.bbox_right) {
			if (point_distance(bbox_left,bbox_top,ledge.bbox_right+1,ledge.bbox_top) < 6) {
				x = ledge.bbox_right + collision_halfmask;
				state(playerState.ledgeHang);
				y = ledge.bbox_bottom+5;
				hspeed = 0;
				vspeed = 0;
			}
		}
		else if (x <= ledge.bbox_left) {
			if (point_distance(bbox_right,bbox_top,ledge.bbox_left-1,ledge.bbox_top) < 6) {
				x = ledge.bbox_left - collision_halfmask;
				state(playerState.ledgeHang);
				y = ledge.bbox_bottom+5;
				hspeed = 0;
				vspeed = 0;
			}
		}
	}
}

wall_jump_buffer = 0;
wall_jump = function() {
	var i = 0;
	var wall = noone;
	repeat (array_length(collision_array)) {
		if (collision_array[i].object_index == oCollision and collision_array[i].image_index == COLLISION_TILE.WALL_JUMP) {
			wall = collision_array[i];
			break;
		}
	}
	
	if (wall == noone) {
		if (image_xscale == 1) wall = instance_position(bbox_right + 1, bbox_top + collision_maskheight/2, oCollision);
		else wall = instance_position(bbox_left - 1, bbox_top + collision_maskheight/2, oCollision);
		if (wall != noone and wall.object_index == oCollision and wall.image_index == COLLISION_TILE.WALL_JUMP) i = 0; // dummy code
		else wall = noone;
	}
	
	if (wall != noone) {
		wall_jump_buffer = 5;
		if (input.up_pressed) {
			if (wall.bbox_right < x) {
				jump();
				hspeed = 2;
			}else {
				jump();
				hspeed = -2;
			}
		}
	}else {
		wall_jump_buffer--;
		if (wall_jump_buffer > 0 and input.up_pressed) {
			jump();
		}
	}
}