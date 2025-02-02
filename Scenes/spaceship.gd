extends Node2D

@export var sway_speed: float
@export var sway_acceleration: float
@export var angle_correction_speed := PI/16

var auto_pilot_down := false
var angle_correction := false
var elapsed_time := 0.0

@export var darkness_tscn: PackedScene

var temp_dark: Node2D

func _physics_process(delta):
	if abs($RotationalAxis.rotation) > (2 * PI):
		$RotationalAxis.rotation = lerp_angle(0, $RotationalAxis.rotation, 1)
	if Input.is_action_pressed("platform_clockwise"):
		$RotationalAxis.rotate(0.05)
		$Player.set_gravity_direction($RotationalAxis.get_rotation())
	if Input.is_action_pressed("platform_counter_clockwise"):
		$RotationalAxis.rotate(-0.05)
		$Player.set_gravity_direction($RotationalAxis.get_rotation())
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
		elapsed_time += (delta / 2)
		if elapsed_time > 1:
			elapsed_time = 1
		$Player.set_gravity_direction($RotationalAxis.get_rotation())
		


func _on_auto_pilot_system_auto_pilot_down():
	auto_pilot_down = true
	var direction = randi_range(0, 1)
	sway_speed = randf_range(PI/20, PI/8)
	if direction == 0:
		sway_speed = sway_speed * -1
	sway_acceleration = randf_range(PI/36, PI/16)


func _on_auto_pilot_system_auto_pilot_powered():
	auto_pilot_down = false
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
	$IceTimer.start()


func _on_ice_timer_timeout():
	$RotationalAxis/Ship/IceFloors.set_visible(false)
