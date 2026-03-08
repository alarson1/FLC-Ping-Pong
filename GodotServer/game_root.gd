extends Node3D

var ball_start_position: Vector3 = Vector3(0, 1, -1.5)
@onready var ball: RigidBody3D = $Ball
@onready var paddle = $Paddle1
@onready var reset_box = $ResetBox


var normal_gravity_scale := 1.0
var gravity_enabled := false
var can_reset := true


func _ready():
	normal_gravity_scale = ball.gravity_scale
	ball.body_entered.connect(_on_ball_body_entered)
	reset_ball()
	
	
	
func _process(delta):
	if can_reset and paddle.global_position.distance_to(reset_box.global_position) < 0.25:
		print("Reset Ball")
		reset_ball()
		can_reset = false
		await get_tree().create_timer(0.5).timeout
		can_reset = true

func reset_ball(): # Sets the ball to have gravity off and in a preset position on startup
	ball.freeze = true
	ball.global_position = ball_start_position
	ball.linear_velocity = Vector3.ZERO
	ball.angular_velocity = Vector3.ZERO
	ball.gravity_scale = 0.0
	gravity_enabled = false
	ball.freeze = false

func _on_ball_body_entered(body):
	if not gravity_enabled:
		ball.gravity_scale = normal_gravity_scale
		gravity_enabled = true
		print("gravity turned on after collision with ", body.name)

	if body.name == "Paddle1":
		print("Paddle velocity: ", paddle.tracked_velocity)
		ball.linear_velocity += paddle.tracked_velocity * 0.8
		print("Ball velocity after hit: ", ball.linear_velocity)
		
		

		

		
