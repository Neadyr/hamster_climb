extends CharacterBody2D

const SPEED = 500.0
const AIRSPEED = 800
const JUMP_VELOCITY = -600
var PREVIOUS_VELOCITY = Vector2(0.0,0.0)
var ACCUMULATED_VELOCITY = 1.0
var IS_CHARGING = false
var IS_SPEEDING = false
var SPEED_TIMER = 3.0
var FRICTION = 20
var IS_MOVING = false
var BOUNCE_FACTOR = 0.6
# Récupère la gravité par défaut du projet
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	if (PREVIOUS_VELOCITY != velocity):
		PREVIOUS_VELOCITY = velocity
	move_and_slide()
	handle_movement(delta)

func handle_movement(delta):
	var dir = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	var collision = get_slide_collision(0)
	if (Input.is_action_pressed("ui_right") or Input.is_action_pressed("ui_left")):
		IS_MOVING = true
	else:
		IS_MOVING = false
	velocity.x += dir * SPEED * delta
	#print("Viteeeesse : ",velocity.length())
	#if Input.is_action_just_pressed("test"):
		
	if Input.is_action_pressed("slow"):
		Engine.time_scale = lerp(Engine.time_scale, 0.1, 0.6)
	else:
		Engine.time_scale = lerp(Engine.time_scale, 1.0, 0.1)
		
	if is_on_floor():
		if collision:
			if (collision.get_normal().y < -0.95 and collision.get_normal().y > -1.05) and (collision.get_normal().x > -0.1 and collision.get_normal().x < 0.1):
				if not IS_MOVING:
					print("IM NOT MOVING")
					velocity.x = lerp(velocity.x, 0.0, 0.1)
			else:
				print("en pente", collision.get_normal())
				velocity += Vector2(collision.get_normal()) * 50
			var collider = collision.get_collider()
			if collider.is_in_group("wall"):
				var bounced_velocity = PREVIOUS_VELOCITY.bounce(collision.get_normal()) * BOUNCE_FACTOR
				velocity.x = bounced_velocity.x
			
			if collider.is_in_group("ground"):
				if (PREVIOUS_VELOCITY.y > 20):
					velocity = PREVIOUS_VELOCITY.bounce(collision.get_normal()) * BOUNCE_FACTOR
				else: 
					velocity.y = 0
	else:
		velocity.y += gravity * delta
			
