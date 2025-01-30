extends PointLight2D

var time_elapsed := 0.0
var light_fade := false

func _process(delta):
	if self.get_energy() != 1 and !light_fade:
		self.set_energy(time_elapsed)
		time_elapsed += delta
		if time_elapsed >= 1:
			time_elapsed = 1
	elif light_fade:
		self.set_energy(1 - time_elapsed)
		time_elapsed += delta
		if time_elapsed >= 1:
			self.queue_free()

func light_out():
	light_fade = true
	time_elapsed = 0
