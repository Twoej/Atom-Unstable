extends AnimatedSprite2D

var current_animation := "still"


func _on_animation_changed():
	current_animation = self.animation

func get_current_animation():
	return current_animation

func flip_sprite(direction):
	if direction == 1:
		self.flip_h = false
		self.offset.x = 0
	elif direction == -1:
		self.flip_h = true
		self.offset.x = 3

func _process(delta):
	pass
