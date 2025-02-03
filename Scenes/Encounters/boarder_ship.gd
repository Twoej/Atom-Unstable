extends Node2D

var time_elapsed := 0.0
var complete = false
signal boarded()

func _ready():
	boarded.connect(get_parent()._on_boarder_ship_boarded)
	
func _process(delta):
	if !complete:
		position = Vector2(2069, -126).lerp(Vector2(1713, 205), time_elapsed)
		time_elapsed += delta
		if time_elapsed > 1:
			time_elapsed = 1
		if position == Vector2(1713, 205) and !$AnimatedSprite2D.is_playing():
			$AnimatedSprite2D.play("default")
			complete = true


func _on_animated_sprite_2d_animation_finished():
	boarded.emit()
	$LeaveTimer.start()


func _on_leave_timer_timeout():
	self.queue_free()
