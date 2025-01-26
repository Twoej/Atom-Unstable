extends System

signal gravity_down()
signal gravity_powered()

func _power_depleted():
	gravity_down.emit()

func _power_replenished():
	gravity_powered.emit()
