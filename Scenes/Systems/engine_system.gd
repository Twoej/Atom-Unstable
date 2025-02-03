extends System

signal engine_down()
signal engine_powered()

func _connect_signals():
	engine_down.connect(main._on_engine_down)
	engine_powered.connect(main._on_engine_powered)
	boarder_position = Vector2(-72, 4)

func _power_depleted():
	engine_down.emit()

func _power_replenished():
	engine_powered.emit()
