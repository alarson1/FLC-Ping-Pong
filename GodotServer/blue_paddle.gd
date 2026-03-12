extends StaticBody3D

var previous_position: Vector3
var tracked_velocity: Vector3 = Vector3.ZERO

func _ready():
	previous_position = global_position

func _process(delta):
	BLUEcalculate_velocity(delta)


func BLUEcalculate_velocity(delta):
	if delta > 0:
		tracked_velocity = (global_position - previous_position) / delta
		#print("Tracked velocity: ", tracked_velocity)
	previous_position = global_position
