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
		if Input.is_action_pressed("rightjoy_left") or Input.is_action_pressed("rightjoy_right") or Input.is_action_pressed("rightjoy_up") or Input.is_action_pressed("rightjoy_down"):
			var right_joystick_x = Input.get_joy_axis(0, JOY_AXIS_RIGHT_X )
			var right_joystick_y = Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y )
			var joystick_direction = Vector2(right_joystick_x,right_joystick_y).normalized()
			LAST_ANGLE = joystick_direction.angle()
			rotation = joystick_direction.angle()
		if Input.is_action_just_released("rightjoy_left") or Input.is_action_just_released("rightjoy_right") or Input.is_action_just_released("rightjoy_up") or Input.is_action_just_released("rightjoy_down"):
			rotation = LAST_ANGLE
