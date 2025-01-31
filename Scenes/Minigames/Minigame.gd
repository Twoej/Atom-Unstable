class_name Minigame extends Node2D

var sibling_system: System
var player: CharacterBody2D

signal minigame_complete()
signal minigame_active(sibling_system: System, minigame: Minigame)

func _ready():
	player = get_node("/root/Main/Spaceship/Player")
	minigame_active.connect(player._on_minigame_active)
	minigame_complete.connect(player._on_minigame_complete)
	
	_minigame_ready()

func set_sibling_system(system: System):
	sibling_system = system
	minigame_complete.connect(sibling_system._on_minigame_complete)
	minigame_active.emit(sibling_system, self)

func _minigame_ready():
	pass
