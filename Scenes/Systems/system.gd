class_name System extends Area2D

@export var power_max: float = 100
@onready var power_remaining: float = power_max
@export var power_loss_rate: float = 10

@export var power_minigame_tscn: PackedScene

var prev_power_remaining: float

@onready var main = get_node("/root/Main")

var player_in_area = false

func _ready():
	#Connecting to display HUD indicating interact button
	self.area_entered.connect(main._interact_control)
	self.area_exited.connect(main._interact_control_fade)
	#Connecting to track when player is in area
	self.area_entered.connect(self._on_area_entered)
	self.area_exited.connect(self._on_area_exited)
	
	var anim_start_frame = randi_range(0, 8)
	$SystemSprite.set_frame(anim_start_frame)
	$SystemSprite.play()
	
	_connect_signals()

func _process(delta):
	_decrease_power(delta)
	#If player interacts while in area, trigger interact function
	if Input.is_action_just_pressed("interact") and player_in_area:
		_interacted()
	if power_remaining == 0 and prev_power_remaining != 0:
		_power_depleted()
	prev_power_remaining = power_remaining

#General function that runs every frame to decrease power
func _decrease_power(delta):
	if self.power_remaining > 0:
		self.power_remaining -= power_loss_rate * delta
	if self.power_remaining < 0:
		power_remaining = 0
	#Updates the label showing the current power remaining
	if find_child("PowerRemaining") != null:
		$PowerRemaining.text = str(int(power_remaining))

func _on_area_entered(area):
	if area.is_in_group("Player"):
		player_in_area = true

func _on_area_exited(area):
	if area.is_in_group("Player"):
		player_in_area = false
	
func _interacted():
	var minigame = power_minigame_tscn.instantiate()
	main.get_child(0).get_child(0).add_child(minigame)
	minigame.set_sibling_system(self)
	minigame.set_position(Vector2(960, 540))

func _power_depleted():
	pass

func _power_replenished():
	pass
	
func _connect_signals():
	pass

func _on_minigame_complete():
	power_remaining = power_max
	_power_replenished()
