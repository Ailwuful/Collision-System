enum COLLIDED {
	NONE = 0,
	DOWN = 1,
	LEFT = 2,
	RIGHT = 4,
	UP = 8,
	STOP = 16 //Stop is in case you touch a special tile like a spike, there's no reason to check any other tiles, so you STOP the checks
}

enum COLLISION_TILE {
	NONE,
	SOLID,
	PLATFORM,
	SLOPE_STEEP_UP,
	SLOPE_STEEP_DOWN,
	SLOPE_SOFT_UP_1,
	SLOPE_SOFT_UP_2,
	SLOPE_SOFT_DOWN_2,
	SLOPE_SOFT_DOWN_1,
	SPRING,
	SOLID_MUDDY,
	SOLID_SLIPPERY,
	LEDGE_GRAB,
	WALL_JUMP,
	LAST
}

global.collisions = array_create(COLLISION_TILE.LAST);

//Default collision struct for solid stuff, copy from this as a template and modify to specific tile
//You can also use constructor collision_tile_template as a default and then alter it after created
//You can add more variables if your game needs it 
global.collisions[COLLISION_TILE.SOLID] = {
	collision_bit : col_bit.wall,
	collision_acceleration : 1,
	collision_speed : 1,
	collision_sound : -1,
	
	move_ground : method(self, move_ground_default),
	move_air_up : method(self, move_vertical_up_default),
	move_air_down : method(self, move_vertical_down_default)
}

global.collisions[COLLISION_TILE.PLATFORM] = {
	collision_bit : col_bit.platform,
	collision_acceleration : 1,
	collision_speed : 1,
	collision_sound : -1,
	
	move_ground : function(_col) {return COLLIDED.NONE;},
	move_air_up : function(_col) {return COLLIDED.NONE;},
	move_air_down : function(_col) {
		with (other) {
			if (yprevious <= _col.bbox_top + 0.5 and place_meeting(x, y, _col)) {
				y = _col.bbox_top;
				return COLLIDED.DOWN;
			}
			return COLLIDED.NONE;
		}
	}
}
global.collisions[COLLISION_TILE.SLOPE_STEEP_UP] = {
	collision_bit : col_bit.slope,
	collision_acceleration : 1,
	collision_speed : 1,
	collision_sound : -1,
	
	move_ground : function(_col) {
		var _x = other.x mod _col.x;
		if (_x <= TILE_SIZE) {
			other.y = _col.bbox_bottom - _x;
		}
		return COLLIDED.NONE;
	},
	move_air_up : function(_col) {
		with (other) {
			var _x = x mod _col.x,
				_y = _col.bbox_bottom - _x;
			if (_x <= TILE_SIZE) {
				if (y >= _y) {
					y = _y;
					return COLLIDED.DOWN;
				}
			}
			return COLLIDED.NONE;
		}
	},
	move_air_down : function(_col) {
		with (other) {
			var _x = x mod _col.x,
				_y = _col.bbox_bottom - _x;
			if (_x <= TILE_SIZE) {
				if (y >= _y) {
					y = _y;
					return COLLIDED.DOWN;
				}
			}
		}
		return COLLIDED.NONE;
	}
}
global.collisions[COLLISION_TILE.SLOPE_STEEP_DOWN] = {
	collision_bit : col_bit.slope,
	collision_acceleration : 1,
	collision_speed : 1,
	collision_sound : -1,
	
	move_ground : function(_col) {
		var _x = other.x mod _col.x;
		if (_x <= TILE_SIZE) {
			other.y = _col.bbox_top + _x;
		}
		return COLLIDED.NONE;
	},
	move_air_up : function(_col) {
		with (other) {
			var _x = x mod _col.x,
				_y = _col.bbox_top + _x;
			if (_x <= TILE_SIZE) {
				if (y >= _y) {
					y = _y;
					return COLLIDED.DOWN;
				}
			}
			return COLLIDED.NONE;
		}
	},
	move_air_down : function(_col) {
		with (other) {
			var _x = x mod _col.x,
				_y = _col.bbox_top + _x;
			if (_x <= TILE_SIZE) {
				if (y >= _y) {
					y = _y;
					return COLLIDED.DOWN;
				}
			}
			return COLLIDED.NONE;
		}
	}
}
global.collisions[COLLISION_TILE.SLOPE_SOFT_UP_1] = {
	collision_bit : col_bit.slope,
	collision_acceleration : 1,
	collision_speed : 1,
	collision_sound : -1,
	
	move_ground : function(_col) {
		var _x = other.x mod _col.x;
		if (_x <= TILE_SIZE) {
			other.y = _col.bbox_bottom - 0.5*_x;
		}
		return COLLIDED.NONE;
	},
	move_air_up : function(_col) {
		with (other) {
			var _x = x mod _col.x,
				_y = _col.bbox_bottom - 0.5*_x;
			if (_x <= TILE_SIZE) {
				if (y >= _y) {
					y = _y;
					return COLLIDED.DOWN;
				}
			}
			return COLLIDED.NONE;
		}
	},
	move_air_down : function(_col) {
		with (other) {
			var _x = x mod _col.x,
				_y = _col.bbox_bottom - 0.5*_x;
			if (_x <= TILE_SIZE) {
				if (y >= _y) {
					y = _y;
					return COLLIDED.DOWN;
				}
			}
			return COLLIDED.NONE;
		}
	}
}
global.collisions[COLLISION_TILE.SLOPE_SOFT_UP_2] = {
	collision_bit : col_bit.slope,
	collision_acceleration : 1,
	collision_speed : 1,
	collision_sound : -1,
	
	move_ground : function(_col) {
		var _x = other.x mod _col.x;
		if (_x <= TILE_SIZE) {
			other.y = _col.bbox_bottom - 0.5*_x - TILE_SIZE/2;
		}
		return COLLIDED.NONE;
	},
	move_air_up : function(_col) {
		with (other) {
			var _x = x mod _col.x,
				_y = _col.bbox_bottom - 0.5*_x - TILE_SIZE/2;
			if (_x <= TILE_SIZE) {
				if (y >= _y) {
					y = _y;
					return COLLIDED.DOWN;
				}
			}
			return COLLIDED.NONE;
		}
	},
	move_air_down : function(_col) {
		with (other) {
			var _x = x mod _col.x,
				_y = _col.bbox_bottom - 0.5*_x - TILE_SIZE/2;
			if (_x <= TILE_SIZE) {
				if (y >= _y) {
					y = _y;
					return COLLIDED.DOWN;
				}
			}
			return COLLIDED.NONE;
		}
	}
}
global.collisions[COLLISION_TILE.SLOPE_SOFT_DOWN_1] = {
	collision_bit : col_bit.slope,
	collision_acceleration : 1,
	collision_speed : 1,
	collision_sound : -1,
	
	move_ground : function(_col) {
		var _x = other.x mod _col.x;
		if (_x <= TILE_SIZE) {
			other.y = _col.bbox_top + 0.5*_x + TILE_SIZE/2;
		}
		return COLLIDED.NONE;
	},
	move_air_up : function(_col) {
		with (other) {
			var _x = x mod _col.x,
				_y = _col.bbox_top + 0.5*_x + TILE_SIZE/2;
			if (_x <= TILE_SIZE) {
				if (y >= _y) {
					y = _y;
					return COLLIDED.DOWN;
				}
			}
			return COLLIDED.NONE;
		}
	},
	move_air_down : function(_col) {
		with (other) {
			var _x = x mod _col.x,
				_y = _col.bbox_top + 0.5*_x + TILE_SIZE/2;
			if (_x <= TILE_SIZE) {
				if (y >= _y) {
					y = _y;
					return COLLIDED.DOWN;
				}
			}
			return COLLIDED.NONE;
		}
	}
}
global.collisions[COLLISION_TILE.SLOPE_SOFT_DOWN_2] = {
	collision_bit : col_bit.slope,
	collision_acceleration : 1,
	collision_speed : 1,
	collision_sound : -1,
	
	move_ground : function(_col) {
		var _x = other.x mod _col.x;
		if (_x <= TILE_SIZE) {
			other.y = _col.bbox_top + 0.5*_x;
		}
		return COLLIDED.NONE;
	},
	move_air_up : function(_col) {
		with (other) {
			var _x = x mod _col.x,
				_y = _col.bbox_top + 0.5*_x;
			if (_x <= TILE_SIZE) {
				if (y >= _y) {
					y = _y;
					return COLLIDED.DOWN;
				}
			}
			return COLLIDED.NONE;
		}
	},
	move_air_down : function(_col) {
		with (other) {
			var _x = x mod _col.x,
				_y = _col.bbox_top + 0.5*_x;
			if (_x <= TILE_SIZE) {
				if (y >= _y) {
					y = _y;
					return COLLIDED.DOWN;
				}
			}
			return COLLIDED.NONE;
		}
	}
}
global.collisions[COLLISION_TILE.SPRING] = {
	collision_bit : col_bit.none,
	collision_acceleration : 1,
	collision_speed : 1,
	collision_sound : -1,
	
	move_ground : function(_col) {return COLLIDED.NONE;},
	move_air_up : function(_col) {return COLLIDED.NONE;},
	move_air_down : function(_col) {
		other.jump(10);
		return COLLIDED.STOP;
	}
}

global.collisions[COLLISION_TILE.SOLID_MUDDY] = {
	collision_bit : col_bit.wall,
	collision_acceleration : 1,
	collision_speed : 0.5,
	collision_sound : -1,
	
	move_ground : method(self, move_ground_default),
	move_air_up : method(self, move_vertical_up_default),
	move_air_down : method(self, move_vertical_down_default)
}

global.collisions[COLLISION_TILE.SOLID_SLIPPERY] = {
	collision_bit : col_bit.wall,
	collision_acceleration : 0.1,
	collision_speed : 1,
	collision_sound : -1,
	
	move_ground : method(self, move_ground_default),
	move_air_up : method(self, move_vertical_up_default),
	move_air_down : method(self, move_vertical_down_default)
}

global.collisions[COLLISION_TILE.LEDGE_GRAB] = new collision_tile_template();
global.collisions[COLLISION_TILE.WALL_JUMP] = new collision_tile_template();