extends Area2D

var IS_AIMING = false

func _input(event):
	if event is InputEventJoypadMotion:
		if event.axis == 2:
			IS_AIMING = true
			
func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("aiming"):
		print("AIMING MOTHER FUCKER")
	else: 
		print("NAH")
	var right_joystick_x = Input.get_joy_axis(0, JOY_AXIS_RIGHT_X )
	var right_joystick_y = Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y )
	var joystick_direction = Vector2(right_joystick_x,right_joystick_y).normalized()

	rotation = joystick_direction.angle()
