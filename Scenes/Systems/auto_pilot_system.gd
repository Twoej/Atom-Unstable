extends System

signal auto_pilot_down()
signal auto_pilot_powered()
signal ship_angle_correction_timeout()

func _power_depleted():
	auto_pilot_down.emit()

func _power_replenished():
	auto_pilot_powered.emit()


func _on_ship_angle_correction_timeout():
	ship_angle_correction_timeout.emit()
