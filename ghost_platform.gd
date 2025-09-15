extends StaticBody2D


func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))
	
func _on_body_entered(body):
	get_parent().CAN_BE_SUMMONED = false
func _on_body_exited(body):
	get_parent().CAN_BE_SUMMONED = true
