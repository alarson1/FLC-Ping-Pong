extends Node3D

@export var ball_start_position: Vector3 = Vector3(0, 2, 0)
@onready var ball: RigidBody3D = $Ball

var normal_gravity_scale: float = 1.0
var gravity_enabled: bool = false

func _ready():
	normal_gravity_scale = ball.gravity_scale
	reset_ball()

func _physics_process(delta):
	if not gravity_enabled and ball.get_contact_count() > 0:
		ball.gravity_scale = normal_gravity_scale
		gravity_enabled = true

func reset_ball():
	ball.global_position = ball_start_position
	ball.linear_velocity = Vector3.ZERO
	ball.angular_velocity = Vector3.ZERO
	ball.gravity_scale = 0.0
	gravity_enabled = false
