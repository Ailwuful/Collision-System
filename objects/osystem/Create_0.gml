var keys = {
	up : [ord("W"), vk_up, gp_padu, vk_space],
	down : [ord("S"), vk_down, gp_padd],
	left : [ord("A"), vk_left, gp_padl],
	right : [ord("D"), vk_right, gp_padr]
}

input_create(0, keys);
input_buffer_add(0, "up", 6);