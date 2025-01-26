extends Node2D

@export var game_over_tscn: PackedScene

var death_timer_started = false
var time_since_last_flash = 16

func _process(_delta):
	if death_timer_started:
		$DeathWarning/CountDown.set_text(str(int($DeathWarning/DeathTimer.get_time_left())))
		if time_since_last_flash > 20 and $DeathWarning/DeathTimer.get_time_left() > 4.5:
			time_since_last_flash = 0
			if $DeathWarning.is_visible():
				$DeathWarning.set_visible(false)
			else:
				$DeathWarning.set_visible(true)
		elif $DeathWarning/DeathTimer.get_time_left() <= 4:
			$DeathWarning.set_visible(true)
		time_since_last_flash += 1

func _interact_control(area):
	if area.is_in_group("Player"):
		$Controls/InteractControl.set_visible(true)

func _interact_control_fade(area):
	if area.is_in_group("Player"):
		$Controls/InteractControl.set_visible(false)

func _on_oxygen_down():
	$DeathWarning/DeathTimer.start()
	death_timer_started = true


func _on_death_timer_timeout():
	$DeathWarning.set_visible(false)
	death_timer_started = false
	$Spaceship.queue_free()
	var game_over_screen = game_over_tscn.instantiate()
	self.add_child(game_over_screen)
