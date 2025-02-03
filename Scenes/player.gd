extends CharacterBody2D

@export var speed: float

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
var air_time_gravity := true
var airborne := true

var gravity_off := false
@export var anti_grav_speed: float
var anti_grav_direction := Vector2.ZERO

var currently_active_minigame_system: System
var currently_active_minigame: Minigame
var player_frozen := false

@export var sliding_accel: float
var sliding_speed: float = 0.0
@export var max_sliding_speed: float
var slide := false

var slippery := false
var horizontal_speed := 0.0
@export var slippery_accel: float
@export var slippery_accel_stationary: float

@export var player_light_tscn: PackedScene

var temp_light: Node2D

var jump_cooldown_complete := true

var prev_angle := 0.0

signal minigame_exited()

var has_gun := false
signal gun_returned()
var gun_rack: System
@export var bullet_tscn: PackedScene

func _process(delta):
	if Input.is_action_just_pressed("click") and has_gun and !gravity_off and !player_frozen:
		$SFXShoot.play()
		var bullet = bullet_tscn.instantiate()
		var facing: int
		if $PlayerSprite.is_flipped_h():
			facing = -1
		else:
			facing = 1
		bullet.direction = facing * right_direction
		bullet.position = self.get_position()
		get_parent().add_child(bullet)
	if has_gun:
		$GunMeter.set_value(($GunTimer.get_time_left() / 20) * 100)
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
		
	
	

func _physics_process(delta):
	if gravity_off:
		anti_grav_direction = Input.get_vector("move_left", "move_right", "jump", "move_down")
		if anti_grav_direction == Vector2.ZERO:
			velocity = 0.99 * velocity
		else:
			velocity = (0.93 * velocity) + (0.07 * (anti_grav_direction * anti_grav_speed))
		if player_frozen:
			velocity = Vector2.ZERO
		move_and_slide()
		return
	#Determines player movement input and resulting speed
	var horizontal_dir = Input.get_axis("move_left", "move_right")
	if player_frozen:
		horizontal_dir = 0
	if slippery:
		horizontal_speed += horizontal_dir * slippery_accel
		if horizontal_dir == 0:
			if horizontal_speed > 0:
				horizontal_speed -= slippery_accel_stationary
			elif horizontal_speed < 0:
				horizontal_speed += slippery_accel_stationary
		if abs(horizontal_speed) > 2 * (speed/3):
			horizontal_speed = horizontal_dir * 2 * (speed/3)
	else:
		horizontal_speed = horizontal_dir * speed
	velocity = right_direction * horizontal_speed		#Uses right direction for current gravity
	if slide and is_on_floor():
		velocity += right_direction * sliding_speed
		if abs(current_angle) < (PI/19 * delta):
			sliding_speed -= sign(current_angle) * sliding_accel
		else:
			sliding_speed += sign(current_angle) * sliding_accel
		if sign(sliding_speed) != sign(current_angle):
			sliding_speed += sign(current_angle) * sliding_accel
		if abs(sliding_speed) > max_sliding_speed:
			sliding_speed = max_sliding_speed * sign(current_angle)
		if current_angle == prev_angle:
			sliding_speed = sliding_speed / 2
		if abs(sliding_speed) < sliding_accel:
			slide = false
		if Input.is_action_pressed("move_right") or Input.is_action_pressed("move_left"):
			sliding_speed -= sign(current_angle * sliding_accel)
		prev_angle = current_angle
	#Determines downward velocity, increase the longer player is in air
	if !is_on_floor():
		if $AirborneTimer.is_stopped():
			$AirborneTimer.start()
		#Casts desired speed onto gravity direction
		downward_velocity += (_get_gravity() * gravity_direction)
	else:
		downward_velocity = downward_velocity * gravity_direction
		if downward_velocity.length() > 500:
			downward_velocity = 500 * gravity_direction
		$AirborneTimer.stop()
		airborne = false
		air_time_gravity = false
	#Handles jump
	if Input.is_action_just_pressed("jump") and is_on_floor() and !player_frozen and jump_cooldown_complete:
		$SFXJump.play()
		downward_velocity = (jump_velocity * gravity_direction)
		$PlayerSprite.play("jump_start")
		$JumpCooldown.start()
		jump_cooldown_complete = false
	#Add downward velocity to velocity
	velocity += downward_velocity
	
	move_and_slide()
		
	
func set_gravity_direction(angle):
	slide = true
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

func _on_minigame_active(sibling_system, minigame):
	currently_active_minigame_system = sibling_system
	minigame_exited.connect(currently_active_minigame_system._on_minigame_exited)
	currently_active_minigame = minigame
	player_frozen = true

func _on_minigame_complete():
	minigame_exited.disconnect(currently_active_minigame_system._on_minigame_exited)
	currently_active_minigame_system = null
	player_frozen = false


func _on_temperature_system_temperature_down():
	$IceTimer.start()
	slippery = true


func _on_ice_timer_timeout():
	slippery = false
	


func _on_lights_system_lights_down():
	var light = player_light_tscn.instantiate()
	self.add_child(light)
	temp_light = light


func _on_lights_system_lights_powered():
	$LightOutTimer.start()


func _on_light_out_timer_timeout():
	if temp_light != null:
		temp_light.light_out()
		temp_light = null


func _on_jump_cooldown_timeout():
	jump_cooldown_complete = true


func _on_floor_detection_area_entered(area):
	if area.is_in_group("Floor"):
		if player_frozen and (currently_active_minigame != null):
			player_frozen = false
			minigame_exited.emit()
			minigame_exited.disconnect(currently_active_minigame_system._on_minigame_exited)
			currently_active_minigame_system = null
			currently_active_minigame.queue_free()
			currently_active_minigame = null
		

func _on_gun_rack_give_gun(gun_rack: System):
	has_gun = true
	$GunTimer.start()
	$GunMeter.set_visible(true)
	gun_returned.connect(gun_rack._on_player_gun_returned)
	self.gun_rack = gun_rack


func _on_gun_timer_timeout():
	has_gun = false
	gun_returned.emit()
	gun_returned.disconnect(gun_rack._on_player_gun_returned)
	self.gun_rack = null
	$GunMeter.set_visible(false)

func _on_eel_attack():
	$ShockSprite.set_visible(true)
	$ShockSprite.play("default")
	$ShockTimer.start(4)
	$SFXBuzzWarning.play()


func _on_shock_timer_timeout():
	if !player_frozen:
		$ShockSprite.set_scale(Vector2(2, 2))
		player_frozen = true
		$ShockTimer.start(2)
		$SFXStun.play()
	elif player_frozen:
		$ShockSprite.set_visible(false)
		$ShockSprite.set_scale(Vector2(1, 1))
		$ShockSprite.stop()
		$ShockSprite.set_frame(0)
		player_frozen = false
		
