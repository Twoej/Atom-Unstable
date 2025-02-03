extends Node2D

@export var main: PackedScene

func _ready():
	$SFXEel.play()

func _on_timer_timeout():
	get_tree().change_scene_to_packed(main)
