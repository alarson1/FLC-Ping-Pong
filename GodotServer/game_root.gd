extends Node3D

var ball_start_position: Vector3 = Vector3(0, 1, -1.5)
var last_contacts: Array[StringName] = [&"default", &"default", &"default", &"default", &"default"]
var bounce_counterR: int = 0
var bounce_counterB: int = 0
var red_score: int = 0:
	set(value):
		red_score = value
		if red_score_label != null:
			(red_score_label.mesh as TextMesh).text = str(red_score)
		_update_serve()
var blue_score: int = 0:
	set(value):
		blue_score = value
		if blue_score_label != null:
			(blue_score_label.mesh as TextMesh).text = str(blue_score)
		_update_serve()
var rally_over: bool = false
var serve_over: bool = false
var contact_timer: float = 0.0
var normal_gravity_scale := 1.0
var gravity_enabled := false
var can_reset := true
@onready var ball: RigidBody3D = $Ball
@onready var paddle = $RedPaddle
@onready var reset_box = $ResetBox
@onready var Bluepaddle = $BluePaddle
@onready var red_score_label: MeshInstance3D = $Enviroment/RedScoreBoard
@onready var blue_score_label: MeshInstance3D = $Enviroment/BlueScoreBoard


func _ready():
	# default ball state and score
	normal_gravity_scale = ball.gravity_scale
	ball.body_entered.connect(_on_ball_body_entered)
	reset_ball()
	(red_score_label.mesh as TextMesh).text = str(red_score)
	(blue_score_label.mesh as TextMesh).text = str(blue_score)
	
func _process(delta):
	if can_reset and paddle.global_position.distance_to(reset_box.global_position) < 0.25:
		print("Reset Ball")
		reset_ball()
		can_reset = false
		await get_tree().create_timer(0.5).timeout
		can_reset = true
	if contact_timer > 0: # contact timer so only one contact body is logged per collision
		contact_timer -= 1

func reset_ball(): # Sets the ball to have zero gravity
	#on startup or when rest box touched, resets to default position,
	# and resets contact tracking
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
	if not gravity_enabled: # enables gravity on first contact
		ball.gravity_scale = normal_gravity_scale
		gravity_enabled = true
		print("gravity turned on after collision with ", body.name)
	if contact_timer <= 0: # calls contact tracking
		_score(body)
		
func _score(body): # tracks last four objects that the ball collided with,
	# and updates score and relevant counters.
	contact_timer = 0.15
	last_contacts.push_front(body.name)
	if last_contacts.size() > 5:
		last_contacts.pop_back()
		
	if last_contacts[4] != &"default":
		serve_over = true
		
	match last_contacts[0]:
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
			if ball.global_position.z < 0 && (bounce_counterR == 1) && (last_contacts[2] == &"BluePaddle" || last_contacts[3] == &"BluePaddle") && rally_over == false:
				blue_score += 1
				rally_over = true
			elif ball.global_position.z > 0 && (bounce_counterB == 1) && (last_contacts[2] == &"RedPaddle" || last_contacts[3] == &"RedPaddle") && rally_over == false:
				red_score += 1
				rally_over = true
			elif (bounce_counterR == 0 && bounce_counterB == 0):
				if (last_contacts[0] == &"BluePaddle") && (ball.global_position.z < 0) && (rally_over == false):
					red_score += 1
					rally_over = true
				elif (last_contacts[0] == &"RedPaddle") && (ball.global_position.z > 0) && (rally_over == false):
					blue_score += 1
					rally_over = true
func _update_serve():
	var total_score: int = red_score + blue_score
	var side_switch: bool = false
	if (total_score > 0) && ((total_score % 2) == 0):
		side_switch = !side_switch
	if side_switch == false:
		ball_start_position = Vector3(0, 1, -1.5)  # red serves
	elif side_switch == true:
		ball_start_position = Vector3(0, 1, 1.5)  # blue serves
		
# to track proper serve vs rally play
#if ball.global_position.z < 0 && (bounce_counterR == 1) && rally_over == false:
	#if (last_contacts[2] == &"BluePaddle") && (serve_over == true):
		#blue_score += 1
		#rally_over = true
	#elif (last_contacts[3] == &"BluePaddle") && (last_contacts[2] == &"Table") && (serve_over == false):
		#blue_score += 1
		#rally_over = true
#elif ball.global_position.z > 0 && (bounce_counterB == 1) && rally_over == false:
	#if (last_contacts[2] == &"RedPaddle") && (serve_over == true):
		#red_score += 1
		#rally_over = true
	#elif (last_contacts[3] == &"RedPaddle") && (last_contacts[2] == &"Table") && (serve_over == false):
		#red_score += 1
		#rally_over = true
	
