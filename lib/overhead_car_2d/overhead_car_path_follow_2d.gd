class_name OverheadCarPathFollow2D extends Node


@export var min_target_distance := 500


var path: Path2D = null


signal path_follow_ready(follow: OverheadCarPathFollow2D)


var path_points := []
var path_index := 0


func _ready():
	path = get_parent()
	path_points = path.curve.get_baked_points()
	path_follow_ready.emit(self)


func provide_input(car: OverheadCarBody2D):
	var input := car._car_input
	input.acceleration = 1.0
	
	var target: Vector2 = path_points[path_index]
	while car.position.distance_to(target) < min_target_distance:
		path_index = wrapi(path_index + 1, 0, path_points.size())
		target = path_points[path_index]
	
	var target_vector := target - car.position
	var target_angle := normalize_angle(target_vector.angle())
	var normal_rotation = normalize_angle(car.rotation)
	
	var steering_angle = angle_difference(normal_rotation, target_angle)
	input.steering = steering_angle / deg_to_rad(car.max_steering_degrees)


func normalize_angle(angle: float) -> float:
	angle = fmod(angle, 2*PI)
	if angle < 0:
		angle += 2*PI
	return angle


func angle_difference(from: float, to: float) -> float:
	return fposmod(to - from + PI, PI*2) - PI
