extends Node2D

class_name ChessBoard

const CHESS_TILE: PackedScene = preload("res://board/ChessTile.tscn")
var GRID_SIZE: int = 5
const TILE_SIZE: float = 63
const CENTERED_TILE_OFFSET := Vector2(TILE_SIZE / 2, TILE_SIZE / 2)
var CHESSBOARD_SIZE := TILE_SIZE * GRID_SIZE
var tile_grid: Array = []
var selected_piece: Node = null
var selected_tile: Node = null
var valid_move_tiles: Array = []
var turn: int = 1
var player_move_in_progress: bool = false

var current_level: int = 1
const LevelManager = preload("res://levels/level_manager.gd")
var level_manager: LevelManager

# Create a mapping of piece types to their scenes
var piece_scene_map: Dictionary = {
	"Pawn": preload("res://pieces/Pawn.tscn"),
	"Rook": preload("res://pieces/Rook.tscn"),
	"Queen": preload("res://pieces/Queen.tscn"),
	"Bishop": preload("res://pieces/Bishop.tscn"),
	"Knight": preload("res://pieces/Knight.tscn")
}

func _ready() -> void:
	# Center board on viewport
	position.x = (get_viewport_rect().size.x - CHESSBOARD_SIZE) / 2
	position.y = (get_viewport_rect().size.y - CHESSBOARD_SIZE) / 2
	draw_board()
	
	level_manager = LevelManager.new()  # Create an instance of the LevelManager
	load_current_level()

func load_current_level() -> void:
	var level_data = level_manager.load_level("level_" + str(current_level))  # Load the current level
	if level_data.size() > 0:
		setup_level(level_data)
	else:
		print("Level data not found!")
	
	# For Debugging Purposes
	#place_piece(piece_scene_map["Rook"], Vector2(2,0), 1)
	#place_piece(PAWN, Vector2(0,0), 0)
	#place_piece(PAWN, Vector2(1,3), 1)
	#place_piece(QUEEN, Vector2(0,1), 0)
	#place_piece(PAWN, Vector2(4,4), 1)
	#place_piece(QUEEN, Vector2(0,3), 0)
	#place_piece(QUEEN, Vector2(2,4), 1)
	#place_piece(BISHOP, Vector2(1,4), 0)
	#place_piece(KNIGHT, Vector2(4,3), 0)
	#move_piece(Vector2(2,0), Vector2(2,1))
	#print(has_piece_at(Vector2(2,11)))
	#print(has_enemy_piece_at(Vector2(2,1), 1))
	#print(tile_grid)

func _process(_delta: float) -> void:
	# For debugging purposes
	#if turn == 0:
		#ai_move_black_piece()
	if Input.is_action_pressed("restart"):
		load_current_level()
		pass
	pass

func draw_board() -> void:
	# Clear existing tiles from tile_grid if it already exists
	for row in tile_grid:
		for tile in row:
			tile.queue_free()  # Remove existing tiles
	tile_grid.clear()  # Clear the grid array
	
	for y in range(GRID_SIZE):
		# For it to be a 2D array
		var row := []
		for x in range(GRID_SIZE):
			var tile := CHESS_TILE.instantiate()
			tile.position = Vector2(x * TILE_SIZE, y * TILE_SIZE)
			tile.grid_position = Vector2(x, y)
			add_child(tile)
			tile.connect("tile_clicked", _on_tile_clicked)
			row.append(tile)
		tile_grid.append(row)


func place_piece(piece_scene: PackedScene, pos: Vector2, team: int) -> void:
	if is_within_bounds(pos):
		var tile: Node = tile_grid[pos.y][pos.x]
		if !tile.piece:
			var piece_instance := piece_scene.instantiate()
			piece_instance.position = tile.position + CENTERED_TILE_OFFSET
			piece_instance.set_team(team)
			piece_instance.grid_position = tile.grid_position
			add_child(piece_instance)
			tile.piece = piece_instance
	else:
		print("Out of bounds")


func move_piece(curr_pos: Vector2, new_pos: Vector2) -> void:
	if is_within_bounds(curr_pos) and is_within_bounds(new_pos):
		var tile_from: Node = tile_grid[curr_pos.y][curr_pos.x] 
		var tile_to: Node = tile_grid[new_pos.y][new_pos.x] 
		var piece: Node = tile_from.piece
		if piece:
			# Capture piece
			if tile_to.piece:
				tile_to.piece.queue_free()
			# Move piece
			piece.position = tile_to.position + CENTERED_TILE_OFFSET
			tile_to.piece = piece
			piece.grid_position = tile_to.grid_position
			tile_from.piece = null
	else:
		print("Out of bounds")



func setup_level(level_data: Dictionary) -> void:
	# Set the grid size from level data
	if "grid_size" in level_data:
		GRID_SIZE = level_data["grid_size"]
		draw_board()  # Call draw_board to create the board with the new size
		reset_board()
	else:
		print("Grid size not specified in level data.")

	# Place pieces based on level_data
	for piece_data in level_data["pieces"]:
		var piece_type: String = piece_data["type"]
		if piece_type in piece_scene_map:
			var piece_scene: PackedScene = piece_scene_map[piece_type]
			
			# Convert the position from Array to Vector2
			var position_array: Array = piece_data["position"]
			var position: Vector2 = Vector2(position_array[0], position_array[1])
			
			place_piece(piece_scene, position, piece_data["team"])
		else:
			print("Unknown piece type: " + piece_type)

func reset_board() -> void:
	# Logic to clear the board and reset the tile_grid
	turn = 1
	player_move_in_progress = false
	selected_piece = null
	selected_tile = null
	valid_move_tiles = []
	
	for y in range(GRID_SIZE):
		for x in range(GRID_SIZE):
			var tile: Node = tile_grid[y][x]
			if tile.piece:
				tile.piece.queue_free()  # Remove the piece from the scene
				tile.piece = null  # Clear the reference



### Player Controller ###
func _on_tile_clicked(grid_pos: Vector2) -> void:
	var clicked_tile: Node = tile_grid[grid_pos.y][grid_pos.x]
	
	# If no piece is currently selected
	if selected_piece == null:
		if clicked_tile.piece != null:
			selected_piece = clicked_tile.piece
			selected_tile = clicked_tile
			
			# Highlight the selected tile
			selected_tile.color_rect.color = Color(0.5, 0.5, 0.5, 0.8) 
			selected_tile.is_selected = true
			
			# Get valid moves for the selected piece
			valid_move_tiles = selected_piece.get_valid_moves()
			#print(valid_move_tiles)
			
			# Highlight all valid move tiles
			for move: Vector2 in valid_move_tiles:
				var tile: Node = tile_grid[move.y][move.x]
				tile.color_rect.color = Color(0.5, 0.5, 0.5, 0.5)
				tile.is_selected = true
				player_move_in_progress = true
	
	# If a piece is already selected
	else:
		if clicked_tile != selected_tile:
			# Check if the clicked tile is a valid move
			if grid_pos in valid_move_tiles:
				move_piece(selected_tile.grid_position, grid_pos)
				#last_moved_piece = selected_piece
				turn -= 1
				if (grid_pos.y == 0) and (selected_piece is Pawn) and (selected_piece.team == 1):
					print("You've won! Loading next level...")
					current_level += 1
					load_current_level()
					return
				else:
					ai_move_black_piece()
				
		# Unhighlight the selected tile and valid move tiles
		selected_tile.color_rect.color = selected_tile.color_rect_default_color
		selected_tile.is_selected = false
		for move: Vector2 in valid_move_tiles:
			var tile: Node = tile_grid[move.y][move.x]
			tile.color_rect.color = tile.color_rect_default_color
			tile.is_selected = false
			player_move_in_progress = false
		
		# Reset selection
		selected_piece = null
		selected_tile = null
		valid_move_tiles = []
		


### AI Controller ###

func ai_move_black_piece() -> void:
	turn += 1
	
	var black_pieces := []

	# Collect all black pieces
	for y in range(GRID_SIZE):
		for x in range(GRID_SIZE):
			var tile: Node = tile_grid[y][x]
			if tile.piece and tile.piece.team == 0:  # Black piece
				black_pieces.append(tile.piece)

	if black_pieces.size() > 0:
		# Collect all pieces that can capture
		var pieces_with_captures := []
		for piece in black_pieces:
			var valid_moves: Array = piece.get_valid_moves()
			var capture_moves: Array = []
			for move in valid_moves:
				if has_enemy_piece_at(move, piece.team):
					capture_moves.append(move)

			if capture_moves.size() > 0:
				pieces_with_captures.append(piece)

		if pieces_with_captures.size() > 0:
			# Select a random black piece that can capture
			var random_piece: Node = pieces_with_captures[randi() % pieces_with_captures.size()]
			var valid_moves: Array = random_piece.get_valid_moves()
			# Collect possible captures again since we have a new piece
			var capture_moves: Array = []
			for move in valid_moves:
				if has_enemy_piece_at(move, random_piece.team):
					capture_moves.append(move)

			if capture_moves.size() > 0:
				# Prioritize capturing a piece
				var capture_move: Vector2 = capture_moves[randi() % capture_moves.size()]
				move_piece(random_piece.grid_position, capture_move)
			else:
				# No captures, so prioritize moves closer to white pieces
				move_closer_to_white(random_piece, black_pieces)
		else:
			# No captures, so prioritize moves closer to white pieces
			var random_piece: Node = black_pieces[randi() % black_pieces.size()]
			move_closer_to_white(random_piece, black_pieces)


# Helper function to move closer to white pieces
func move_closer_to_white(random_piece: Node, black_pieces: Array) -> void:
	var valid_moves: Array = random_piece.get_valid_moves()
	if valid_moves.size() > 0:
		var prioritized_moves := []
		for move in valid_moves:
			if has_piece_at(move):
				# Check if the piece is white
				var target_piece: Node = tile_grid[move.y][move.x].piece
				if target_piece.team == 1:  # White piece
					prioritized_moves.append(move)

		if prioritized_moves.size() > 0:
			# Select a move closer to a white piece
			var closest_move: Vector2 = prioritized_moves[0]
			var closest_distance: float = closest_move.distance_to(random_piece.grid_position)

			for move in prioritized_moves:
				var distance: float = move.distance_to(random_piece.grid_position)
				if distance < closest_distance:
					closest_distance = distance
					closest_move = move

			move_piece(random_piece.grid_position, closest_move)
		else:
			# If no prioritized moves, select a random valid move
			var random_move: Vector2 = valid_moves[randi() % valid_moves.size()]
			move_piece(random_piece.grid_position, random_move)




### Helper Functions ###

func has_piece_at(pos: Vector2) -> bool:
	if not is_within_bounds(pos):
		return false
	var tile: Node = tile_grid[pos.y][pos.x] 
	return tile != null and tile.piece != null
	
func has_enemy_piece_at(pos: Vector2, current_team: int) -> bool:
	if not has_piece_at(pos):
		return false
	var piece: Node = tile_grid[pos.y][pos.x].piece
	return piece.team != current_team
	
func is_within_bounds(pos: Vector2) -> bool:
	return pos.x >= 0 and pos.x < GRID_SIZE and pos.y >= 0 and pos.y < GRID_SIZE
