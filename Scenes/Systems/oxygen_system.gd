extends System

signal oxygen_down()
signal oxygen_powered()

func _connect_signals():
	oxygen_down.connect(main._on_oxygen_down)
	oxygen_powered.connect(main._on_oxygen_powered)

func _power_depleted():
	oxygen_down.emit()

func _power_replenished():
	oxygen_powered.emit()
