extends RigidBody3D


var hit_strength: float = 0.8
var can_receive_hit := true

func _ready():
	continuous_cd = true
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.name == "Paddle 1" and can_receive_hit:
		if "tracked_velocity" in body:
			print("Paddle velocity: ", body.tracked_velocity)
			linear_velocity += body.tracked_velocity * hit_strength
			print("Ball velocity after hit: ", linear_velocity)
			
			can_receive_hit = false
			await get_tree().create_timer(0.1).timeout
			can_receive_hit = true
