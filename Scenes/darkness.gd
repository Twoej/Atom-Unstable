extends PointLight2D

var elapsed_time := 0.0
var darken := false
var fade_on := false

func _process(delta):
	if self.get_color() != Color.WHITE and darken:
		self.set_color(Color(1, 1, 1, 0).lerp(Color.WHITE, elapsed_time))
		elapsed_time += delta
		if elapsed_time >= 1:
			elapsed_time = 1
			darken = false
	if fade_on:
		self.set_color(Color.WHITE.lerp(Color(1, 1, 1, 0), elapsed_time))
		elapsed_time += delta
		if elapsed_time >= 1:
			self.queue_free()


func _on_dark_delay_timeout():
	darken = true

func lights_powered():
	fade_on = true
	elapsed_time = 0
