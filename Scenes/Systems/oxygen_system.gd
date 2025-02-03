extends System

signal oxygen_down()
signal oxygen_powered()

func _connect_signals():
	oxygen_down.connect(main._on_oxygen_down)
	oxygen_powered.connect(main._on_oxygen_powered)
	boarder_position = Vector2(-59, 27)

func _power_depleted():
	oxygen_down.emit()
	$WarningFlashing.start()

func _power_replenished():
	oxygen_powered.emit()
	$WarningFlashing.stop()
	$Warning.set_visible(false)


func _on_warning_flashing_timeout():
	$Warning.set_visible(!$Warning.is_visible())
