# OverheadCarBody2D is the recipe described here adapted for Godot 4.
# http://kidscancode.org/godot_recipes/3.x/2d/car_steering/
# https://engineeringdotnet.blogspot.com/2010/04/simple-2d-car-physics-in-games.html
#
# Extend OverheadCarBody2D and override _get_input(input: CarInput) to control.
class_name OverheadCarBody2D extends CharacterBody2D


@export var max_engine_power = 1200  # Forward acceleration force.
@export var max_speed_reverse = 250
@export var max_steering_degrees = 15  # Amount that front wheel turns, in degrees
@export var friction = 0.9
@export var drag = 0.0015
@export var brakes = 4.0
@export var slip_speed = 400  # Speed where traction is reduced
@export var traction_fast = 0.1  # High-speed traction
@export var traction_slow = 0.7  # Low-speed traction
@export var wheel_base = 70  # Distance from front to rear wheel


class CarInput:
	var steering := 0.0      # -1.0 (left) to 1.0 (right)
	var acceleration := 0.0  # -1.0 (reverse) to 1.0 (accelerate)
	var braking := false     # True if brakes are engaged


var _car_input := CarInput.new()
var _path_follow: OverheadCarPathFollow2D = null


func _init():
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING


func _ready():
	_connect_car_areas(get_tree().root)


func _provide_input(_input: CarInput):
	pass


func _physics_process(delta):
	if _path_follow:
		_path_follow.provide_input(self)
	else:
		_provide_input(_car_input)
	_car_input.steering = clamp(_car_input.steering, -1.0, 1.0)
	_car_input.acceleration = clamp(_car_input.acceleration, -1.0, 1.0)
	
	# Base steering wheel angle and acceleration
	var steer_angle = _car_input.steering * deg_to_rad(max_steering_degrees)
	var acceleration = _car_input.acceleration * transform.x * max_engine_power

	# Apply friction
	if velocity.length() < 5:
		velocity = Vector2.ZERO
	var friction_force = velocity * -friction
	var drag_force = velocity * velocity.length() * -drag
	if velocity.length() < 100:
		friction_force *= 3
	acceleration += drag_force + friction_force
	if _car_input.braking:
		acceleration += velocity * -brakes
	
	# Calculate steering
	var rear_wheel = position - transform.x * wheel_base / 2.0 + velocity * delta
	var front_wheel = position + transform.x * wheel_base / 2.0 + velocity.rotated(steer_angle) * delta
	var new_heading = (front_wheel - rear_wheel).normalized()
	var traction = traction_slow
	if velocity.length() > slip_speed:
		traction = traction_fast
	var d = new_heading.dot(velocity.normalized())
	if d > 0:
		velocity = velocity.lerp(new_heading * velocity.length(), traction)
	if d < 0:
		velocity = -new_heading * min(velocity.length(), max_speed_reverse)
	
	# Update the physics engine
	rotation = new_heading.angle()
	velocity += acceleration * delta
	move_and_slide()
	_do_update_output(_car_input.acceleration)


func _update_output(_speed_factor: float, _acceleration_factor: float):
	pass


var _highest_measured_speed = 0


func _do_update_output(acceleration):
	var speed = velocity.length()
	if speed > _highest_measured_speed:
		_highest_measured_speed = speed
	var speed_factor = speed / _highest_measured_speed if _highest_measured_speed > 0 else 0
	_update_output(speed_factor, abs(acceleration))


func _connect_car_areas(node: Node):
	for child in node.get_children(true):
		if child is OverheadCarArea2D:
			child.car_body_entered.connect(_on_overhead_car_area_2d_car_body_entered)
			child.car_body_exited.connect(_on_overhead_car_area_2d_car_body_exited)
		_connect_car_areas(child)


func _on_overhead_car_area_2d_car_body_entered(_body, area: OverheadCarArea2D):
	friction += area.friction
	drag += area.drag


func _on_overhead_car_area_2d_car_body_exited(_body, area: OverheadCarArea2D):
	friction -= area.friction
	drag -= area.drag


func _on_overhead_car_path_follow_2d_path_follow_ready(follow: OverheadCarPathFollow2D):
	_path_follow = follow
