extends CharacterBody2D

@export var speed: int
@export var gravity: int
@export var jump_force: int

var gravity_direction := Vector2(0, 1)
var right_direction := Vector2(1, 0)

func _process(delta):
	$GravityInd.position = gravity_direction * 100
func _physics_process(_delta):
	if !is_on_floor():
		if velocity.y != 500:
			velocity.y += gravity
	if (velocity.y > 500):
		velocity.y = 500
	if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = -jump_force
	var horizontal_dir = Input.get_axis("move_left", "move_right")
	velocity.x = speed * horizontal_dir
	move_and_slide()
	
func set_gravity_direction(angle):
	gravity_direction = Vector2(cos(angle + PI/2), sin(angle + PI/2)).normalized()
