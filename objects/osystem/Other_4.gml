//This code will read the Collisions layer and create oCollision instances in place of the collision tiles.
var tilemap = layer_tilemap_get_id(layer_get_id("Collisions"));
layer_set_visible("Collisions",false);
var w = room_width div TILE_SIZE,
	h = room_height div TILE_SIZE,
	inst, tile, index;
	
var col_layer = layer_create(0,"Collision_Objects");

for (var o = 0; o < h; o++) {
	for (var i = 0; i < w; i++) {
		tile = tilemap_get(tilemap,i,o);
		index = tile_get_index(tile);
		if (index != 0) {
			inst = instance_create_layer(i*TILE_SIZE,o*TILE_SIZE,col_layer,oCollision);
			inst.image_index = index;
			
			// This while stretches the instance horizontally to conserve number of oCollision instances
			if (tile_get_index(tilemap_get(tilemap,i+1,o)) == index) {
				while(tile_get_index(tilemap_get(tilemap,i+1,o)) == index) {
					inst.image_xscale++;
					i++;
				}
			}
			// This while stretches the instance vertically, but we don't want to add to o in this case since it will mess the for loop
			else if (tile_get_index(tilemap_get(tilemap,i,o+1)) == index) {
				var _o = o;
				while(tile_get_index(tilemap_get(tilemap,i,_o+1)) == index) {
					//We set the tile to 0 so next time the for loop reaches this tile, it doesn't create another instance on top of the stretched one
					tilemap_set(tilemap, 0, i, _o+1);
					inst.image_yscale++;
					_o++;
				}
			}
		}
	}
}