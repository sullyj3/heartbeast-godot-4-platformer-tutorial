extends CharacterBody2D

@export var movement_data : PlayerMovementData

var can_air_jump = false
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var coyote_jump_timer = $"Coyote Jump Timer"

func apply_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * delta * movement_data.gravity_scale

func handle_jump():
	if is_on_floor(): 
		can_air_jump = true

	if Input.is_action_just_pressed("ui_accept"):
		var can_jump = is_on_floor() or not coyote_jump_timer.is_stopped()
		if can_jump:
			velocity.y = movement_data.jump_velocity
		elif not is_on_floor() and can_air_jump:
			velocity.y = movement_data.jump_velocity * 0.8
			can_air_jump = false

	# slow upwards movement on jump release
	elif Input.is_action_just_released("ui_accept") and not is_on_floor() and velocity.y < 0:
		velocity.y = velocity.y / 2

func handle_acceleration(input_axis, delta):
	var acceleration = movement_data.acceleration if is_on_floor() else movement_data.air_acceleration
	if input_axis != 0:
		velocity.x = move_toward(velocity.x, input_axis * movement_data.speed, acceleration * delta)

# ground only
func apply_friction(input_axis, delta):
	if input_axis == 0 and is_on_floor():
		velocity.x = move_toward(velocity.x, 0, movement_data.friction * delta)

func apply_air_resistance(input_axis, delta):
	if input_axis == 0 and not is_on_floor():
		velocity.x = move_toward(velocity.x, 0, movement_data.air_resistance * delta)

func _physics_process(delta):
	apply_gravity(delta)
	handle_jump()
	var input_axis = Input.get_axis("ui_left", "ui_right")
	update_animations(input_axis)
	handle_acceleration(input_axis, delta)
	apply_friction(input_axis, delta)
	apply_air_resistance(input_axis, delta)
	var was_on_floor = is_on_floor()
	move_and_slide()
	var just_left_ledge = (was_on_floor and not is_on_floor() and velocity.y >= 0)
	if just_left_ledge:
		coyote_jump_timer.start()

func update_animations(input_axis):
	if input_axis == 0:
		animated_sprite_2d.play("idle")
	else:
		animated_sprite_2d.play("run")
		animated_sprite_2d.flip_h = input_axis < 0
	
	# when in air, override run and idle and play "jump" 
	if not is_on_floor():
		animated_sprite_2d.play("jump")
