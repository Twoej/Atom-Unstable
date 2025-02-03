extends System

signal lights_down()
signal lights_powered()

func _connect_signals():
	boarder_position = Vector2(-61, 20)

func _power_depleted():
	lights_down.emit()

func _power_replenished():
	lights_powered.emit()
