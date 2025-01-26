extends System

signal oxygen_down()
signal oxygen_powered()

func _connect_signals():
	oxygen_down.connect(main._on_oxygen_down)

func _power_depleted():
	oxygen_down.emit()

func _power_replenished():
	oxygen_powered.emit()
