extends CharacterBody2D

@export var speed: int
@export var gravity: int
@export var jump_force: int

var gravity_direction := Vector2(0, 1)
var right_direction := Vector2(1, 0)
var downward_velocity := Vector2.ZERO
var current_angle := 0.0
var fix_rotation := false
var elapsed_time := 0.0

func _process(delta):
	if self.rotation != current_angle and $RotationAdjustDelay.is_stopped() and !fix_rotation:
		$RotationAdjustDelay.start(0.2)
	if fix_rotation:
		self.rotation = lerp_angle(self.rotation, current_angle, elapsed_time)
		elapsed_time += delta
		if elapsed_time >= 1:
			elapsed_time = 1
	if self.rotation == current_angle:
		fix_rotation = false
		elapsed_time = 0
func _physics_process(_delta):
	var horizontal_dir = Input.get_axis("move_left", "move_right")
	velocity = right_direction * horizontal_dir * speed
	if !is_on_floor():
		downward_velocity += (gravity * gravity_direction)
	else:
		downward_velocity = Vector2.ZERO
	if Input.is_action_just_pressed("jump") and is_on_floor():
		downward_velocity = (-jump_force * gravity_direction)
	velocity += downward_velocity
	
	move_and_slide()
	
func set_gravity_direction(angle):
	gravity_direction = Vector2(cos(angle + PI/2), sin(angle + PI/2)).normalized()
	right_direction = Vector2(gravity_direction.y, -gravity_direction.x)
	up_direction = -gravity_direction
	current_angle = angle


func _on_rotation_adjust_delay_timeout():
	fix_rotation = true
