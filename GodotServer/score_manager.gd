extends Node3D


var red_player_score: int = 0
var blue_player_score: int = 0

var last_hitter: int = 0 # 0 is neither player, 1 = red player, 2 = blue player
var legal_bounce_happened: bool = false
var rally_over: bool = false


func reset_rally() -> void:
	last_hitter = 0
	legal_bounce_happened = false
	rally_over = false


func on_paddle_hit(player_id: int) -> void:
	if rally_over:
		return
	
	last_hitter = player_id
	legal_bounce_happened = false


func on_table_bounce(side_id: int) -> void:
	if rally_over:
		return
	
	if last_hitter == 0:
		return
	
	if side_id == last_hitter:
		award_point(opponent_of(last_hitter))
		return
	
	if side_id != last_hitter:
		if legal_bounce_happened:
			award_point(last_hitter)
		else:
			legal_bounce_happened = true


func on_floor_hit() -> void:
	if rally_over:
		return
	
	if last_hitter == 0:
		return
	
	if legal_bounce_happened:
		award_point(last_hitter)
	else:
		award_point(opponent_of(last_hitter))


func opponent_of(player_id: int) -> int:
	if player_id == 1:
		return 2
	elif player_id == 2:
		return 1
	return 0

func award_point(player_id: int) -> void:
	if rally_over:
		return
	rally_over = true
	if player_id == 1:
		red_player_score += 1
	elif player_id == 2:
		blue_player_score += 1
	
	print("Point to Player ", player_id)
	print("Score: ", red_player_score, " - ", blue_player_score)
