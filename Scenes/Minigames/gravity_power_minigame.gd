extends Minigame


func _on_button_pressed():
	minigame_complete.emit()
	self.queue_free()
