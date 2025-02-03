extends Node2D

var paused = false

signal boss_time()
signal win()

var time_left: float

var boss := false

func _process(_delta):
	if !$GameTime.is_paused() and !boss:
		$TextureProgressBar.set_value(((150 - $GameTime.get_time_left()) / 150) * 100)
	elif !$GameTime.is_paused() and boss:
		$TextureProgressBar.set_value(((60 - $GameTime.get_time_left()) / 60) * 100)
	time_left = $GameTime.get_time_left()

func pause(pause: bool):
	$GameTime.set_paused(pause)


func _on_game_time_timeout():
	if !boss:
		boss_time.emit()
		$GameTime.start(60)
		boss = true
	else:
		win.emit()
		
func get_time_left():
	return time_left
