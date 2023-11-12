extends CanvasLayer

@onready var animation_player = $AnimationPlayer

func _fade_to_black():
	animation_player.play("fade_to_black")
	await animation_player.animation_finished

func _fade_from_black():
	animation_player.play("fade_from_black")
	await animation_player.animation_finished

func transition_to(scene: PackedScene):
	await _fade_to_black()
	get_tree().change_scene_to_packed(scene)
	_fade_from_black()
