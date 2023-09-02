# Collision System
 
Welcome to Ailwuful's awesome and robust platformer collision system.
Which can be adapted to other types of games, of course.

How does it work?

1. oSystem has a Room Start event that will look for a layer named "Collisions", and upon finding
one it will automatically create instances of the oCollision object in the room to be used in
as collisions.

2. oCollision has a sprite that has shapes to be collided with and they represent what type of
collision should happen. The image_index of the sprCollisionTiles has to match the index of the
tiles in the collision tileset.

3. That image_index is used to know which index in a global.collisions array to access. Which
should countain a struct with variables and methods determining what happens when in collision
with that tile/instance.

4. Other objects can also be children of oCollision and they can have these variables and methods
in them.

This project has examples of possible collision tiles and a player object with some functionality

The system has 3 main functions to handle collision

collision_check() should be called from the scope of the instance colliding, it will simply
collect which instances have been collided with and store them in a variable

collision_ground_check() does something similar, but in a rectangular area on the bottom of the
instance, to store variables that can change the behavior of the instance.
It is also used to check slopes going down.

collision_move(method_string) will move the instance by calling the methods that handle the
collision. Which method to call needs to be passed as a string. 
This is where the beauty of the system lies. You can customize different behavior to different
objects or tiles.

You can also take some inspiration on how I'm doing states and triggers in the oPlayer object.
Usually triggers that change something are methods in the create event.
The code that the player runs is stored in functions in a script specific for the player.