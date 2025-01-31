extends Minigame

var switch_state := [false, false, false]

func _minigame_ready():
	$Switch1/Button.pressed.connect(_toggle_switch.bind($Switch1, 0))
	$Switch2/Button.pressed.connect(_toggle_switch.bind($Switch2, 1))
	$Switch3/Button.pressed.connect(_toggle_switch.bind($Switch3, 2))
	

func _toggle_switch(switch: AnimatedSprite2D, i: int):
	if switch.get_animation() == "off":
		switch.play("on")
		switch_state[i] = true
	else:
		switch.play("off")
		switch_state[i] = false
	_switch_state_changed()

func _on_win_timer_timeout():
	self.queue_free()

func _switch_state_changed():
	if switch_state == [true, true, true]:
		minigame_complete.emit()
		$WinTimer.start()
