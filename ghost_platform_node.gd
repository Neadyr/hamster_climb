extends Node2D

var is_overlapping := false
var overlap_count := 0

func _ready():
	var sensor = get_node("contact_sensor")
	sensor.monitoring = true
	sensor.monitorable = true
	# Choisis ce que tu veux détecter :
	# sensor.collision_layer = 0    # (facultatif)
	# sensor.collision_mask = 1<<2  # ex: voir seulement le layer 2

	sensor.connect("body_entered", Callable(self, "_on_sensor_body_entered"))
	sensor.connect("body_exited",  Callable(self, "_on_sensor_body_exited"))
	sensor.connect("area_entered", Callable(self, "_on_sensor_area_entered"))
	sensor.connect("area_exited",  Callable(self, "_on_sensor_area_exited"))

func _on_sensor_body_entered(_b): _overlap(+1)
func _on_sensor_body_exited(_b):  _overlap(-1)
func _on_sensor_area_entered(_a): _overlap(+1)
func _on_sensor_area_exited(_a):  _overlap(-1)

func _overlap(delta:int) -> void:
	
	overlap_count = max(overlap_count + delta, 0)
	is_overlapping = overlap_count > 0
	print(overlap_count)
