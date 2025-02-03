extends Node2D

@export var sway_speed: float
@export var sway_acceleration: float
@export var angle_correction_speed := PI/16

var auto_pilot_down := false
var auto_pilot_down_saved := false
var angle_correction := false
var elapsed_time := 0.0

@export var darkness_tscn: PackedScene

var temp_dark: Node2D

var alien_rotate := false
var alien_rotate_point := 0.0
var rotation_count := 0

var systems = []

var eel_target: System

@export var robot_tscn: PackedScene

var total_rotated: float

func _ready():
	systems = [
	$RotationalAxis/Systems/GravitySystem,
	$RotationalAxis/Systems/OxygenSystem,
	$RotationalAxis/Systems/TemperatureSystem,
	$RotationalAxis/Systems/LightsSystem,
	$RotationalAxis/Systems/AutoPilotSystem,
	$RotationalAxis/Systems/EngineSystem
	]

func _physics_process(delta):
	if abs($RotationalAxis.rotation) > (2 * PI):
		$RotationalAxis.rotation = lerp_angle(0, $RotationalAxis.rotation, 1)
	if auto_pilot_down:
		$RotationalAxis.rotate(sway_speed * delta)
		if $RotationalAxis.get_rotation() > 0:
			sway_speed -= sway_acceleration * delta
		else:
			sway_speed += sway_acceleration * delta
		$Player.set_gravity_direction($RotationalAxis.get_rotation())
	if angle_correction:
		$RotationalAxis.set_rotation(lerp_angle($RotationalAxis.get_rotation(), 0, elapsed_time))
		if $RotationalAxis.get_rotation() == 0:
			angle_correction = false
			elapsed_time = 0
			if alien_rotate:
				alien_rotate = false
				alien_rotate_point = 0
				rotation_count = 0
				if auto_pilot_down_saved:
					auto_pilot_down = true
		elapsed_time += (delta / 2)
		if elapsed_time > 1:
			elapsed_time = 1
		$Player.set_gravity_direction($RotationalAxis.get_rotation())
		
		
	if alien_rotate:
		if (rotation_count != 2) or (abs($RotationalAxis.get_rotation() - alien_rotate_point) > 0.042):
			$RotationalAxis.rotate((3 * PI/4) * delta)
			total_rotated += (3 * PI/4) * delta
			$Player.set_gravity_direction($RotationalAxis.get_rotation())
			rotation_count = (int)(total_rotated/(2 * PI))
		elif $AlienTimer.is_stopped():
			$AlienTimer.start()
			


func _on_auto_pilot_system_auto_pilot_down():
	auto_pilot_down = true
	auto_pilot_down_saved = true
	var direction = randi_range(0, 1)
	sway_speed = randf_range(PI/20, PI/8)
	if direction == 0:
		sway_speed = sway_speed * -1
	sway_acceleration = randf_range(PI/36, PI/16)
	if alien_rotate:
		auto_pilot_down = false


func _on_auto_pilot_system_auto_pilot_powered():
	auto_pilot_down = false
	auto_pilot_down_saved = false
	sway_speed = 0
	sway_acceleration = 0
	$RotationalAxis/Systems/AutoPilotSystem/ShipAngleCorrection.start()


func _on_auto_pilot_system_ship_angle_correction_timeout():
	angle_correction = true


func _on_lights_system_lights_down():
	var dark = darkness_tscn.instantiate()
	$RotationalAxis/Ship.add_child(dark)
	temp_dark = dark
	$RotationalAxis/Ship/ShipSprite.play("light_off")


func _on_lights_system_lights_powered():
	if temp_dark != null:
		temp_dark.lights_powered()
		$RotationalAxis/Ship/ShipSprite.play("light_on")
		temp_dark = null


func _on_temperature_system_temperature_down():
	$RotationalAxis/Ship/IceFloors.set_visible(true)
	$SFXIce.play()
	$IceTimer.start()


func _on_ice_timer_timeout():
	$RotationalAxis/Ship/IceFloors.set_visible(false)

func _on_alien_rotation_change(rotation_change: float, rotation: float):
	$RotationalAxis.rotate(rotation_change)
	$Player.set_gravity_direction($RotationalAxis.get_rotation())
	if auto_pilot_down:
		auto_pilot_down = false
	if rotation > 0.51:
		alien_rotate = true
		total_rotated = 0.0
		alien_rotate_point = randf_range(0, 2 * PI)


func _on_alien_timer_timeout():
	angle_correction = true

func _on_boarder_ship_boarded():
	var boarder = robot_tscn.instantiate()
	systems[randi_range(0, 5)].add_child(boarder)


func _on_eel_encounter_attack():
	eel_target = systems[randi_range(0, 5)]
	eel_target.eel_attack_on()
	
func _on_eel_encounter_attack_end():
	eel_target.eel_attack_off()
	eel_target = null

func _on_eel_attack_beam():
	var system_to_zero = systems[randi_range(0, 5)]
	system_to_zero.make_zero()
	
func systems_reset():
	for system in systems:
		system.make_full()
	if has_node("EelEncounter"):
		$EelEncounter.queue_free()
