extends Node2D

var speed := 230.0
var next_position: Vector2
var next_position_index: int
var position_count := 0

func _process(delta):
	var direction = (next_position - get_position()).normalized()
	set_position(get_position() + (direction * speed * delta))

func set_speed(value):
	speed = value
