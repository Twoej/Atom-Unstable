class_name System extends Area2D

@export var power_max: float = 100
@onready var power_remaining: float = power_max
@export var power_loss_rate: float = 10

@export var power_minigame_tscn: PackedScene
var minigame_active := false

var prev_power_remaining: float

@onready var main = get_node("/root/Main")

var player_in_area = false

var boarder_position: Vector2
var boarded := false

var eel := false

var zeroed := false

func _ready():
	#Connecting to display HUD indicating interact button
	self.area_entered.connect(main._interact_control)
	self.area_exited.connect(main._interact_control_fade)
	#Connecting to track when player is in area
	self.area_entered.connect(self._on_area_entered)
	self.area_exited.connect(self._on_area_exited)
	
	$BatteryFlashing.timeout.connect(self._on_battery_flashing_timeout)
	
	var anim_start_frame = randi_range(0, 8)
	$SystemSprite.set_frame(anim_start_frame)
	$SystemSprite.play()
	
	_connect_signals()

func _process(delta):
	_decrease_power(delta)
	#If player interacts while in area, trigger interact function
	if Input.is_action_just_pressed("interact") and player_in_area and !minigame_active:
		_interacted()
	if power_remaining == 0 and prev_power_remaining != 0:
		_power_depleted()
		$SystemSprite.pause()
	prev_power_remaining = power_remaining
	
	if !has_node("Boarder") and !boarded:
		boarded = false
	if has_node("Boarder") and !boarded:
		$Boarder.set_position(boarder_position)
		$Boarder/AnimatedSprite2D.play("default")
		boarded = true
	if has_node("Boarded"):
		if boarded and !$Boarder/AnimatedSprite2D.is_playing() and $Boarder/AnimatedSprite2D.get_animation() == "default":
			$Boarder/AnimatedSprite2D.play("pull_energy")
	if boarded or eel:
		_decrease_power(delta)

#General function that runs every frame to decrease power
func _decrease_power(delta):
	if self.power_remaining > 0:
		self.power_remaining -= power_loss_rate * delta
	if self.power_remaining < 0:
		power_remaining = 0
	var battery_frame = 3 - (int)(((power_remaining / power_max) * 100) / 25)
	if (power_remaining/power_max) < 0.1 and $BatteryFlashing.is_stopped() and power_remaining != 0:
		$BatteryFlashing.start()
	if (power_remaining/power_max) >= 0.1:
		if battery_frame >= 0:
			$Battery.set_frame(battery_frame)
	if power_remaining == 0:
		$BatteryFlashing.stop()
		$Battery.set_frame(4)

func _on_area_entered(area):
	if area.is_in_group("Player"):
		player_in_area = true

func _on_area_exited(area):
	if area.is_in_group("Player"):
		player_in_area = false
	
func _interacted():
	minigame_active = true
	var minigame = power_minigame_tscn.instantiate()
	main.get_node("Spaceship").get_child(0).add_child(minigame)
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
	if zeroed:
		$ShockSprite.set_visible(false)
		$ShockSprite.stop()
		zeroed = false
	$SystemSprite.play()
	minigame_active = false
	
func _on_minigame_exited():
	minigame_active = false

func _on_battery_flashing_timeout():
	if $Battery.get_frame() == 3:
		$Battery.set_frame(4)
	elif $Battery.get_frame() == 4:
		$Battery.set_frame(3)
	if power_remaining/power_max < 0.05:
		$BatteryFlashing.stop()
		$BatteryFlashing.start(0.1)

func eel_attack_on():
	eel = true
	$ShockSprite.set_visible(true)
	$ShockSprite.play("default")

func eel_attack_off():
	eel = false
	$ShockSprite.set_visible(false)
	$ShockSprite.stop()

func make_zero():
	power_remaining = 0
	_decrease_power(1/60)
	$ShockSprite.set_visible(true)
	$ShockSprite.play("default")
	zeroed = true
	
func make_full():
	power_remaining = power_max
	_decrease_power(1/60)
