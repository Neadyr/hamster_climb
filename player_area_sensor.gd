extends Area2D

func _ready():
	connect("area_entered", Callable(self, "_on_area_entered"))
	connect("area_exited", Callable(self, "_on_area_exited"))

func _on_area_entered(area):
	if area.is_in_group("black_hole"):
		get_parent().IN_ZONE = true

func _on_area_exited(area):
	if area.is_in_group("black_hole"):
		get_parent().IN_ZONE = false
