extends RigidBody3D

@export var max_ball_speed : float = 13.0
@export var bounce_efficiency : float = 0.6	# ball dies on the paddle if no swing
@export var arm_impact : float = 0.4		# only 15% of swing speed added

var prev_ball_pos : Vector3
var hit_timer : float = 0.0

func _ready():
	# enabled to allow get_colliding_bodies to work
	contact_monitor = true
	max_contacts_reported = 5
	prev_ball_pos = global_position

func _physics_process(delta):
	if hit_timer > 0.0:
		hit_timer -= delta
	
	# check for overlapping paddles every physics tick
	var bodies = get_colliding_bodies()
	
	for body in bodies:
		if hit_timer <= 0.0 and "Paddle" in body.name:
			handle_paddle_hit(body)
			break # prevent multiple hits in one frame

	prev_ball_pos = global_position

func handle_paddle_hit(paddle):
	var ball_vel_before = linear_velocity
	var p_vel = paddle.get_tracked_velocity()
	
	# using the y axis as identified for the paddle face
	var face_normal = paddle.global_transform.basis.y.normalized()
	
	# isolate the velocity moving directly forward/backward
	var v_ball_dot = ball_vel_before.dot(face_normal)
	var v_paddle_dot = p_vel.dot(face_normal)
	
	# calculate the exit speed with the new dampened multipliers
	var exit_speed = (v_paddle_dot * arm_impact) - (v_ball_dot * bounce_efficiency)
	
	# keep the side to side momentum of the ball but swap the forward speed
	var tangential_vel = ball_vel_before - (face_normal * v_ball_dot)
	var final_velocity = tangential_vel + (face_normal * exit_speed)
	
	# apply the new velocity to the ball
	linear_velocity = final_velocity
	
	if linear_velocity.length() > max_ball_speed:
		linear_velocity = linear_velocity.normalized() * max_ball_speed
	
	# cooldown of hits, at 480hz must be > .1
	hit_timer = 0.15 
	
	# push ball out of paddle volume to prevent double hits
	global_position += face_normal * 0.08
	
	# telemetry to debug the power curve
	print("--- DAMPENED IMPACT ---")
	print("  Swing Speed: ", snappedf(v_paddle_dot, 0.1), " | Ball Out: ", snappedf(exit_speed, 0.1))
	print("  Final Speed: ", snappedf(linear_velocity.length(), 0.1))

# game root calls this
func reset(start_position: Vector3):
	global_position = start_position
	prev_ball_pos = start_position
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	hit_timer = 0.0
