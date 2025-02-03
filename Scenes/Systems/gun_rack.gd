extends System

signal give_gun(gun_rack: System)
var player: CharacterBody2D

func _connect_signals():
	player = get_node("/root/Main/Spaceship/Player")
	give_gun.connect(player._on_gun_rack_give_gun)
	$SystemSprite.pause()

func _interacted():
	give_gun.emit(self)
	$SystemSprite.play("empty")


func _on_player_gun_returned():
	$SystemSprite.play("default")
	$SystemSprite.pause()
