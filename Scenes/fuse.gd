extends PickUpItem

func _fuse_process(_delta):
	if held:
		self.set_scale(Vector2(3, 3))
	else:
		self.set_scale(Vector2(2, 2))

func _fuse_ready():
	$Sprite2DShadow.set_position(Vector2(8, 5))
