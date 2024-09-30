extends "res://pieces/piece.gd"

class_name Rook

func get_valid_moves() -> Array[Vector2]:
	var valid_moves: Array[Vector2] = []
	var current_pos := grid_position

	## Out of Lives
	#if damaged == true and lives < 0:
		#print("???")
		#return valid_moves

	# Rook moves vertically and horizontally
	# Check vertical (up and down)
	for y_offset: int in [-1, 1]:  # -1 for up, 1 for down
		var check_pos := current_pos + Vector2(0, y_offset)
		while board.is_within_bounds(check_pos):
			if board.has_piece_at(check_pos):
				if board.has_enemy_piece_at(check_pos, team):
					valid_moves.append(check_pos)  # Can capture
				break  # Blocked by piece (friendly or enemy)
			valid_moves.append(check_pos)
			check_pos += Vector2(0, y_offset)  # Keep moving in the same direction

	# Check horizontal (left and right)
	for x_offset: int in [-1, 1]:  # -1 for left, 1 for right
		var check_pos := current_pos + Vector2(x_offset, 0)
		while board.is_within_bounds(check_pos):
			if board.has_piece_at(check_pos):
				if board.has_enemy_piece_at(check_pos, team):
					valid_moves.append(check_pos)  # Can capture
				break  # Blocked by piece (friendly or enemy)
			valid_moves.append(check_pos)
			check_pos += Vector2(x_offset, 0)  # Keep moving in the same direction

	return valid_moves
