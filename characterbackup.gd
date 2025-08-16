extends CharacterBody2D

const SPEED = 500.0
const AIRSPEED = 800
const JUMP_VELOCITY = -600
const WALL_JUMP_VELOCITY = 200
var CAN_WALL_JUMP = true
var CAN_DASH = true
var IS_DASHING = false
var DASH_TIMER
var DASH_TIME = 0.3
var DASH_SPEED = 2000
var DASH_COOLDOWN = 0.0
var DASH_CD_RESET = 3.0
var PREVIOUS_VELOCITY = Vector2(0,0)
var ACCUMULATED_VELOCITY = 1.0
var IS_CHARGING = false
var IS_SPEEDING = false
var SPEED_TIMER = 3.0
# Récupère la gravité par défaut du projet
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	if (PREVIOUS_VELOCITY != velocity):
		print(PREVIOUS_VELOCITY)
		PREVIOUS_VELOCITY = velocity
	move_and_slide()
	handle_movement(delta)

func start_dash():
	IS_DASHING = true
	DASH_TIMER = DASH_TIME
	var direction = Vector2(
	Input.get_axis("ui_left", "ui_right"),
	Input.get_axis("ui_up", "ui_down")
	).normalized()
	velocity = direction * DASH_SPEED
	CAN_DASH = false

func handle_movement(delta):
	var dir = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	# if IS_DASHING:
	# 	DASH_TIMER -= delta
	# 	velocity = velocity.normalized() * DASH_SPEED
	# 	if DASH_TIMER < 0.1:
	# 		velocity = velocity.normalized() * 600
	# 		IS_DASHING = false
	# else:
	# 	DASH_COOLDOWN -= delta
	# if not IS_DASHING:
	# if is_on_floor():
	# 		if not CAN_WALL_JUMP:
	# 			CAN_WALL_JUMP = true
	# 		if not CAN_DASH:
	# 			CAN_DASH = true
	# 		if IS_SPEEDING:
	# 			SPEED_TIMER -= delta
	# 			velocity.x = dir * SPEED * ACCUMULATED_VELOCITY
	# 			if (SPEED_TIMER < 0):
	# 				ACCUMULATED_VELOCITY = lerp(ACCUMULATED_VELOCITY, 1.0, 0.1)
	# 			if (ACCUMULATED_VELOCITY < 1.1):
	# 				IS_SPEEDING = false
	# 				ACCUMULATED_VELOCITY = 1
	# 			# Figure it out, looking to make the character speed fast and decreases speed to go back to regular speed, lerp is an idea
	# 		if not IS_CHARGING and not IS_SPEEDING:
	# 			velocity.x = dir * SPEED
	# 	else:
		# if (velocity.x <= 550 and velocity.x > -550):
	velocity.x += dir * SPEED * delta
		# else:
		# 	if(velocity.x > 0):
		# 		velocity.x = 500
		# 	else:
		# 		velocity.x = -500
	# if CAN_DASH and Input.is_action_just_pressed("dash"):
	# 	start_dash()
	# if is_on_floor() and Input.is_action_just_pressed("jump"):
	# 	velocity.y = JUMP_VELOCITY
	if Input.is_action_pressed("slow"):
		Engine.time_scale = lerp(Engine.time_scale, 0.1, 0.6)
	else:
		Engine.time_scale = lerp(Engine.time_scale, 1.0, 0.1)
	# Sonic-dash
	# if Input.is_action_pressed("sonic"):
	# 	IS_CHARGING = true
	# 	velocity = velocity.lerp(Vector2(0, velocity.y), 0.1)
	# 	if ACCUMULATED_VELOCITY < 6:
	# 		ACCUMULATED_VELOCITY += delta * 2
	# if Input.is_action_just_released("sonic"):
	# 	IS_CHARGING = false
	# 	IS_SPEEDING = true
	# if is_on_wall_only() and CAN_WALL_JUMP and Input.is_action_just_pressed("jump") and (Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right")):
	
	var collision = get_slide_collision(0)
	if collision and PREVIOUS_VELOCITY > Vector2(1, 1):
		var collider = collision.get_collider()
		if collider.is_in_group("wall"):
			velocity = PREVIOUS_VELOCITY.bounce(collision.get_normal()) * 0.8
		elif collider.is_in_group("ground"):
			velocity = PREVIOUS_VELOCITY.bounce(collision.get_normal()) * 0.4
	# 		CAN_WALL_JUMP = false
	# 		velocity.y = JUMP_VELOCITY
	# 		velocity.x = WALL_JUMP_VELOCITY * collision.get_normal().x
	# if not is_on_floor():
	# 	if not IS_DASHING:
	# 		if is_on_wall_only() and (Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right")) and velocity.y >= -50:
	# 			velocity = velocity.lerp(Vector2(velocity.x, 100), 0.1)
	# 		else:
	velocity.y += gravity * delta
