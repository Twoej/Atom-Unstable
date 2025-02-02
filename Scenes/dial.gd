extends Area2D

var velocity: float:
	set(value):
		velocity = value
		if velocity == 0:
			$LockInTimer.start()
			$LockIn.set_visible(true)

func _ready():
	velocity = randf_range(300, 1000);
	var direction := float(randi_range(0, 1))
	velocity = velocity * sign(direction - 0.5)
	var starting_pos = randi_range(-232, 234)
	set_position(Vector2(starting_pos, get_position().y))

func _process(delta):
	self.position.x += velocity * delta


func _on_area_entered(area):
	if area.is_in_group("Minigame"):
		velocity = -velocity


func _on_lock_in_timer_timeout():
	$LockIn.set_visible(false)

func set_velocity(value):
	velocity = value
