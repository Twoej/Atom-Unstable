extends System

signal lights_down()
signal lights_powered()

func _power_depleted():
	lights_down.emit()

func _power_replenished():
	lights_powered.emit()
