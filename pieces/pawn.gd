extends "res://pieces/piece.gd"

func _ready() -> void:
	pass 

func _process(_delta: float) -> void:
	pass


func get_valid_moves() -> Array:
	var valid_moves: Array = []
	var forward_direction := -1 if team == Team.WHITE else 1
	var current_pos := grid_position
	
	# Check if the pawn can move one square forward
	var forward_one := current_pos + Vector2(0, forward_direction)
	
	print("Current Position: ", current_pos)
	print("Forward Direction: ", forward_direction)
	
	if board.is_within_bounds(forward_one) and not board.has_piece_at(forward_one):
		valid_moves.append(forward_one)
		
		# Check for double-step if on the starting row on large grids
		#if board.GRID_SIZE > 5:
			#var start_row: int = board.GRID_SIZE - 2 if team == Team.WHITE else 1
			#if current_pos.y == start_row:
				#var forward_two := current_pos + Vector2(0, forward_direction * 2)
				#if board.is_within_bounds(forward_two) and not board.has_piece_at(forward_two):
					#valid_moves.append(forward_two)
	
	# Check diagonal captures
	var diagonal_left := current_pos + Vector2(-1, forward_direction)
	var diagonal_right := current_pos + Vector2(1, forward_direction)
	
	if board.is_within_bounds(diagonal_left) and board.has_enemy_piece_at(diagonal_left, team):
		valid_moves.append(diagonal_left)
		
	if board.is_within_bounds(diagonal_right) and board.has_enemy_piece_at(diagonal_right, team):
		valid_moves.append(diagonal_right)
	
	print(valid_moves)	
	return valid_moves
