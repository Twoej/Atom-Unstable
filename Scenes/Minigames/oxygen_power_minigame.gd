extends Minigame

var switch_state: Array = [false, false, false]

func _minigame_ready():
	$Top.pressed.connect(_toggle_switch.bind(0))
	$Middle.pressed.connect(_toggle_switch.bind(1))
	$Bottom.pressed.connect(_toggle_switch.bind(2))

func _toggle_switch(i: int):
	switch_state[i] = !switch_state[i]
	var background_state: Array = [
		(switch_state[2] and !switch_state[1]) or (!switch_state[0] and switch_state[1]),
		(!switch_state[1] and switch_state[2]) or (switch_state[0] and switch_state[1]),
		(switch_state[2] and switch_state[1]) or (switch_state[0] and !switch_state[1]),
	]
	var background_state_int: int
	for j in 3:
		background_state_int += ((int)(background_state[2 - j])) << j
	$Background.set_frame(background_state_int)
	
	if background_state_int == 3:
		minigame_complete.emit()
		$WinTimer.start()


func _on_win_timer_timeout():
	self.queue_free()
