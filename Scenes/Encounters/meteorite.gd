extends AnimatedSprite2D

var velocity = Vector2(-52, 238).normalized() * 200

func _ready():
	play(str(randi_range(1, 4)))
	position = Vector2(randf_range(1200, 1640), randf_range(-220, 220))
	set_z_index(randi_range(-1, 1))
	

func _process(delta):
	position += velocity * delta
