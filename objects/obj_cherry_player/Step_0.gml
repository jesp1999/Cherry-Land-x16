/// @description Insert description here
// You can write your code in this editor
key_right = keyboard_check(ord("D"));
key_left = keyboard_check(ord("A"));
key_up = keyboard_check(ord("W"));
key_down = keyboard_check(ord("S"));
key_jump = keyboard_check_pressed(vk_space);
key_jump_down = keyboard_check(vk_space);
key_sprint = keyboard_check(vk_shift);

colliding_right = place_meeting(x+1, y, obj_solid_parent);
colliding_left = place_meeting(x-1, y, obj_solid_parent);
colliding_down = place_meeting(x, y+1, obj_solid_parent);
colliding_up = place_meeting(x, y-1, obj_solid_parent);

accel = key_right - key_left;

// Friction and terminal velocity control
if (colliding_down) {
	if (key_sprint) {
		xspeed_term = 3;
		frict = 0.1;
	} else {
		xspeed_term = 1.5;
		frict = 0.25;
	}
} else {
	xspeed_term = 3;
	frict = 0.07;
}

// Flags jumping as false when at peak of jump
if (yspeed >= 0) {
	jumping = false;
}

// You can jump once you stand on a wall
if (colliding_down) {
	canjump = true;
}

// Speed depends on acceleration from movement input
if (colliding_down) {
	xspeed += accel * moveaccel;
} else {
	xspeed += 0.5 * accel * moveaccel;
}
xspeed -= frict * xspeed;
if (abs(xspeed) > xspeed_term) {
	xspeed = sign(xspeed) * xspeed_term;
}

// Accelerate due to gravity
if (yspeed < yspeed_term) {
	if (!(place_meeting(x, y-1, obj_solid_parent) && key_jump_down)) {
		yspeed += accelfactor * grav;
	}
}

// Allow you to terminate mid-jump
if (jumping && !key_jump_down) {
	yspeed /= 2;
}

// Jump code
if (canjump && key_jump) {
	if (colliding_down) {
		canjump = false;
		jumping = true;
		if (place_meeting(x, y+1, obj_bouncy)) {
			yspeed = key_jump * -bouncespeed;
		} else {
			yspeed = key_jump * -jumpspeed;
		}
	} else if (colliding_up) {
		//TODO*/
	} else if (colliding_left && key_left) {
		canjump = false;
		jumping = true;
		walljumping = true;
		canwalljump = false;
		if (place_meeting(x-1, y, obj_bouncy)) {
			yspeed = key_jump * -bouncespeed;
			xspeed = bouncespeed;
		} else {
			yspeed = key_jump * -jumpspeed;
			xspeed = bouncespeed;
		}
	}
	if (colliding_right && key_right) {
		canjump = false;
		jumping = true;
		walljumping = true;
		canwalljump = false;
		if (place_meeting(x+1, y, obj_bouncy)) {
			yspeed = key_jump * -bouncespeed;
			xspeed = -bouncespeed;
		} else {
			yspeed = key_jump * -jumpspeed;
			xspeed = -bouncespeed;
		}
	}
}

// Move until colliding with a wall horizontally
if (place_meeting(x+xspeed, y, obj_solid_parent)) {
	while(!place_meeting(x+sign(xspeed), y, obj_solid_parent)) {
		x += sign(xspeed);	
	}
	xspeed = 0;
}
x += xspeed;

// Slide down a wall while moving against it
if ((key_left && place_meeting(x-1, y, obj_solid_parent)) || (key_right && place_meeting(x+1, y, obj_solid_parent)) && yspeed >= 0) {
	if (!jumping) {
		canjump = true;
		jumping = false;
		yspeed += yspeed * (1-wallfric);
		if (yspeed > yspeed_term_wall) {
			yspeed = yspeed_term_wall;	
		}
	}
}

// Move until colliding with a wall vertically
if (place_meeting(x, y+yspeed, obj_solid_parent)) {
	while(!place_meeting(x, y+sign(yspeed), obj_solid_parent)) {
		y += sign(yspeed);	
	}
	yspeed = 0;
}
y += yspeed;