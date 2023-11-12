extends Node2D

@export var next_level: PackedScene

@onready var camera = $Camera2D
@onready var player = $Player
@onready var level_completed = $CanvasLayer/LevelCompleted

func _ready():
	RenderingServer.set_default_clear_color(Color.BLACK)
	Events.level_completed.connect(show_level_completed)

func _process(_delta):
	# camera.position = player.position
	# smooth camera movement (exponential decay)
	var camera_target_position = player.position + Vector2.UP * 30.0
	var camera_target_offset = camera_target_position - camera.position
	camera.position = camera.position + camera_target_offset * 0.3
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()

func show_level_completed():
	level_completed.show()
	if not next_level is PackedScene: return
	LevelTransition.transition_to(next_level)
