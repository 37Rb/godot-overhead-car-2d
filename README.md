# Overhead Car Body 2D for Godot 4

Adds a class called OverheadCar2D to Godot 4 that implements reasonably good car physics. It's the car solution described [here](http://kidscancode.org/godot_recipes/3.x/2d/car_steering/) and [here](https://engineeringdotnet.blogspot.com/2010/04/simple-2d-car-physics-in-games.html) but adapted for Godot 4 and shared so it can be easily reused. It extends [CharacterBody2D](https://docs.godotengine.org/en/stable/classes/class_characterbody2d.html).

## How To Use It

OverheadCar2D is [registered as a named class](https://docs.godotengine.org/en/4.0/tutorials/scripting/gdscript/gdscript_basics.html#registering-named-classes) so you can add a new OverheadCar2D node from the Create New Node dialog. You'll need to extend the OverheadCar2D class to use it. Make sure you choose Extend Script not Attach Script.

### The _provide_input Callback

Use the `_provide_input` callback to connect your game's input to the car physics engine. There are 3 fields on the input object used to control the car.

```gdscript
class CarInput:
	var steering := 0.0      # -1.0 (left) to 1.0 (right)
	var acceleration := 0.0  # -1.0 (reverse) to 1.0 (accelerate)
	var braking := false     # True if brakes are engaged
```

Here is an example `_provide_input` that works with a joystick and buttons. Button presses override joystick motion in this example.

```gdscript
extends OverheadCar2D

func _provide_input(input: CarInput):
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

Just like any Godot physics body, you'll need to add a sprite and a collision shape as children of the OverheadCar2D so you have something to drive around and crash.

### The _update_output Callback

Use the `_update_output` callback to update car outputs based on the physics state. You might change the engine sound or animate trailing smoke based on speed and acceleration. Each argument is a proportion [0, 1] of the max for convenience. For example, if you have an AudioStreamPlayer node called EngineSound:

```gdscript
func _update_output(speed_factor: float, acceleration_factor: float):
	var volume_range = max_engine_volume - min_engine_volume
	$EngineSound.volume_db = min_engine_volume + acceleration_factor * volume_range
	var pitch_range = max_engine_pitch - min_engine_pitch
	$EngineSound.pitch_scale = min_engine_pitch + speed_factor * pitch_range
```

Of course, the normal physics state variables like position and velocity are available if you need more detail but the given speed and acceleration factors are convenient to use as simple multipliers.

## Installation

The plan is to make it available on the [Godot Asset Library](https://godotengine.org/asset-library/asset) but I ran into an issue getting it to work that way. In the mean time you can just copy the script into your project as a work around.