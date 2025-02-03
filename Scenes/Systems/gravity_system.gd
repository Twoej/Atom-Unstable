extends System

signal gravity_down()
signal gravity_powered()

func _connect_signals():
	boarder_position = Vector2(-73, 14)

func _power_depleted():
	gravity_down.emit()

func _power_replenished():
	gravity_powered.emit()
