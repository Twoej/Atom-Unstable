extends Minigame

@export var electron_tscn: PackedScene

var speed := 200.0
var direction := Vector2.RIGHT

var markers = []
var electrons = []
var electron_count := 0
var electron_complete_count := 0

var path_complete := false

func _process(delta):
	if !path_complete:
		$Path.set_position($Path.get_position() + (direction * speed * delta))
	if Input.is_action_just_pressed("jump") and direction != Vector2.DOWN:
		direction = Vector2.UP
	if Input.is_action_just_pressed("move_down") and direction != Vector2.UP:
		direction = Vector2.DOWN
	if Input.is_action_just_pressed("move_left")and direction != Vector2.RIGHT:
		direction = Vector2.LEFT
	if Input.is_action_just_pressed("move_right")and direction != Vector2.LEFT:
		direction = Vector2.RIGHT
	if path_complete:
		for i in electrons.size():
			if (electrons[i].get_position() - electrons[i].next_position).length() < 5:
				if !((electrons[i].next_position_index + 1) >= markers.size()):
					electrons[i].next_position = markers[electrons[i].next_position_index + 1]
					electrons[i].next_position_index += 1
				else:
					if electrons[i].is_visible():
						electrons[i].set_visible(false)
						electron_complete_count += 1
	if (electron_complete_count == electron_count) and path_complete:
		self.queue_free()
	


func _on_save_marker_timeout():
	markers.append($Path.get_position())


func _on_summon_electron_timeout():
	var electron = electron_tscn.instantiate()
	electrons.append(electron)
	electrons[electron_count].position = Vector2(-221, -180)
	for i in electrons.size():
		electrons[i].next_position = markers[electrons.size() - i - 1]
		electrons[i].next_position_index = (electrons.size() - i - 1)
	self.add_child(electrons[electron_count])
	electron_count += 1
	


func _on_boundary_area_entered(area):
	if area.is_in_group("Path"):
		for i in electrons.size():
			electrons[i].queue_free()
		electrons.clear()
		markers.clear()
		$Path.set_position(Vector2(-221, -180))
		direction = Vector2.RIGHT
		electron_count = 0


func _on_win_area_entered(area):
	if area.is_in_group("Path"):
		$SaveMarker.stop()
		$SummonElectron.stop()
		markers.append($Path.get_position())
		path_complete = true
		$Path.queue_free()
		minigame_complete.emit()
