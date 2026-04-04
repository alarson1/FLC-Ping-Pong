extends Node3D

var ball_start_position: Vector3 = Vector3(0, 1, -1.5)
var last_contacts: Array[StringName] = [&"default", &"default", &"default"]
var bounce_counterR: int = 0
var bounce_counterB: int = 0
var red_score: int
var blue_score: int
var rally_over: bool = false
var serve_over: bool = false
var contact_timer: float = 0.0
@onready var ball: RigidBody3D = $Ball
@onready var paddle = $RedPaddle
@onready var reset_box = $ResetBox
@onready var Bluepaddle = $BluePaddle


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
	if contact_timer > 0:
		contact_timer -= 1

func reset_ball(): # Sets the ball to have zero gravity
	#on startup or when rest box touched
	ball.freeze = true
	ball.global_position = ball_start_position
	ball.linear_velocity = Vector3.ZERO
	ball.angular_velocity = Vector3.ZERO
	ball.gravity_scale = 0.0
	gravity_enabled = false
	ball.freeze = false
	ball.prev_ball_pos = ball_start_position
	rally_over = false
	serve_over = false
	bounce_counterR = 0
	bounce_counterB = 0
	last_contacts.fill(&"default")


func _on_ball_body_entered(body):
	if not gravity_enabled:
		ball.gravity_scale = normal_gravity_scale
		gravity_enabled = true
		print("gravity turned on after collision with ", body.name)
	if contact_timer <= 0:
		_score(body)
		
func _score(body):
	contact_timer = 0.15
	last_contacts.push_front(body.name)
	if last_contacts.size() > 3:
		last_contacts.pop_back()
		
	match last_contacts[0]: # updates various counters
		# based on which object the ball last contacted
		&"RedPaddle":
			bounce_counterR = 0
			bounce_counterB = 0
		&"BluePaddle":
			bounce_counterR = 0
			bounce_counterB = 0
		&"Table":
			if ball.global_position.z < 0:
				bounce_counterR += 1
				if bounce_counterR >= 2 && rally_over == false:
					blue_score += 1;
					rally_over = true
			elif ball.global_position.z > 0:
				bounce_counterB += 1
				if bounce_counterB >= 2 && rally_over == false:
					red_score += 1;
					rally_over = true
		&"Net":
			if last_contacts[1] == &"RedPaddle" && rally_over == false:
				blue_score += 1
				rally_over = true
			elif last_contacts[1] == &"BluePaddle" && rally_over == false:
				red_score += 1
				rally_over = true
		&"Floor Hitbox":
			if ball.global_position.z < 0 && (last_contacts[1] == &"BluePaddle" || last_contacts[2] == &"BluePaddle") && rally_over == false:
				blue_score += 1
				rally_over = true
			elif ball.global_position.z > 0 && (last_contacts[1] == &"RedPaddle" || last_contacts[2] == &"RedPaddle") && rally_over == false:
				red_score += 1
				rally_over = true
