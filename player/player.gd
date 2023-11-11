extends CharacterBody2D

signal died

@export var movement_data : PlayerMovementData

var can_air_jump = false
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var coyote_jump_timer = $"Coyote Jump Timer"

@onready var initial_position = position

@onready var raycast_left_leg: RayCast2D = $raycast_left_leg
@onready var raycast_left_shoulder: RayCast2D = $raycast_left_shoulder
@onready var raycast_right_leg: RayCast2D = $raycast_right_leg
@onready var raycast_right_shoulder: RayCast2D = $raycast_right_shoulder

func apply_gravity(delta: float):
	if not is_on_floor():
		# when player has jumped, they can release jump to slow their ascent
		# we apply heavier gravity when moving upwards with jump key released
		# TODO this is a bit of a hack, may need to revisit when there are other 
		# possible causes of the player moving upwards than just jumping
		var heavy_gravity = velocity.y < 0 and not Input.is_action_pressed("jump")
		var jump_released_gravity_scalar = 3.0 if heavy_gravity else 1.0
		velocity.y += gravity * delta * movement_data.gravity_scale * jump_released_gravity_scalar

# returns either the normal of the wall we're touching, or false if we're not touching a wall
func maybe_wall_collision_normal():
	# TODO ensure collision is with a wall
	match facing_direction:
		-1.0:
			if raycast_left_leg.is_colliding(): return raycast_left_leg.get_collision_normal()
			if raycast_left_shoulder.is_colliding(): return raycast_left_shoulder.get_collision_normal()
		1.0:
			if raycast_right_leg.is_colliding(): return raycast_right_leg.get_collision_normal()
			if raycast_right_shoulder.is_colliding(): return raycast_right_shoulder.get_collision_normal()
		_:
			return false

func handle_jump():
	if is_on_floor(): 
		can_air_jump = true

	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = movement_data.jump_velocity
		elif not coyote_jump_timer.is_stopped():
			velocity.y = movement_data.jump_velocity
		else:
			var wall_normal = maybe_wall_collision_normal()
			if wall_normal:
				velocity.y = movement_data.wall_jump_v_speed
				velocity.x = wall_normal.x * movement_data.wall_jump_h_speed
				facing_direction = sign(velocity.x)
				can_air_jump = true
			elif can_air_jump:
				velocity.y = movement_data.jump_velocity * 0.8
				can_air_jump = false

func handle_acceleration(input_axis: float, delta):
	var acceleration = movement_data.acceleration if is_on_floor() else movement_data.air_acceleration
	var speed = movement_data.speed
	if Input.is_action_pressed("sprint"):
		speed *= 1.75
	if input_axis != 0:
		velocity.x = move_toward(velocity.x, input_axis * speed, acceleration * delta)

# ground only
func apply_friction(input_axis: float, delta):
	if input_axis == 0 and is_on_floor():
		velocity.x = move_toward(velocity.x, 0, movement_data.friction * delta)

func apply_air_resistance(input_axis: float, delta):
	if input_axis == 0 and not is_on_floor():
		velocity.x = move_toward(velocity.x, 0, movement_data.air_resistance * delta)


func _physics_process(delta):
	if die_if_fell_out_of_world():
		return
	apply_gravity(delta)
	handle_jump()
	var input_axis: float = Input.get_axis("move_left", "move_right")
	update_animations(input_axis)
	handle_acceleration(input_axis, delta)
	apply_friction(input_axis, delta)
	apply_air_resistance(input_axis, delta)
	var was_on_floor = is_on_floor()
	move_and_slide()
	var just_left_ledge = (was_on_floor and not is_on_floor() and velocity.y >= 0)
	if just_left_ledge:
		coyote_jump_timer.start()

func die_if_fell_out_of_world():
	if position.y > 360:
		reset()

func reset():
	position = initial_position 
	velocity = Vector2.ZERO
	died.emit()

# default sprite faces right, flipped faces left
# negative if facting left, positive if facing right
var facing_direction = 1

func update_animations(input_axis: float):
	if input_axis == 0:
		animated_sprite_2d.play("idle")
	else:
		animated_sprite_2d.play("run")

		# if we're moving in the same direction as our velocity, face that way
		if sign(input_axis) == sign(velocity.x):
			facing_direction = sign(input_axis)
		else:
			# player trying to move in opposite direction of velocity.
			# face sprite in direction of input as long as their
			# reverse velocity is below a certain threshold
			const H_FLIP_THRESHOLD_VELOCITY = 100
			var should_face_input = abs(velocity.x) < H_FLIP_THRESHOLD_VELOCITY
			facing_direction = sign(input_axis) if should_face_input else sign(velocity.x)

	# when in air, override run and idle and play "jump" 
	if not is_on_floor():
		animated_sprite_2d.play("jump")

	animated_sprite_2d.flip_h = facing_direction < 0

func _on_hazard_detector_area_entered(_area):
	print("player entered hazard")
	reset()
