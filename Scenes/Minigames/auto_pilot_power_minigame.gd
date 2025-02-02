extends Minigame

@export var dial_tscn: PackedScene

var rows_complete := 0:
	set(value):
		rows_complete = value
		if value < 3:
			var dial = dial_tscn.instantiate()
			dials.append(dial)
			self.add_child(dials[value])
			dials[value].set_position(starting_pos[value])
		elif value == 3:
			$WinTimer.start()
var current_row_complete = false

var in_green := false

var dials: Array = []
var starting_pos: Array = [Vector2(0, -112), Vector2(0, -4), Vector2(0, 106)]

func _minigame_ready():
	var dial = dial_tscn.instantiate()
	dials.append(dial)
	self.add_child(dials[0])
	dials[0].set_position(starting_pos[0])
	

func _process(_delta):
	if Input.is_action_just_pressed("click") or Input.is_action_just_pressed("interact") or Input.is_action_just_pressed("jump"):
		if in_green and rows_complete < 3:
			dials[rows_complete].set_velocity(0)
			rows_complete += 1

func _on_green_area_entered(area):
	if area.is_in_group("Dial"):
		in_green = true


func _on_green_area_exited(area):
	in_green = false


func _on_win_timer_timeout():
	minigame_complete.emit()
	self.queue_free()
