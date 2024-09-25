extends "res://pieces/piece.gd"

func get_valid_moves() -> Array:
	var valid_moves: Array = []
	var current_pos := grid_position

	# All possible Knight moves (2 squares in one direction, then 1 square perpendicular)
	var knight_moves := [
		Vector2(2, 1),   # Move right 2, up 1
		Vector2(2, -1),  # Move right 2, down 1
		Vector2(-2, 1),  # Move left 2, up 1
		Vector2(-2, -1), # Move left 2, down 1
		Vector2(1, 2),   # Move up 2, right 1
		Vector2(1, -2),  # Move down 2, right 1
		Vector2(-1, 2),  # Move up 2, left 1
		Vector2(-1, -2)  # Move down 2, left 1
	]

	# Check each possible Knight move
	for move: Vector2 in knight_moves:
		var new_pos:Vector2 = current_pos + move
		if board.is_within_bounds(new_pos):
			if not board.has_piece_at(new_pos) or board.has_enemy_piece_at(new_pos, team):
				valid_moves.append(new_pos)  # Add move if empty or has enemy piece

	return valid_moves
