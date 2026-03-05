extends RigidBody3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# pass # Replace with function body.
	gravity_scale = 0
	contact_monitor = true
	body_entered.connect(_enable_gravity)
	
func _enable_gravity() -> void:
	gravity_scale = 1
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
