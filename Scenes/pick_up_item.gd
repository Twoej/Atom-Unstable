class_name PickUpItem extends Area2D

var mouse_inside := false
var out_of_bounds := false
var prev_position: Vector2

func _ready():
	$Sprite2DShadow.set_position(Vector2(22, 7))

func _process(_delta):
	if mouse_inside and Input.is_action_pressed("Click") and !out_of_bounds:
		self.set_position(get_parent().get_local_mouse_position())
	if out_of_bounds:
		var setback = (self.get_position() - prev_position).normalized() * 15
		self.set_position(self.get_position() - setback)


func _on_mouse_entered():
	mouse_inside = true


func _on_mouse_exited():
	mouse_inside = false


func _on_area_entered(area):
	if area.is_in_group("Minigame"):
		out_of_bounds = true


func _on_pos_timer_timeout():
	prev_position = self.get_position()


func _on_area_exited(area):
	if area.is_in_group("Minigame"):
		out_of_bounds = false
