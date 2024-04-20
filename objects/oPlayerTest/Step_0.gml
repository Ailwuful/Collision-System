var right_key = keyboard_check(vk_right) or keyboard_check(ord ("D"));
var left_key = keyboard_check(vk_left) or keyboard_check(ord ("A"));
var jump_key = keyboard_check(vk_space);

xspd = (right_key - left_key) * move_spd;

var onGround = place_meeting(x, y+2, oCollision);
if (onGround) {
	yspd = 0;
	if (jump_key) yspd = -jump_speed;
}else {
	yspd += grav;
}

move_and_collide(xspd, yspd, oCollision);