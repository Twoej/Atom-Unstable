extends Node2D

var animation_count := 0
var goal_pos = Vector2.ZERO
var goal_rotation = 0

var rotation_speed := 0.0

signal rotation_change(rotation_change: float, rotation: float)

func _ready():
	rotation_change.connect(get_parent()._on_alien_rotation_change)
	self.set_position(Vector2(532, 512))

func _process(delta):
	if get_parent().get_child(1) != self:
		self.get_parent().move_child(self, 1)
	if $Head.get_position() != goal_pos:
		$Head.set_position($Head.get_position() + ((goal_pos - $Head.get_position()).normalized() * 130 * delta))
		if ($Head.get_position() - goal_pos).length() < 1:
			$Head.set_position(goal_pos)
	elif $PauseBetweenAnimation.is_stopped() and !$Head.is_playing() and !$Hands.is_playing() and abs($Hands.get_rotation() - goal_rotation) < 0.005:
		$PauseBetweenAnimation.start(0.7)
	if abs($Hands.get_rotation() - goal_rotation) > 0.005:
		$Hands.rotate(sign(goal_rotation - $Hands.get_rotation()) * rotation_speed * delta)
		rotation_change.emit(sign(goal_rotation - $Hands.get_rotation()) * rotation_speed * delta, $Hands.get_rotation())
		if abs($Hands.get_rotation() - goal_rotation) < 0.005:
			$Hands.set_rotation(goal_rotation)
			
	if rotation_speed == 0:
		self.set_rotation(get_parent().get_child(2).get_rotation())
	


func _on_pause_between_animation_timeout():
	if animation_count == 0:
		$Head.play("left_blink")
	elif animation_count == 1:
		goal_pos = Vector2(0, 125)
	elif animation_count == 2:
		$Head.play("right_blink")
		$Head.pause()
		$Head.set_frame(0)
		goal_pos = Vector2.ZERO
	elif animation_count == 3:
		$Head.play()
	elif animation_count == 4:
		goal_pos = Vector2(0, 125)
	elif animation_count == 5:
		$Head.play("middle")
		goal_pos = Vector2.ZERO
	elif animation_count == 6:
		$Hands.set_visible(true)
		$Hands.play("default")
		rotation_change.emit(0, 0)
	elif animation_count == 7:
		rotation_speed = 0.1
		goal_rotation = -0.2
	elif animation_count == 8:
		rotation_speed = PI
		goal_rotation = PI/6
	elif animation_count == 9:
		self.queue_free()
	animation_count += 1


func _on_head_frame_changed():
	if animation_count == 4 and $Head.get_frame() == 1:
		$Head.set_position(Vector2(738, 2))
		goal_pos = $Head.get_position()
	elif animation_count == 4 and $Head.get_frame() == 4:
		$Head.set_position(Vector2.ZERO)
		goal_pos = Vector2.ZERO
