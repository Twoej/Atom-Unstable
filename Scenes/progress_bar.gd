extends Node2D

var paused = false

func _process(_delta):
	if !$GameTime.is_paused():
		$ProgressBar.set_value(((300 - $GameTime.get_time_left()) / 300) * 100)

func pause(pause: bool):
	$GameTime.set_paused(pause)
