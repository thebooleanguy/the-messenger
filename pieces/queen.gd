extends "res://pieces/piece.gd"

func get_valid_moves() -> Array:
	var valid_moves: Array = []
	var current_pos := grid_position

	# Directions for movement: vertical, horizontal, and diagonal
	var directions := [
		Vector2(0, 1),   # Up
		Vector2(0, -1),  # Down
		Vector2(1, 0),   # Right
		Vector2(-1, 0),  # Left
		Vector2(1, 1),   # Up-Right (Diagonal)
		Vector2(-1, -1), # Down-Left (Diagonal)
		Vector2(1, -1),  # Down-Right (Diagonal)
		Vector2(-1, 1)   # Up-Left (Diagonal)
	]

	# Check each direction
	for direction: Vector2 in directions:
		var check_pos: Vector2 = current_pos + direction
		while board.is_within_bounds(check_pos):
			if board.has_piece_at(check_pos):
				if board.has_enemy_piece_at(check_pos, team):
					valid_moves.append(check_pos)  # Can capture
				break  # Blocked by piece (friendly or enemy)
			valid_moves.append(check_pos)
			check_pos += direction  # Continue moving in the same direction

	return valid_moves
