extends StaticBody3D # Or AnimatableBody3D

var previous_position: Vector3
var tracked_velocity: Vector3 = Vector3.ZERO
var velocity_history: Array[Vector3] = []

@export var average_window: int = 16 # number of frames velocity is averaged over
@export var velocity_deadzone: float = 0.15 # Ignores micro-twitches

func _ready():
	previous_position = global_position

func _physics_process(delta: float) -> void:
	# Only calculates if the Vicon data actually changed 
	if global_position == previous_position:
		return

	var current_velocity: Vector3 = (global_position - previous_position) / delta
	
	# 2.If the movement is jitter, treat as zero
	if current_velocity.length() < velocity_deadzone:
		current_velocity = Vector3.ZERO

	velocity_history.append(current_velocity)
	
	if velocity_history.size() > average_window:
		velocity_history.pop_front()
	
	# average of velcoity of set number of frames
	var sum: Vector3 = Vector3.ZERO
	for v in velocity_history:
		sum += v
	
	tracked_velocity = sum / velocity_history.size()
	previous_position = global_position

func get_tracked_velocity() -> Vector3:
	return tracked_velocity
