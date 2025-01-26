extends Node2D

func _physics_process(delta):
	if abs($RotationalAxis.rotation) > (2 * PI):
		$RotationalAxis.rotation = lerp_angle(0, $RotationalAxis.rotation, 1)
	if Input.is_action_pressed("platform_clockwise"):
		$RotationalAxis.rotate(0.05)
		$Player.set_gravity_direction($RotationalAxis.get_rotation())
	if Input.is_action_pressed("platform_counter_clockwise"):
		$RotationalAxis.rotate(-0.05)
		$Player.set_gravity_direction($RotationalAxis.get_rotation())
