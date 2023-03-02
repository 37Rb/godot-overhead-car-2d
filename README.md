# Overhead Car Body 2D for Godot 4

Adds a class called OverheadCar2D to Godot 4 that implements reasonbly good car physics. It's the car solution described [here](http://kidscancode.org/godot_recipes/3.x/2d/car_steering/) and [here](https://engineeringdotnet.blogspot.com/2010/04/simple-2d-car-physics-in-games.html) but adapted for Godot 4 and shared so it can be easily reused. It extends [CharacterBody2D](https://docs.godotengine.org/en/stable/classes/class_characterbody2d.html).

## How To Use It

OverheadCar2D is [registered as a named class](https://docs.godotengine.org/en/4.0/tutorials/scripting/gdscript/gdscript_basics.html#registering-named-classes) so you can add a new OverheadCar2D node from the Create New Node dialog. You'll need to extend the OverheadCar2D class to use it. Make sure you choose Extend Script not Attach Script.

Use the `_get_input(input)` callback to connect your game's input to the car physics engine. There are 3 fields on the input object used to control the car.

```gdscript
class CarInput:
	var steering := 0.0      # -1.0 (left) to 1.0 (right)
	var acceleration := 0.0  # -1.0 (reverse) to 1.0 (accelerate)
	var braking := false     # True if brakes are engaged
```

Here is an example `_get_input(input)` callback that works with a joystick and buttons. Button presses override joystick motion in this example.

```gdscript
extends OverheadCar2D

func _get_input(input):
	input.steering = Input.get_axis("axis_left", "axis_right")
	input.acceleration = Input.get_axis("axis_down", "axis_up")
	if Input.is_action_pressed("accelerate"):
		input.acceleration = 1.0
	if Input.is_action_pressed("reverse"):
		input.acceleration = -1.0
	if Input.is_action_pressed("steer_left"):
		input.steering = -1.0
	if Input.is_action_pressed("steer_right"):
		input.steering = 1.0
	input.braking = Input.is_action_pressed("brake")
```

There are a bunch of export variables available in the inspector and can be used to control the car dynamics.