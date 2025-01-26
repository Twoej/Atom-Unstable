extends System

signal temperature_down()
signal temperature_powered()

func _connect_signals():
	temperature_down.connect(main._on_temperature_down)
	temperature_powered.connect(main._on_temperature_powered)

func _power_depleted():
	temperature_down.emit()

func _power_replenished():
	temperature_powered.emit()
