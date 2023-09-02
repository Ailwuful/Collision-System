collision_object_init();
collision_actor_init();
frame = 0;
spd = 1;

move_ground = function() {
	alarm[0] = 2;
	if (frame++ >= 15) {
		var dir = sign(other.hspeed);
		//other.x += spd*dir;
		x += spd*dir;
		other.hspeed = 0;
	}
	if (other.x >= bbox_right) {
		other.x = bbox_right + other.collision_halfmask;
		return COLLIDED.LEFT;
	}
	else if (other.x <= bbox_left) {
		other.x = bbox_left - other.collision_halfmask;
		return COLLIDED.RIGHT;
	}
	return COLLIDED.NONE;
}