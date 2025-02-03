extends Node2D

@export var game_over_tscn: PackedScene
@export var win_screen_tscn: PackedScene

var death_timer_started = false
var time_since_last_flash = 16
var death_cause: String = "none"
var delayed_dying := false

@export var encounters: Array[PackedScene]

@export var boss_battle_tscn: PackedScene

func _ready():
	$MusicMain.play()

func _process(delta):
	if death_timer_started and !$SFXAlarm.is_playing():
		$SFXAlarm.play()
	if death_timer_started:
		$UILayer/DeathWarning/CountDown.set_text(str(int($UILayer/DeathWarning/DeathTimer.get_time_left())))
		if time_since_last_flash > 13 and $UILayer/DeathWarning/DeathTimer.get_time_left() > 14:
			time_since_last_flash = 0
			if $UILayer/DeathWarning.is_visible():
				$UILayer/DeathWarning.set_visible(false)
			else:
				$UILayer/DeathWarning.set_visible(true)
		elif $UILayer/DeathWarning/DeathTimer.get_time_left() <= 14:
			$UILayer/DeathWarning.set_visible(true)
		time_since_last_flash += 1
	if has_node("Spaceship"):
		if $Spaceship/Player.has_gun:
			$UILayer/Controls/ShootControl.set_visible(true)
		else:
			$UILayer/Controls/ShootControl.set_visible(false)
	if $VisualDetail.get_position().x > -100:
		$VisualDetail.set_position(Vector2($VisualDetail.get_position().x - (50 * delta), $VisualDetail.get_position().y))

func _interact_control(area):
	if area.is_in_group("Player"):
		$UILayer/Controls/InteractControl.set_visible(true)

func _interact_control_fade(area):
	if area.is_in_group("Player"):
		$UILayer/Controls/InteractControl.set_visible(false)

func _on_oxygen_down():
	if death_cause == "none":
		death_cause = "oxygen"
		$UILayer/DeathWarning/PowerIndicator.set_text("Power Oxygen!!")
		$UILayer/DeathWarning/DeathTimer.start(15.5)
		death_timer_started = true
	else:
		delayed_dying = true
		


func _on_death_timer_timeout():
	$ProgressBar.pause(true)
	death_cause = "none"
	$UILayer/DeathWarning.set_visible(false)
	death_timer_started = false
	$Spaceship.queue_free()
	var game_over_screen = game_over_tscn.instantiate()
	self.add_child(game_over_screen)
	$MusicMain.stop()
	$MusicBoss.stop()
	$MusicBoss2.stop()

func _on_oxygen_powered():
	if death_cause == "oxygen":
		death_cause = "none"
		$UILayer/DeathWarning.set_visible(false)
		death_timer_started = false
		$UILayer/DeathWarning/DeathTimer.stop()
		time_since_last_flash = 16
		if delayed_dying:
			delayed_dying = false
			_on_temperature_down()
	elif (death_cause == "temp") and delayed_dying:
		delayed_dying = false


func _on_temperature_down():
	if death_cause == "none":
		death_cause = "temp"
		$UILayer/DeathWarning/PowerIndicator.set_text("Power Temperature System!!")
		$UILayer/DeathWarning/DeathTimer.start(15.5)
		death_timer_started = true
	else:
		delayed_dying = true

func _on_temperature_powered():
	if death_cause == "temp":
		death_cause = "none"
		$UILayer/DeathWarning.set_visible(false)
		death_timer_started = false
		$UILayer/DeathWarning/DeathTimer.stop()
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


func _on_random_encounter_timer_timeout():
	if $ProgressBar.get_time_left() > 25:
		$RandomEncounterTimer.start(randi_range(25, 70))
		var encounter = encounters[randi_range(0, 3)].instantiate()
		if has_node("Spaceship"):
			$Spaceship.add_child(encounter)


func _on_visual_detail_timer_timeout():
	$VisualDetailTimer.start(randi_range(39, 70))
	$VisualDetail.set_position(Vector2(2100, randi_range(300, 800)))
	$VisualDetail.play(str(randi_range(0, 3)))


func _on_progress_bar_boss_time():
	$RandomEncounterTimer.stop()
	$UILayer/BossLabel.set_visible(true)
	var boss = boss_battle_tscn.instantiate()
	$Spaceship.add_child(boss)
	$Spaceship.systems_reset()
	$MusicMain.stop()
	$MusicChangeTimer.start()


func _on_progress_bar_win():
	$ProgressBar.pause(true)
	death_cause = "none"
	$UILayer/DeathWarning.set_visible(false)
	death_timer_started = false
	$Spaceship.queue_free()
	var win_screen = win_screen_tscn.instantiate()
	self.add_child(win_screen)


func _on_music_change_timer_timeout():
	$MusicBoss.play()


func _on_music_boss_finished():
	$MusicBoss2.play()


func _on_music_boss_2_finished():
	$MusicBoss2.play()


func _on_music_main_finished():
	$MusicMain.play()
