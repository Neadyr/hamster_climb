extends RigidBody2D

var SPEED = 500.0
var ACCUMULATED_VELOCITY = 0.0
var IS_CHARGING = false
var IN_ZONE = false
var LAST_INPUT
var IS_IN_AIR = false
var IS_ON_ICE = false
var TORQUE_POWER = 50000
var ACCELERATION = 2

@onready var sat = $"./counter_rotate/character_satelite"

func _ready():
	contact_monitor = true
	max_contacts_reported = 4
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exit", Callable(self, "_on_body_exit"))

func _input(event):
	if event is InputEventKey:
		LAST_INPUT = "keyboard"
	elif event is InputEventJoypadMotion or event is InputEventJoypadButton:
		LAST_INPUT = "joypad"
		
func _process(delta):
	if Input.is_action_just_pressed("reset"):
		self.global_position = Vector2(0, 0)
		angular_velocity = 0
		linear_velocity = Vector2(0,0)
		
func _physics_process(delta):
	if IN_ZONE:
		gravity_scale = 0
	else:
		gravity_scale = 1
	#if Input.is_action_pressed('grap'):
		#var mouse = get_global_mouse_position()
		#var get_positions = (mouse - self.global_position)
		#var distance = get_positions.length()
		#var direction = get_positions.normalized()
		#if distance > 600:
			#apply_central_force((direction * 2000) * ( min((distance - 600), 300) / 10))
	if Input.is_action_just_pressed('boom'):
		var satelite_direction = Vector2.RIGHT.rotated(sat.rotation)
		#var mouse_pos = get_global_mouse_position()
		#var distance_from_mouse = (mouse_pos - self.global_position).length()
		#if distance_from_mouse < 300 and distance_from_mouse > 30:
		apply_central_impulse(satelite_direction * (600 ) * -1)
	if not IS_CHARGING:
		if IS_ON_ICE:
			SPEED = SPEED / 2
		if Input.is_action_just_pressed('ui_right') or Input.is_action_just_pressed('ui_left'):
			ACCELERATION = 2
		if Input.is_action_pressed('ui_right'):
			apply_central_force(Vector2(SPEED, 0))
			ACCELERATION += delta
			#apply_torque(TORQUE_POWER * ACCELERATION)
			#print(TORQUE_POWER * ACCELERATION)
		if Input.is_action_pressed('ui_left'):
			#apply_torque(-TORQUE_POWER * ACCELERATION)
			#print(TORQUE_POWER * ACCELERATION)
			
			apply_central_force(Vector2(-SPEED, 0))
		if IN_ZONE:
			if Input.is_action_pressed('ui_up'):
				apply_central_force(Vector2(0, -SPEED))
			if Input.is_action_pressed('ui_down'):
				apply_central_force(Vector2(0, SPEED))
		
	#if Input.is_action_just_pressed("jump"):
		#if not IS_IN_AIR:
			#apply_central_impulse(Vector2(0, -500))
	#if Input.is_action_just_pressed("sonic"):
		#IS_CHARGING = true
	#if Input.is_action_pressed("sonic"):
		#stop_motion()
		#ACCUMULATED_VELOCITY += delta
	#if Input.is_action_just_released("sonic"):
		#gravity_scale = 1.0
		#var force = 1500 * ACCUMULATED_VELOCITY
		#if LAST_INPUT == "keyboard":
			#var mouse_pos = get_global_mouse_position()
			#var keyboard_direction = (mouse_pos - self.global_position).normalized()
			#if keyboard_direction.x < 0:
				#keyboard_direction.x = -1
			#else:
				#keyboard_direction.x = 1
			#apply_central_impulse(Vector2(keyboard_direction.x, 0) * force)
			#
		#elif LAST_INPUT == "joypad":
			#var lx = Input.get_joy_axis(0, JOY_AXIS_LEFT_X )
			#var joystick_direction = Vector2(lx, 0).normalized()
			#if joystick_direction.x < 0:
				#joystick_direction.x = -1
			#else:
				#joystick_direction.x = 1
			#apply_central_impulse(joystick_direction * force)
		#IS_CHARGING = false
		#ACCUMULATED_VELOCITY = 0.3
		
func _on_body_entered(body):
	if body.is_in_group("ground"):
		IS_IN_AIR = false
	elif body.is_in_group("ice"):
		IS_ON_ICE = true
func _on_body_exit(body):
	if body.is_in_group("ground"):
		IS_IN_AIR = true
	elif body.is_in_group("ice"):
		IS_ON_ICE = false

func _integrate_forces(state):
	var count = state.get_contact_count()
	if count == 0:
		IS_IN_AIR = true
	

func stop_motion():
	gravity_scale = 0
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0
