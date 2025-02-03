extends Node2D

@export var face: PackedScene

func _ready():
	$MusicTitle.play()

func _on_play_pressed():
	get_tree().change_scene_to_packed(face)


func _on_quit_pressed():
	get_tree().quit()


func _on_music_title_finished():
	$MusicTitle.play()
