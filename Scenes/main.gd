extends Node2D

@export var game_over_tscn: PackedScene

var death_timer_started = false
var time_since_last_flash = 16
var death_cause: String = "none"
var delayed_dying := false

func _process(_delta):
	if death_timer_started:
		$DeathWarning/CountDown.set_text(str(int($DeathWarning/DeathTimer.get_time_left())))
		if time_since_last_flash > 13 and $DeathWarning/DeathTimer.get_time_left() > 4.5:
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
	if death_cause == "none":
		death_cause = "oxygen"
		$DeathWarning/PowerIndicator.set_text("Power Oxygen!!")
		$DeathWarning/DeathTimer.start(5)
		death_timer_started = true
	else:
		delayed_dying = true


func _on_death_timer_timeout():
	$ProgressBar.pause(true)
	death_cause = "none"
	$DeathWarning.set_visible(false)
	death_timer_started = false
	$Spaceship.queue_free()
	var game_over_screen = game_over_tscn.instantiate()
	self.add_child(game_over_screen)

func _on_oxygen_powered():
	if death_cause == "oxygen":
		death_cause = "none"
		$DeathWarning.set_visible(false)
		death_timer_started = false
		$DeathWarning/DeathTimer.stop()
		time_since_last_flash = 16
		if delayed_dying:
			delayed_dying = false
			_on_temperature_down()
	elif (death_cause == "temp") and delayed_dying:
		delayed_dying = false


func _on_temperature_down():
	if death_cause == "none":
		death_cause = "temp"
		$DeathWarning/PowerIndicator.set_text("Power Temperature System!!")
		$DeathWarning/DeathTimer.start(10)
		death_timer_started = true
	else:
		delayed_dying = true

func _on_temperature_powered():
	if death_cause == "temp":
		death_cause = "none"
		$DeathWarning.set_visible(false)
		death_timer_started = false
		$DeathWarning/DeathTimer.stop()
		time_since_last_flash = 16
		if delayed_dying:
			delayed_dying = false
			_on_oxygen_down()
	elif (death_cause == "oxygen") and delayed_dying:
		delayed_dying = false
		
		

func _on_engine_down():
	$ProgressBar.pause(true)

func _on_engine_powered():
	$ProgressBar.pause(false)
