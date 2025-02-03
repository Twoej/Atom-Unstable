extends Node2D

func _ready():
	$SFXEel.play()

func _on_quit_pressed():
	get_tree().quit()


func _on_try_again_pressed():
	get_tree().reload_current_scene()
