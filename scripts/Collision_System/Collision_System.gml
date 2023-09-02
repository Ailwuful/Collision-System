#macro grav 0.25
#macro MAX_FALL_SPEED 8
#macro TILE_SIZE 32
#macro LEDGE_CORRECTION 4
#macro CORNER_CORRECTION 4

enum col_bit {
	none = 0,
	wall = 1,
	slope = 2,
	platform = 4,
}{
     // code here
 }

//Try to always have a mask that is an even number of pixels, which means an odd number in terms of the inspector values
/// @function collision_actor_init()
/// @desc Initializes necessary variables for things that need to use the collision system
function collision_actor_init() {
	collision_array = array_create(0); //this is maintained to know what you've been in collision with this frame
	collision_halfmask = ((bbox_right - bbox_left) * 0.5); //this is used to move the instance close to the wall, but this value assumes your origin point is in the middle of the instance
	collision_maskheight = bbox_bottom - bbox_top; //this is used to move the instance close to the wall, but this value assumes your origin point is in the bottom of the instance
	collision_slope = noone; //Slopes require special code to be handled with walls, so when in collision with a slope I store it in this variable
	ground_bit = 0; //this can be used to know what kind of ground you're stepping on, important for special behavior like checking if you're solely on a platform and can drop down. Check the Bitwise operations in the manual for knowledge.
	ground_link = noone; //this is used to link the character to the ground so it moves along with the ground, like with moving platforms
	ground_sound = -1; //this variable stores which sound steps should make when moving on the ground
	ground_speed = 1; //this can be used to change the speed a character can move in this ground
	ground_acceleration = 1; //this can be used to change the acceleration the character moves in this ground
}

/// @function	collision_object_init()
/// @desc	Initializes necessary variables for objects that need to be collided. They also need to be children of oCollision
function collision_object_init() {
	collision_bit = col_bit.wall; //this can be used to know what kind of ground you're stepping on, I use bitwise operations to make sure you're only stepping on one type of ground and not two
	collision_acceleration = 1; //this can be used to change the acceleration the character moves in this ground
	collision_speed = 1; //this can be used to change the speed a character can move in this ground
	collision_sound = -1; //this variable is passed to the actor when they step on this instance. To be used to make stepping sounds.
	collision_link = noone; //this is used to link the character to the ground so it moves along with the ground, like with moving platforms
	
	move_ground = method(self, move_ground_default); //Creating a method function with move_ground_default behaviour bound to the instance
	move_air_up = method(self, move_vertical_up_default);
	move_air_down = method(self, move_vertical_down_default);
}

///@function	collision_check()
///@desc		Checks for collision and stores values in necessary variables
function collision_check() {
	var _list = ds_list_create();
	var _num = instance_place_list(x, y, oCollision, _list, false);
	array_resize(collision_array, 0);
	collision_slope = noone; //Slopes are special in that they need to ignore collision with walls while you're in one. So I store it in a special variable.
	ground_bit = 0;
	ground_link = noone;
	
	var i = 0;
	repeat (_num) {
		var _id = _list[| i];
		if (_id.object_index == oCollision) {
			var _index = _id.image_index;
			var _bit = global.collisions[_index].collision_bit;
			if (_bit == col_bit.slope) {
				if (x mod _id.x <= TILE_SIZE) {
					collision_slope = _id;
					ground_bit |= _bit;
				}
			}else {
				array_push(collision_array, _id);
			}
		}else {
			array_push(collision_array, _id);
		}
		i++;
	}
	ds_list_destroy(_list);
}

///@function	collision_ground_check()
///@desc		Checks a rectangle area on the feet of the instance to check what the instance is stepping on.
function collision_ground_check() {
	var _list = ds_list_create();
	// The +1 and -1 to bboxes is not ideal but necessary because collision_rectangle rounds values and it can return true when you're not really colliding with something
	// The values on this rectangle can be changed to fit the needs of your game
	var _num = collision_rectangle_list(bbox_left + 1, bbox_bottom, bbox_right - 1, bbox_bottom + 5, oCollision, true, false, _list, false);
	var _id = noone;
	
	var i = 0;
	repeat (_num) {
		_id = _list[| i];
		if (_id.object_index == oCollision) {
			var _bit = global.collisions[_id.image_index].collision_bit;
			if (_bit == col_bit.slope and collision_slope == noone) {
				if (x mod _id.x <= TILE_SIZE) {
					collision_slope = _id;
					ground_bit = _bit;
					ground_speed = global.collisions[_id.image_index].collision_speed;
					ground_acceleration = global.collisions[_id.image_index].collision_acceleration;
					ground_sound = global.collisions[_id.image_index].collision_sound;
				}
			}
		}
		i++;
	}
	
	if (_num > 0 and collision_slope == noone) {
		// I will assume you're never in collision on the ground with more than 2 different things, not counting slopes
		if (_num > 1) {
			var _distance_1 = 0;
			var _distance_2 = 0;
			with (_list[| 0]) {
				_distance_1 = distance_to_point(other.x, other.y);
			}
			with (_list[| 1]) {
				_distance_2 = distance_to_point(other.x, other.y);
			}
			i = _distance_1 < _distance_2 ? 0 : 1;
		}else {
			i = 0;
		}
		
		_id = _list[| i];
		if (_id.object_index == oCollision) {
			ground_bit |= global.collisions[_id.image_index].collision_bit;
			ground_speed = global.collisions[_id.image_index].collision_speed;
			ground_acceleration = global.collisions[_id.image_index].collision_acceleration;
			ground_sound = global.collisions[_id.image_index].collision_sound;
		}else {
			ground_bit |= _id.collision_bit;
			ground_speed = _id.collision_speed;
			ground_acceleration = _id.collision_acceleration;
			ground_sound = _id.collision_sound;
			ground_link = _id.collision_link;
		}
	}
	
	ds_list_destroy(_list);
}

///@function		collision_move(method_string)
///@desc			Iterates through the collisions stored to move the instance. Returns a real representing what sides the instance collided, to be used in a bitwise operation.
///@arg	{String}	_method	The method name as a string to check how to move the instance.
///@return	{Real}	
function collision_move(_method) {
	var _collided = 0;
	var _colnum = array_length(collision_array);
	var _id = noone;
	if (ground_link != noone) ground_link.move_other();
	
	if (collision_slope != noone) {
		if (_colnum > 0) {
			_id = collision_array[0];
			if (collision_slope.y != _id.y) {
				if (_id.object_index == oCollision) _collided |= global.collisions[_id.image_index][$ _method](_id);
				else _collided |= _id[$ _method](_id);
			}
		}
		_collided |= global.collisions[collision_slope.image_index][$ _method](collision_slope);
	}
	else if (_colnum > 0) {
		var i = 0;
		repeat (_colnum) {
			_id = collision_array[i];
			if (_id.object_index == oCollision) _collided |= global.collisions[_id.image_index][$ _method](_id);
			else _collided |= _id[$ _method](_id);
			i++;
			
			if (_collided & COLLIDED.STOP == COLLIDED.STOP) return COLLIDED.STOP;
		}
	}
	return _collided;
}

///@function	collision_tile_template()
///@desc		Can be used to fill an index in the global.collisions array with default collision values same as a solid wall.
///@self <constructor>
function collision_tile_template() constructor {
	collision_bit = col_bit.wall;
	collision_acceleration = 1;
	collision_speed = 1;
	collision_sound = -1;
	
	move_ground = function(_col) {
		with (other) {
			// The extra 0.5 is because collisions only register when instances overlap at half a pixel
			// If you have sub 0.5 speeds your sprite can look to jitter while moving towards walls, though
			if (bbox_right - (x - xprevious) <= _col.bbox_left + 0.5) {
				x = _col.bbox_left - collision_halfmask;
				hspeed = 0;
				return COLLIDED.RIGHT;
			}
			else if (bbox_left - (x - xprevious) >= _col.bbox_right - 0.5) {
				x = _col.bbox_right + collision_halfmask;
				hspeed = 0;
				return COLLIDED.LEFT;
			}
			else {
				y = _col.bbox_top;
			}
			return COLLIDED.NONE;
		}
	}
	move_air_up = function(_col) {
		with (other) {
			//Vertical check
			if (place_meeting(xprevious, y, _col)) {
				// Ledge_correction allows the actor to continue going up if they hit the wall going up by just a few pixels
				if (!place_meeting(x + LEDGE_CORRECTION, y, oCollision)) {
					x = _col.bbox_right + collision_halfmask;
				}
				else if (!place_meeting(x - LEDGE_CORRECTION, y, oCollision)) {
					x = _col.bbox_left - collision_halfmask;
				}
				else {
					if (yprevious < _col.bbox_bottom) y = _col.bbox_top;
					else {
						y = _col.bbox_bottom + collision_maskheight;
						vspeed = 0;
						return COLLIDED.UP;
					}
				}
			}
			//Horizontal check
			if (place_meeting(x, y, _col)) {
				if (xprevious <= _col.bbox_left + 0.5) {
					x = _col.bbox_left - collision_halfmask;
					hspeed = 0;
					return COLLIDED.LEFT;
				}
				if (xprevious >= _col.bbox_right - 0.5) {
					x = _col.bbox_right + collision_halfmask;
					hspeed = 0;
					return COLLIDED.RIGHT;
				}
			}
			return COLLIDED.NONE;
		}
	}
	move_air_down = function(_col) {
		with (other) {
			//Check if landing somewhere first and Checking collision again since another collision may already have stopped me
			if (yprevious <= _col.bbox_top + 0.5 and place_meeting(x, y, _col)) {
				y = _col.bbox_top;
				vspeed = 0;
				return COLLIDED.DOWN;
			}
			//Checking collision again since another collision may already have stopped me
			if (place_meeting(x, y, _col)) {
				if (xprevious <= _col.bbox_left + 0.5) {
					x = _col.bbox_left - collision_halfmask;
					hspeed = 0;
					return COLLIDED.LEFT;
				}
				if (xprevious >= _col.bbox_right - 0.5) {
					x = _col.bbox_right + collision_halfmask;
					hspeed = 0;
					return COLLIDED.RIGHT;
				}
			}
			return COLLIDED.NONE;
		}
	}
}

///@function	move_ground_default(collision_id)
///@desc		To be used with the method() function to bind this function as a default method in a struct of the global.collisions array.
///@return {Real}
function move_ground_default(_col) {
	with (other) {
		if (bbox_right - (x - xprevious) <= _col.bbox_left + 0.5) {
			x = _col.bbox_left - collision_halfmask;
			return COLLIDED.RIGHT;
		}
		else if (bbox_left - (x - xprevious) >= _col.bbox_right - 0.5) {
			x = _col.bbox_right + collision_halfmask;
			return COLLIDED.LEFT;
		}
		else {
			y = _col.bbox_top; // This is in case you're coming off a slope at high speeds
		}
		return COLLIDED.NONE;
	}
}

///@function	move_vertical_up_default(collision_id)
///@desc		To be used with the method() function to bind this function as a default method in a struct of the global.collisions array.
///@return {Real}
function move_vertical_up_default(_col) {
	with (other) {
		//Vertical check
		if (place_meeting(xprevious, y, _col)) {
			if (!place_meeting(x + LEDGE_CORRECTION, y, oCollision)) {
				x = _col.bbox_right + collision_halfmask;
			}
			else if (!place_meeting(x - LEDGE_CORRECTION, y, oCollision)) {
				x = _col.bbox_left - collision_halfmask;
			}
			else {
				if (yprevious < _col.bbox_bottom) y = _col.bbox_top;
				else {
					y = _col.bbox_bottom + collision_maskheight;
					vspeed = 0;
					return COLLIDED.UP;
				}
			}
		}
		//Horizontal check
		if (place_meeting(x, y, _col)) {
			if (xprevious <= _col.bbox_left + 0.5) {
				x = _col.bbox_left - collision_halfmask;
				hspeed = 0;
				return COLLIDED.LEFT;
			}
			if (xprevious >= _col.bbox_right - 0.5) {
				x = _col.bbox_right + collision_halfmask;
				hspeed = 0;
				return COLLIDED.RIGHT;
			}
		}
		return COLLIDED.NONE;
	}
}

///@function	move_vertical_down_default(collision_id)
///@desc		To be used with the method() function to bind this function as a default method in a struct of the global.collisions array.
///@return {Real}
function move_vertical_down_default(_col) {
	with (other) {
		if (yprevious <= _col.bbox_top + 0.5 and place_meeting(x, y, _col)) {
			y = _col.bbox_top;
			vspeed = 0;
			return COLLIDED.DOWN;
		}
		if (place_meeting(x, y, _col)) {
			if (xprevious <= _col.bbox_left + 0.5) {
				x = _col.bbox_left - collision_halfmask;
				hspeed = 0;
				return COLLIDED.LEFT;
			}
			if (xprevious >= _col.bbox_right - 0.5) {
				x = _col.bbox_right + collision_halfmask;
				hspeed = 0;
				return COLLIDED.RIGHT;
			}
		}
		return COLLIDED.NONE;
	}
}