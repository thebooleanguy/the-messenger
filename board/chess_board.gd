extends Node2D

class_name ChessBoard

const CHESS_TILE: PackedScene = preload("res://board/ChessTile.tscn")
var GRID_SIZE: int = 4
const TILE_SIZE: float = 63
const CENTERED_TILE_OFFSET := Vector2(TILE_SIZE / 2, TILE_SIZE / 2)
var CHESSBOARD_SIZE :float = TILE_SIZE * GRID_SIZE
var tile_grid: Array[Array] = []
var selected_piece: Node = null
var selected_tile: Node = null
var valid_move_tiles: Array[Vector2] = []
var turn: int = 0
var player_move_in_progress: bool = false

@onready var lvl_label: Node = $CanvasLayer/HBoxContainerTopLeft/LevelLabel
var current_level: int = 8
var max_levels: int = 8
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
	#position.x = (get_viewport_rect().size.x - CHESSBOARD_SIZE) / 2
	#position.y = (get_viewport_rect().size.y - CHESSBOARD_SIZE) / 2
	#get_viewport().size = Vector2(768,432)
	draw_board()
	level_manager = LevelManager.new()
	load_current_level()


func _process(_delta: float) -> void:
	if Input.is_action_pressed("restart"):
		#await get_tree().create_timer(0.1).timeout
		load_current_level()
	# Dynamic Resizing
	position.x = (get_viewport_rect().size.x - CHESSBOARD_SIZE) / 2
	position.y = (get_viewport_rect().size.y - CHESSBOARD_SIZE) / 2

func draw_board() -> void:
	# Clear existing tiles from tile_grid if it already exists
	for row: Array[Node] in tile_grid:
		for tile: Node in row:
			tile.queue_free()  # Remove existing tiles
	tile_grid.clear()  # Clear the grid array
	
	for y in range(GRID_SIZE):
		# For it to be a 2D array
		var row: Array[Node] = []
		for x in range(GRID_SIZE):
			var tile := CHESS_TILE.instantiate()
			tile.position = Vector2(x * TILE_SIZE, y * TILE_SIZE)
			tile.grid_position = Vector2(x, y)
			add_child(tile)
			tile.connect("tile_clicked", _on_tile_clicked)
			row.append(tile)
		tile_grid.append(row)


func place_piece(piece_scene: PackedScene, pos: Vector2, team: int, damaged: bool, lives: int) -> void:
	if is_within_bounds(pos):
		var tile: Node = tile_grid[pos.y][pos.x]
		if !tile.piece:
			var piece_instance := piece_scene.instantiate()
			piece_instance.position = tile.position + CENTERED_TILE_OFFSET
			piece_instance.set_team(team)
			piece_instance.grid_position = tile.grid_position
			piece_instance.damaged = damaged
			piece_instance.lives = lives
			add_child(piece_instance)
			tile.piece = piece_instance
	else:
		print("Out of bounds")


func move_piece(curr_pos: Vector2, new_pos: Vector2) -> void:
	if is_within_bounds(curr_pos) and is_within_bounds(new_pos):
		var tween: Tween = create_tween()
		var tile_from: Node = tile_grid[curr_pos.y][curr_pos.x] 
		var tile_to: Node = tile_grid[new_pos.y][new_pos.x] 
		var piece: Node = tile_from.piece
		if piece:
			# Out of lives
			if ((piece.damaged == true) and (piece.lives <= 0)):
				return
			# Capture piece
			if tile_to.piece:
				#await get_tree().create_timer(0.3).timeout
				$PieceCaptureSound.play()
				tile_to.piece.queue_free()
			# Move piece
			#piece.position = tile_to.position + CENTERED_TILE_OFFSET
			if piece.damaged:
				piece.lives -= 1
				piece.lives_label.text = str(piece.lives)
			tween.tween_property(piece, "position", tile_to.position + CENTERED_TILE_OFFSET, 0.1)
			tile_to.piece = piece
			piece.grid_position = tile_to.grid_position
			tile_from.piece = null
			if !$PieceMoveSound.playing:
				$PieceMoveSound.play()
	else:
		print("Out of bounds")


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
				turn -= 1
				await get_tree().create_timer(0.05).timeout
				ai_move_black_piece()
				await get_tree().create_timer(0.11).timeout
				#Check for Win
				if is_instance_valid(selected_piece):
					if (grid_pos.y == 0) and (selected_piece is Pawn) and (selected_piece.team == 1):
						print("You've won! Loading next level...")
						$WinSound.play()
						if current_level < max_levels:
							current_level += 1
							load_current_level()
						# Game Complete
						else:
							get_tree().change_scene_to_file("res://ui/GameOver.tscn")
						return
				
				
					
				
		# Unhighlight the selected tile and valid move tiles
		if selected_tile:
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
		# Move towards closest capture or closest white piece if no capture is available
		var best_move := find_closest_capture_or_move(black_pieces)

		if best_move:
			move_piece(best_move["piece"].grid_position, best_move["move"])


# Helper function to prioritize the closest capture first, otherwise move towards the closest white piece
func find_closest_capture_or_move(black_pieces: Array) -> Dictionary:
	#var _best_move: Dictionary
	var closest_capture_distance: float = INF
	var closest_move_distance: float = INF
	var best_capture: Dictionary
	var best_normal_move: Dictionary

	# Loop through all black pieces and their valid moves
	for piece: Node in black_pieces:
		var valid_moves: Array = piece.get_valid_moves()

		for move: Vector2 in valid_moves:
			for y in range(GRID_SIZE):
				for x in range(GRID_SIZE):
					var tile: Node = tile_grid[y][x]

					# If there's a white piece on this tile (for a capture)
					if tile.piece and tile.piece.team == 1:  # White piece
						var distance: float = piece.grid_position.distance_to(tile.piece.grid_position)
						
						# Check if this is a capture
						if move == tile.piece.grid_position:
							# Prioritize closest capture
							if distance < closest_capture_distance:
								closest_capture_distance = distance
								best_capture = {"piece": piece, "move": move}
						else:
							# Track the closest normal move
							if distance < closest_move_distance:
								closest_move_distance = distance
								best_normal_move = {"piece": piece, "move": move}

	# Prioritize the closest capture first, otherwise fall back to the closest normal move
	if best_capture:
		return best_capture
	else:
		return best_normal_move






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
	
	
func setup_level(level_data: Dictionary) -> void:
	# Set the grid size from level data
	if "grid_size" in level_data:
		GRID_SIZE = level_data["grid_size"]
		draw_board()  # Call draw_board to create the board with the new size
		#reset_board()
	else:
		print("Grid size not specified in level data.")
	lvl_label.text = ("Level " + str(current_level))
	
	# Center Board
	#if GRID_SIZE > 5:
		#get_viewport().size = Vector2(800,600)
	#else:
	#get_viewport().size = Vector2(768,432)
	position.x = (get_viewport_rect().size.x - CHESSBOARD_SIZE) / 2
	position.y = (get_viewport_rect().size.y - CHESSBOARD_SIZE) / 2

	# Place pieces based on level_data
	for piece_data: Dictionary in level_data["pieces"]:
		var piece_type: String = piece_data["type"]
		var piece_damaged: bool = false
		var piece_lives: int = 0
		if piece_data["damaged"]:
			piece_damaged = true
			piece_lives = piece_data["lives"]
		#var piece_lives: int = piece_data["lives"]
		if piece_type in piece_scene_map:
			var piece_scene: PackedScene = piece_scene_map[piece_type]
			
			# Convert the position from Array to Vector2
			var position_array: Array = piece_data["position"]
			var pos: Vector2 = Vector2(position_array[0], position_array[1])
			
			place_piece(piece_scene, pos, piece_data["team"], piece_damaged, piece_lives)
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
				
func load_current_level() -> void:
	reset_board()
	var level_data := level_manager.load_level("level_" + str(current_level))  # Load the current level
	#if current_level == 1:
		#$TutorialMusic.play()
	if current_level == 7:
		$TutorialMusic.stop()
		#$MusicPlayer.stream = preload("res://assets/music/Intense.mp3")
		$GameMusic.play()
	if level_data.size() > 0:
		setup_level(level_data)
	else:
		print("Level data not found!")



func _on_texture_button_pressed() -> void:
	load_current_level()
