extends Area2D

var direction


func _process(delta):
	position += direction * 400 * delta


func _on_area_entered(area):
	if area.is_in_group("BulletDestroy"):
		self.queue_free()
	if area.is_in_group("Enemy"):
		area.queue_free()
