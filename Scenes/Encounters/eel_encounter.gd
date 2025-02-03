extends Node2D

var time_elapsed := 0.0
signal attack()
signal attack_end()

var leaving := false

func _ready():
	$SFXEel.play()
	$AnimatedSprite2D.play("move")
	attack.connect(get_parent()._on_eel_encounter_attack)
	attack_end.connect(get_parent()._on_eel_encounter_attack_end)

func _process(delta):
	if !leaving:
		position = Vector2(2181, 454).lerp(Vector2(1634, 454), time_elapsed)
		time_elapsed += delta * 0.5
		if time_elapsed > 1:
			time_elapsed = 1
	else:
		position = Vector2(1634, 454).lerp(Vector2(2181, 454), time_elapsed)
		time_elapsed += delta * 0.6
		if time_elapsed > 1:
			time_elapsed = 1
	if (position == Vector2(2181, 454)) and leaving:
		self.queue_free()


func _on_animated_sprite_2d_animation_looped():
	if ($AnimatedSprite2D.get_animation() == "move") and (position == Vector2(1634, 454)) and !leaving:
		$AnimatedSprite2D.play("attack")
		attack.emit()
		$SFXEelAttack.play()
		$AttackTimer.start()


func _on_attack_timer_timeout():
	$AnimatedSprite2D.play("idle")
	attack_end.emit()


func _on_animated_sprite_2d_animation_finished():
	$AnimatedSprite2D.set_flip_h(true)
	$AnimatedSprite2D.play("move")
	leaving = true
	time_elapsed = 0
