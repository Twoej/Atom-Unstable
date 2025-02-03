extends System

signal temperature_down()
signal temperature_powered()

func _connect_signals():
	temperature_down.connect(main._on_temperature_down)
	temperature_powered.connect(main._on_temperature_powered)
	boarder_position = Vector2(-62, 3)

func _power_depleted():
	temperature_down.emit()
	$WarningFlashing.start()

func _power_replenished():
	temperature_powered.emit()
	$WarningFlashing.stop()
	$Warning.set_visible(false)


func _on_warning_flashing_timeout():
	$Warning.set_visible(!$Warning.is_visible())
