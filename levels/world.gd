extends Node2D

@onready var collision_polygon_2d = $platform/CollisionPolygon2D
@onready var polygon_2d = $platform/CollisionPolygon2D/Polygon2D
@onready var camera = $Camera2D
@onready var player = $Player
@onready var level_completed = $CanvasLayer/LevelCompleted

func _ready():
	RenderingServer.set_default_clear_color(Color.BLACK)
	polygon_2d.polygon = collision_polygon_2d.polygon
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
	print("Level completed!")
	level_completed.show()
