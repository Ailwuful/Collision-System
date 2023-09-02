collision_object_init();

path = path_add();
path_add_point(path, x, y, 80);
path_add_point(path, x + TILE_SIZE, y, 100);
path_add_point(path, x + TILE_SIZE * 4, y, 100);
path_add_point(path, x + TILE_SIZE * 4 + TILE_SIZE, y, 80);
path_set_closed(path, true);
path_start(path, 2, path_action_continue, true);

collision_link = id;
move_other = function(_col) {
	var xspd = x - xprevious;
	var yspd = y - yprevious;
	
	if (path_index != -1) {
		other.x += xspd;
		other.y += yspd;
	}
}

collision_bit = col_bit.platform;
move_ground = function() {return COLLIDED.NONE};
move_air_up = function() {return COLLIDED.NONE};
move_air_down = function(_col) {
	with (other) {
		if (yprevious <= _col.bbox_top + 0.5 and place_meeting(x, y, _col)) {
			y = _col.bbox_top;
			return COLLIDED.DOWN;
		}
		return COLLIDED.NONE;
	}
}