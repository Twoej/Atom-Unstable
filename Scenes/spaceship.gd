extends Node2D



func _physics_process(delta):
	if Input.is_action_pressed("platform_clockwise"):
		$RotationalAxis.rotate(0.05)
		$Player.set_gravity_direction($RotationalAxis.get_rotation())
	if Input.is_action_pressed("platform_counter_clockwise"):
		$RotationalAxis.rotate(-0.05)
		$Player.set_gravity_direction($RotationalAxis.get_rotation())
