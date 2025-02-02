extends PickUpItem

func _block_ready():
	origin_point = Vector2(270, 0)
	self.set_position(Vector2(randi_range(174, 382), randi_range(-157, 190)))
	held_unheld.connect(get_parent()._on_block_held_unheld)

func _block_process(_delta):
	if held:
		self.set_scale(Vector2(2, 2))
	else:
		self.set_scale(Vector2(1, 1))
