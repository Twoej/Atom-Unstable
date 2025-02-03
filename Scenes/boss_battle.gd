extends Node2D

var time_elapsed := 0.0
var arrived := false
var direction := -1
var attack_index := 3

var attacking := false

signal attack()
signal attack_end()
signal attack_player()
signal attack_beam()

func _ready():
	attack.connect(get_parent()._on_eel_encounter_attack)
	attack_end.connect(get_parent()._on_eel_encounter_attack_end)
	attack_player.connect(get_parent().get_node("Player")._on_eel_attack)
	attack_beam.connect(get_parent()._on_eel_attack_beam)

func _process(delta):
	if !arrived:
		position = Vector2(2181, 454).lerp(Vector2(1634, 454), time_elapsed)
		time_elapsed += delta * 0.3
		if time_elapsed > 1:
			time_elapsed = 1
			arrived = true
	elif $AnimatedSprite2D.get_animation() == "move":
		position.y += direction * 40 * delta
		if position.y < 300 or position.y > 750:
			direction = -direction
	elif $AnimatedSprite2D.get_animation() == "attack" and !attacking:
		if attack_index == 0:
			$ShockTimer.start()
			attack.emit()
			$SFXEelAttack.play()
			attacking = true
		elif attack_index == 1 and !attacking:
			$ShockTimer.start()
			attack_player.emit()
			attacking = true
	elif $AttackSprite.is_visible() and !attacking:
		if $AttackSprite.get_frame() == 5 and $BeamRemove.is_stopped():
			attack_beam.emit()
			$SFXEelAttackBeamLand.play()
			attacking = true
			$BeamRemove.start()
	

func _on_attack_delay_timeout():
	attack_index = randi_range(0, 2)
	


func _on_animated_sprite_2d_animation_looped():
	if attack_index == 0 or attack_index == 1:
		$AnimatedSprite2D.play("attack")
	elif attack_index == 2:
		$AnimatedSprite2D.play("idle")
		$AttackSprite.set_visible(true)
		$AttackSprite.play("default")
		$SFXEelAttackBeam.play()


func _on_shock_timer_timeout():
	if attack_index == 0:
		attack_end.emit()
		attacking = false
		$AnimatedSprite2D.play("move")
		attack_index = 3
	elif attack_index == 1:
		$AnimatedSprite2D.play("move")
		attacking = false
		attack_index = 3


func _on_beam_remove_timeout():
	$AttackSprite.stop()
	$AttackSprite.set_frame(0)
	$AttackSprite.set_visible(false)
	$AnimatedSprite2D.play("move")
	attacking = false
	attack_index = 3
