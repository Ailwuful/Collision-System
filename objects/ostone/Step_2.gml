collision_check();
if (falling) {
	vspeed += GRAVITY;
	var collided = collision_move("move_air_down");
	if (collided == COLLIDED.DOWN) {
		vspeed = 0;
		collision_ground_check();
		falling = false;
	}
}else {
	collision_ground_check();
	collision_move("move_ground");
	if (ground_bit == col_bit.none) falling = true;
}