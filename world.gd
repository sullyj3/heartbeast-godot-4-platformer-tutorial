extends Node2D

@onready var collision_polygon_2d = $platform/CollisionPolygon2D
@onready var polygon_2d = $platform/CollisionPolygon2D/Polygon2D
@onready var camera = $Camera2D
@onready var player = $Player

func _ready():
	RenderingServer.set_default_clear_color(Color.BLACK)
	polygon_2d.polygon = collision_polygon_2d.polygon

func _process(delta):
	# camera.position = player.position
	# smooth camera movement (exponential decay)
	var camera_player_offset = player.position - camera.position
	camera.position = camera.position + camera_player_offset * 0.3
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
