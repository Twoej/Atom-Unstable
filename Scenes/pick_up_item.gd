class_name PickUpItem extends Area2D

var mouse_inside := false
var out_of_bounds := false
var held := false:
	set(value):
		held = value
		held_change.emit(value)
		held_unheld.emit(value, self)
var out_of_play := false

var direction: Vector2
var speed: float

var origin_point := Vector2(20, 0)

signal mouse_in_out(item: PickUpItem, in_out: bool)
signal held_change(held: bool)
signal held_unheld(held: bool, item: PickUpItem)

func _ready():
	$Sprite2DShadow.set_position($Sprite2DShadow.get_position() + Vector2(22, 7))
	
	self.area_entered.connect(self._on_area_entered)
	self.area_exited.connect(self._on_area_exited)
	self.mouse_entered.connect(self._on_mouse_entered)
	self.mouse_exited.connect(self._on_mouse_exited)
	
	self.mouse_in_out.connect(get_parent()._on_pick_up_item_mouse_in_out)
	self.held_change.connect(get_parent()._on_pick_up_item_held_change)
	
	self.set_position(Vector2(randi_range(-30, 285), randi_range(-215, 215)))
	
	direction = Vector2(randf() - randf(), randf() - randf()).normalized()
	speed = randf_range(10, 100)
	
	_fuse_ready()
	
	_block_ready()
	
	

func _process(delta):
	if Input.is_action_just_released("click"):
		held = false
	if (held or mouse_inside and Input.is_action_pressed("click")) and !out_of_bounds:
		self.set_position(get_parent().get_local_mouse_position())
		held = true
	if out_of_bounds and held:
		var setback = ((self.get_position() - origin_point).normalized() * 15)
		self.set_position(self.get_position() - setback)
	if out_of_play and !held:
		var distance_mod = (self.get_position() - origin_point).length()/50
		if (self.get_position() - origin_point).length() < 450:
			distance_mod = 2
		var setback = ((self.get_position() - origin_point).normalized() * speed * delta * distance_mod)
		self.set_position(self.get_position() - setback)
	if !held and !out_of_play:
		self.set_position(self.get_position() + (direction * speed * delta))
		if randi_range(0, 500) == 1:
			direction = Vector2(randf() - randf(), randf() - randf()).normalized()
	
	_fuse_process(delta)
	
	_block_process(delta)


func _on_mouse_entered():
	mouse_in_out.emit(self, true)


func _on_mouse_exited():
	mouse_inside = false
	mouse_in_out.emit(self, false)

func _on_area_entered(area):
	if area.is_in_group("Minigame"):
		out_of_bounds = true
		if !held:
			direction = -direction
	if area.is_in_group("MinigameItem"):
		direction = -direction
		out_of_play = true


func _on_area_exited(area):
	if area.is_in_group("Minigame"):
		held = false
		out_of_bounds = false
	if area.is_in_group("MinigameItem"):
		out_of_play = false

func set_mouse_inside(mouse_inside):
	self.mouse_inside = mouse_inside
	
func _fuse_process(delta):
	pass

func _fuse_ready():
	pass

func _block_ready():
	pass

func _block_process(delta):
	pass
