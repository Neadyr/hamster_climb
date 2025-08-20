extends Node2D

func _physics_process(_delta: float) -> void:
	rotation = -get_parent().rotation
