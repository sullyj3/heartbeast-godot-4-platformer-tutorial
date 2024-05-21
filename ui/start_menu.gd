extends CenterContainer

@export var first_level: PackedScene

@onready var start_game_button = %StartGameButton
@onready var quitbutton = %Quitbutton
@onready var ui_button_prompt = $uiButtonPrompt

func any_joystick_connected():
	return not Input.get_connected_joypads().is_empty()

func _ready():
	RenderingServer.set_default_clear_color(Color.BLACK)
	start_game_button.grab_focus()
	
	# gamepad UI set
	ui_button_prompt.visible = any_joystick_connected()
	Input.connect("joy_connection_changed", _on_joy_connection_changed)

func _on_joy_connection_changed(device: int, connected: bool):
	ui_button_prompt.visible = any_joystick_connected()

func _on_start_game_button_pressed():
	LevelTransition.transition_to(first_level)

func _on_quitbutton_pressed():
	get_tree().quit()
