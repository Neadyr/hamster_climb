extends Area2D

var IS_AIMING = false
var LAST_ANGLE
var IS_LOCKED = false
func _input(event):
	if event is InputEventJoypadMotion:
		if event.axis == 2:
			IS_AIMING = true

func _physics_process(_delta: float) -> void:
	if IS_LOCKED == false:
		if Input.is_action_pressed("leftjoy_left") or Input.is_action_pressed("leftjoy_right") or Input.is_action_pressed("leftjoy_up") or Input.is_action_pressed("leftjoy_down"):
			var left_joystick_x = Input.get_joy_axis(0, JOY_AXIS_LEFT_X )
			var left_joystick_y = Input.get_joy_axis(0, JOY_AXIS_LEFT_Y )
			var joystick_direction = Vector2(left_joystick_x,left_joystick_y).normalized()
			LAST_ANGLE = joystick_direction.angle()
			rotation = joystick_direction.angle()
		if Input.is_action_just_released("leftjoy_left") or Input.is_action_just_released("leftjoy_right") or Input.is_action_just_released("leftjoy_up") or Input.is_action_just_released("leftjoy_down"):
			rotation = LAST_ANGLE
