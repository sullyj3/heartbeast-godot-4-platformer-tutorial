extends Node2D

@onready var collision_polygon_2d = $platform/CollisionPolygon2D
@onready var polygon_2d = $platform/CollisionPolygon2D/Polygon2D
@onready var camera = $Camera2D
@onready var player = $Player

func _ready():
	RenderingServer.set_default_clear_color(Color.BLACK)
	polygon_2d.polygon = collision_polygon_2d.polygon

func _process(delta):
	camera.position = player.position
