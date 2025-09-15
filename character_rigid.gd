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
var platform = preload("res://summoned_platform.tscn")
var ghost_platform = preload("res://ghost_platform.tscn")
var CURRENT_G_PLATFORM
var CURRENT_SUMMONED_PLATFORM
var LAST_PLATFORM_ANGLE
var BOOM_CHARGE = 0
var CAN_SUMMON = true
var SUMMON_WAS_CANCELLED = false
var CAN_BOOM = true
var BOOM_CD = 0.1
var BOOM_LOCK = false
var BOOM_CD_VALUE = 0
var BOOM_WAS_CANCELLED = false
@onready var sat = $"./counter_rotate/character_satelite"
@onready var sat_pos_getter = $"./counter_rotate/character_satelite/satelite_sprite"


# FEAT => summoned platform must be unavailable somehow from the ground


func _ready():
	contact_monitor = true
	max_contacts_reported = 4
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))

func _input(event):
	if event is InputEventKey:
		LAST_INPUT = "keyboard"
	elif event is InputEventJoypadMotion or event is InputEventJoypadButton:
		LAST_INPUT = "joypad"
		
func _process(_delta):
	if Input.is_action_just_pressed("reset"):
		restart()
		
func _physics_process(delta):
	if BOOM_CD_VALUE < BOOM_CD and BOOM_LOCK:
		BOOM_CD_VALUE += delta
		CAN_BOOM = false
	else:
		BOOM_LOCK = false

	var sat_pos = sat_pos_getter.global_position
	
	if IN_ZONE:
		gravity_scale = 0
	else:
		gravity_scale = 1
		
	if Input.is_action_just_pressed("platform") and CAN_SUMMON:
		var summoned_ghost_platform = ghost_platform.instantiate()
		get_parent().add_child(summoned_ghost_platform)
		CURRENT_G_PLATFORM = summoned_ghost_platform
		CURRENT_G_PLATFORM.position = sat_pos
	if Input.is_action_pressed("platform") and CAN_SUMMON:
		sat.IS_LOCKED = true
		Engine.time_scale = lerp(Engine.time_scale, 0.1, 0.6)
		if not Input.is_action_pressed("rotate_platform"):
			if Input.is_action_pressed("leftjoy_left") or Input.is_action_pressed("leftjoy_right") or Input.is_action_pressed("leftjoy_up") or Input.is_action_pressed("leftjoy_down"):
				
				var left_joystick_x = Input.get_joy_axis(0, JOY_AXIS_LEFT_X)
				var left_joystick_y = Input.get_joy_axis(0, JOY_AXIS_LEFT_Y)
				var joystick_direction = Vector2(left_joystick_x,left_joystick_y).normalized()
				
				CURRENT_G_PLATFORM.position += joystick_direction * delta * 10000
		else:
			
			if Input.is_action_pressed("leftjoy_left") or Input.is_action_pressed("leftjoy_right") or Input.is_action_pressed("leftjoy_up") or Input.is_action_pressed("leftjoy_down"):
				var left_joystick_x = Input.get_joy_axis(0, JOY_AXIS_LEFT_X)
				var left_joystick_y = Input.get_joy_axis(0, JOY_AXIS_LEFT_Y)
				var joystick_direction = Vector2(left_joystick_x,left_joystick_y).normalized()
				LAST_PLATFORM_ANGLE = joystick_direction.angle() + PI/2
				CURRENT_G_PLATFORM.rotation = joystick_direction.angle() + PI/2
		
		var distance = (CURRENT_G_PLATFORM.position - self.position).length()
		print("overlapping ?", CURRENT_G_PLATFORM.is_overlapping)
		if not (CURRENT_G_PLATFORM.is_overlapping):
			CURRENT_G_PLATFORM.get_node("contact_sensor/ghost_color").modulate = Color.hex(0x6bffda40)
		else:
			CURRENT_G_PLATFORM.get_node("contact_sensor/ghost_color").modulate = Color.hex(0xfed3e640)
				
		if Input.is_action_just_released("rightjoy_left") or Input.is_action_just_released("rightjoy_right") or Input.is_action_just_released("rightjoy_up") or Input.is_action_just_released("rightjoy_down"):
			CURRENT_G_PLATFORM.rotation = LAST_PLATFORM_ANGLE
		if Input.is_action_just_pressed("cancel"):
			Input.action_release("platform")
			CURRENT_G_PLATFORM.queue_free()
			SUMMON_WAS_CANCELLED = true
			sat.IS_LOCKED = false
			
	else:
		Engine.time_scale = lerp(Engine.time_scale, 1.0, 0.1)
	if Input.is_action_just_released("platform") and CAN_SUMMON:
		if not SUMMON_WAS_CANCELLED:
			sat.IS_LOCKED = false
			var distance = (CURRENT_G_PLATFORM.position - self.position).length()
			if not (CURRENT_G_PLATFORM.is_overlapping): # Should detect a collision instead of plain distance, feels weird
				if CURRENT_SUMMONED_PLATFORM:
					CURRENT_SUMMONED_PLATFORM.queue_free()
				var summoned_platform = platform.instantiate()
				CURRENT_SUMMONED_PLATFORM = summoned_platform
				summoned_platform.position = CURRENT_G_PLATFORM.global_position
				summoned_platform.rotation = CURRENT_G_PLATFORM.rotation
				CURRENT_G_PLATFORM.queue_free()
				get_parent().add_child(summoned_platform)
				CAN_SUMMON = false
			else:
				CURRENT_G_PLATFORM.queue_free()
		else:
			SUMMON_WAS_CANCELLED = false
		
	if Input.is_action_pressed("boom") and CAN_BOOM and BOOM_LOCK == false:
		if BOOM_CHARGE < 3:
			BOOM_CHARGE += delta
			print(BOOM_CHARGE)
		if Input.is_action_just_pressed("cancel"):
			Input.action_release("boom")
			BOOM_WAS_CANCELLED = true
			BOOM_CHARGE = 0
	if Input.is_action_just_released('boom') and CAN_BOOM and BOOM_LOCK == false:
		if not BOOM_WAS_CANCELLED:
			var satelite_direction = Vector2.RIGHT.rotated(sat.rotation)
			apply_central_impulse(satelite_direction * 600 * -1 * BOOM_CHARGE)
			BOOM_CHARGE = 0
			CAN_BOOM = false
			BOOM_LOCK = true
			BOOM_CD_VALUE = 0
		else:
			BOOM_WAS_CANCELLED = false

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
	if body.is_in_group("repel") or body.is_in_group("platform_back"):
		print("RRRRREPEEEEL")
		var anim_node = body.get_parent().get_node("pop_anim")
		anim_node.play("pop")
		await anim_node.animation_finished
		body.get_parent().queue_free()
	if body.is_in_group("ground"):
		print("Poc, j'ai touché le sol")
		IS_IN_AIR = false
	elif body.is_in_group("ice"):
		IS_ON_ICE = true
func _on_body_exit(body):
	if body.is_in_group("ground"):
		IS_IN_AIR = true
	elif body.is_in_group("ice"):
		IS_ON_ICE = false

func _integrate_forces(state):
	var collision = state.get_contact_collider_object(0)

	if collision:
		if state.get_contact_collider_object(0).is_in_group("ground"):
			CAN_BOOM = true
			CAN_SUMMON = true
		if state.get_contact_collider_object(0).is_in_group("repel"):
			var normal = state.get_contact_local_normal(0)
			apply_central_impulse(normal * 600)
			print("YEET")
	
func restart():
	get_tree().reload_current_scene()
