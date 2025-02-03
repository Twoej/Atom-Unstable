extends Node2D

func _ready():
	$MusicWin.play()


func _on_music_win_finished():
	$MusicWin.play()
	
	
func _on_play_pressed():
	get_tree().reload_current_scene()


func _on_quit_pressed():
	get_tree().quit()
