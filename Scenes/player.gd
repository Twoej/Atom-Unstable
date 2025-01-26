extends CharacterBody2D

@export var speed: int

@export var jump_height: float
@export var jump_time_to_peak: float
@export var jump_time_to_descent: float

@onready var jump_velocity: float = (-2.0 * jump_height) / jump_time_to_peak
@onready var jump_gravity: float = (2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)
@onready var fall_gravity: float = (2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)

var gravity_direction := Vector2(0, 1)
var right_direction := Vector2(1, 0)
var downward_velocity := Vector2.ZERO
var current_angle := 0.0
var fix_rotation := false
var elapsed_time := 0.0
var air_time_gravity = true
var airborne = true

var gravity_off = false
@export var anti_grav_speed: float
var anti_grav_direction := Vector2.ZERO

func _process(delta):
	if gravity_off:
		if anti_grav_direction != Vector2.ZERO:
			self.rotation = anti_grav_direction.angle() + PI/2
		return
	##Rotation fixing
	#Checks if rotation needs to be fixed for new gravity
	if self.rotation != current_angle and $RotationAdjustDelay.is_stopped() and !fix_rotation:
		$RotationAdjustDelay.start(0.2)		#Timer until rotation is fixed
	if fix_rotation:
		#Rotates player to match angle at an exponential rate
		self.rotation = lerp_angle(self.rotation, current_angle, elapsed_time)
		elapsed_time += delta
		#lerp_angle cannot take more than 1 without error
		if elapsed_time >= 1:
			elapsed_time = 1
	#Stops rotation fix if rotation is correct
	if self.rotation == current_angle:
		fix_rotation = false
		elapsed_time = 0
		
	##Animation Handling
	#Play in air animation if in the air and not currently jumping
	if !$PlayerSprite.is_playing() and !is_on_floor() and ($PlayerSprite.get_current_animation() != "in_air"):
		$PlayerSprite.play("in_air")
	#Play running animation if on the ground and inputting
	if is_on_floor() and Input.get_axis("move_left", "move_right"):
		$PlayerSprite.play("run_right")
		#Send the input to the sprite to flip the sprite to the right direction
		$PlayerSprite.flip_sprite(Input.get_axis("move_left", "move_right"))
	#If there is no input, idle animation
	elif is_on_floor():
		$PlayerSprite.play("still")
	#If the player is airborne and at peak of jump and not already in the falling state play the falling animation
	if !is_on_floor() and (downward_velocity.length() < 30) and airborne and ($PlayerSprite.get_current_animation() != "falling"):
		$PlayerSprite.play("falling")

func _physics_process(_delta):
	if gravity_off:
		anti_grav_direction = Input.get_vector("move_left", "move_right", "jump", "move_down")
		if anti_grav_direction == Vector2.ZERO:
			velocity = 0.99 * velocity
		else:
			velocity = (0.93 * velocity) + (0.07 * (anti_grav_direction * anti_grav_speed))
		move_and_slide()
		return
	#Determines player movement input and resulting speed
	var horizontal_dir = Input.get_axis("move_left", "move_right")
	velocity = right_direction * horizontal_dir * speed		#Uses right direction for current gravity
	#Determines downward velocity, increase the longer player is in air
	if !is_on_floor():
		if $AirborneTimer.is_stopped():
			$AirborneTimer.start()
		#Casts desired speed onto gravity direction
		downward_velocity += (_get_gravity() * gravity_direction)
	else:
		$AirborneTimer.stop()
		airborne = false
		downward_velocity = Vector2.ZERO
		air_time_gravity = false
	#Handles jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		downward_velocity = (jump_velocity * gravity_direction)
		$PlayerSprite.play("jump_start")
	#Add downward velocity to velocity
	velocity += downward_velocity
	
	move_and_slide()
	
func set_gravity_direction(angle):
	#Determines the vector of gravity direction
	gravity_direction = Vector2(cos(angle + PI/2), sin(angle + PI/2)).normalized()
	#stores the right direction (perpendicular to grav)
	right_direction = Vector2(gravity_direction.y, -gravity_direction.x)
	#Changes the up direction for move_and_slide()
	up_direction = -gravity_direction
	#Saves the angle to adjust the player angle later
	current_angle = angle


func _on_rotation_adjust_delay_timeout():
	fix_rotation = true


func _on_airborne_timer_timeout():
	airborne = true
	

func _get_gravity():
	if abs(downward_velocity.angle() - gravity_direction.angle()) < PI/8:
		return fall_gravity
	else:
		return jump_gravity


func _on_gravity_system_gravity_down():
	gravity_off = true
	downward_velocity = -200 * gravity_direction
	velocity = (0.1 * velocity) + downward_velocity
	$PlayerSprite.play("anti-grav", 0.8)


func _on_gravity_system_gravity_powered():
	gravity_off = false
	velocity = Vector2.ZERO
	downward_velocity = Vector2.ZERO
	anti_grav_direction = Vector2.ZERO
	$PlayerSprite.play("falling", 1)
