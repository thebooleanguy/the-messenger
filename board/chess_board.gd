extends Node2D

class_name ChessBoard

const CHESS_TILE: PackedScene = preload("res://board/ChessTile.tscn")
var grid_size: int
const TILE_SIZE: float = 63
const CENTERED_TILE_OFFSET := Vector2((TILE_SIZE / 2) - 2, (TILE_SIZE / 2) + 2)
var chessboard_size :float = TILE_SIZE * grid_size

# Margins
const MARGIN: float = 20.0
const TOP_MARGIN: float = 50.0  # More space for labels
const SCALE_FACTOR: float = 0.9  # Scale down to 90% of the original size

var tile_grid: Array[Array] = []
var selected_piece: Node = null
var selected_tile: Node = null
var valid_move_tiles: Array[Vector2] = []
var turn: int = 0
var player_move_in_progress: bool = false

# Labels
@onready var hint_label: Label = $CanvasLayer/HBoxContainerCenterRight/ControlHintLabel
@onready var lvl_label: Label = $CanvasLayer/HBoxContainerTopLeft/LevelLabel
# Music
@onready var tutorial_music: AudioStreamPlayer = $TutorialMusic
@onready var game_music: AudioStreamPlayer = $GameMusic
# SoundEffects
@onready var piece_capture_sound: AudioStreamPlayer = $PieceCaptureSound
@onready var piece_move_sound: AudioStreamPlayer = $PieceMoveSound
@onready var win_sound: AudioStreamPlayer = $WinSound
@onready var ui_sound_loop: AudioStreamPlayer = $UISoundLoop


@export var current_level: int = 1
@export var max_levels: int = 11
const LevelManager = preload("res://levels/level_manager.gd")
var level_manager: LevelManager


# Create a mapping of piece types to their scenes
var piece_scene_map: Dictionary[String, Variant] = {
	"Pawn": preload("res://pieces/Pawn.tscn"),
	"Rook": preload("res://pieces/Rook.tscn"),
	"Queen": preload("res://pieces/Queen.tscn"),
	"Bishop": preload("res://pieces/Bishop.tscn"),
	"Knight": preload("res://pieces/Knight.tscn")
}

func _ready() -> void:
	draw_board()
	level_manager = LevelManager.new()
	load_current_level()
	_center_and_scale_board()
	
	hint_label.visible_characters = 0
	hint_label.text = ""
	script_events()
	#await(get_tree().create_timer(2))
	#tutorial_music.play()


func _process(_delta: float) -> void:
	if Input.is_action_pressed("restart"):
		#await get_tree().create_timer(0.1).timeout
		load_current_level()
	# Dynamic Resizing
	_center_and_scale_board()

func draw_board() -> void:
	# Clear existing tiles from tile_grid if they exist
	for row: Array[Node] in tile_grid:
		for tile: Node in row:
			tile.queue_free()  # Remove existing tiles
	tile_grid.clear()  # Clear the grid array
	
	# Draw the board with scaled tiles
	for y in range(grid_size):
		var row: Array[Node] = []
		for x in range(grid_size):
			var tile := CHESS_TILE.instantiate()
			
			# Apply scaling and position adjustments with rounding
			var pos_x: int = round(x * TILE_SIZE * SCALE_FACTOR)
			var pos_y: int = round(y * TILE_SIZE * SCALE_FACTOR)
			tile.position = Vector2(pos_x, pos_y)
			tile.scale = Vector2(SCALE_FACTOR, SCALE_FACTOR)  # Scale each tile
			
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
				piece_capture_sound.play()
				tile_to.piece.queue_free()
			# Reduce Lives
			if piece.damaged:
				piece.lives -= 1
				piece.lives_label.text = str(piece.lives)
			# Move piece
			tween.tween_property(piece, "position", tile_to.position + CENTERED_TILE_OFFSET, 0.1)
			tile_to.piece = piece
			piece.grid_position = tile_to.grid_position
			tile_from.piece = null
			if !piece_move_sound.playing:
				piece_move_sound.play()
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
						win_sound.play()
						if current_level < max_levels:
							current_level += 1
							load_current_level()
							script_events()
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
	for y in range(grid_size):
		for x in range(grid_size):
			var tile: Node = tile_grid[y][x]
			if tile.piece and tile.piece.team == 0 and tile.piece.lives > 0:  # Black piece
				black_pieces.append(tile.piece)

	if black_pieces.size() > 0:
		# Move towards closest capture or closest white piece if no capture is available
		var best_move := find_closest_capture_or_move(black_pieces)

		if best_move:
			move_piece(best_move["piece"].grid_position, best_move["move"])


# Helper function to prioritize the closest capture first, otherwise move towards the closest white piece
func find_closest_capture_or_move(black_pieces: Array) -> Dictionary[String, Variant]:
	#var _best_move: Dictionary
	var closest_capture_distance: float = INF
	var closest_move_distance: float = INF
	var best_capture: Dictionary[String, Variant]
	var best_normal_move: Dictionary[String, Variant]

	# Loop through all black pieces and their valid moves
	for piece: Node in black_pieces:
		var valid_moves: Array = piece.get_valid_moves()

		for move: Vector2 in valid_moves:
			for y in range(grid_size):
				for x in range(grid_size):
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
	return pos.x >= 0 and pos.x < grid_size and pos.y >= 0 and pos.y < grid_size
	
	
func setup_level(level_data: Dictionary[Variant, Variant]) -> void:
	# Set the grid size from level data
	if "grid_size" in level_data:
		grid_size = level_data["grid_size"]
		draw_board()  # Call draw_board to create the board with the new size
	else:
		print("Grid size not specified in level data.")
	lvl_label.text = ("Level " + str(current_level) + "/" + str(max_levels))
	
	_center_and_scale_board()

	# Place pieces based on level_data
	for piece_data: Dictionary[Variant, Variant] in level_data["pieces"]:
		var piece_type: String = piece_data["type"]
		var piece_damaged: bool = false
		var piece_lives: int = 99
		if piece_data["damaged"]:
			piece_damaged = true
			piece_lives = piece_data["lives"]

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
	
	for y in range(grid_size):
		for x in range(grid_size):
			var tile: Node = tile_grid[y][x]
			if tile.piece:
				tile.piece.queue_free()  # Remove the piece from the scene
				tile.piece = null  # Clear the reference

				
func load_current_level() -> void:
	reset_board()
	var level_data: Dictionary[Variant, Variant] = level_manager.load_level("level_" + str(current_level))
	#print(level_data)
	#if current_level == 2:
		#tutorial_music.play()
	#if current_level == 7:
		#tutorial_music.stop()
		#game_music.play()
	if level_data.size() > 0:
		setup_level(level_data)
	else:
		print("Level data not found!")
	
	



func _on_texture_button_pressed() -> void:
	load_current_level()
	
	
# Center Board
func _center_and_scale_board() -> void:
	var board_size: float = grid_size * TILE_SIZE
	
	# Define the margins (adjust these values as needed)
	var side_margin: float = 10
	var top_margin: float = 30
	
	# Calculate available space considering margins
	var available_width: float = get_viewport_rect().size.x - 2 * side_margin
	var available_height: float = get_viewport_rect().size.y - top_margin - side_margin
	
	# Scale the board based on the smaller available space
	var scale_factor: float = min(available_width / board_size, available_height / board_size)
	
	# Apply the scaling
	scale = Vector2(scale_factor, scale_factor)
	
	# Calculate the new scaled board size
	var scaled_board_size: float = board_size * scale_factor
	
	# Center the chessboard within the available space
	position.x = (get_viewport_rect().size.x - scaled_board_size) / 2 + side_margin
	position.y = (get_viewport_rect().size.y - scaled_board_size) / 2 + top_margin


func script_events() -> void:
	if current_level == 1:
		await(display_hint(1, 2, "Use your mouse to move a pawn to the other side", hint_label, 3))
		#await(display_hint(1, 3, "Take a pawn to the other side", hint_label, 2))
	if current_level == 2:
		#await get_tree().create_timer(0.1).timeout
		tutorial_music.play()
	if current_level == 3:
		await(display_hint(1, 3, "Use other pieces strategically to aid your pawn", hint_label, 3))
	#if current_level == 6:
		#await(display_hint(4, 2, "Make the right kind of sacrifice", hint_label, 2))
	if current_level == 7:
		await(display_hint(2, 3, "Numbered pieces have a limited number of turns left", hint_label, 3))
	if current_level == 8:
		#await get_tree().create_timer(0.1).timeout
		tutorial_music.stop()
		game_music.play()
		
	
	
func display_hint(start_delay: int, end_delay: int, text_content: String, label: Node, typing_speed: float) -> void:
	await get_tree().create_timer(start_delay).timeout
	var tween: Tween = create_tween()
	hint_label.text = text_content
	#ui_sound_loop.stream.loop = true
	ui_sound_loop.play()
	tween.tween_property(label, "visible_characters", text_content.length(), typing_speed)
	await get_tree().create_timer(typing_speed).timeout
	#ui_sound_loop.stream.loop = false
	ui_sound_loop.stop()
	await get_tree().create_timer(end_delay).timeout
	hint_label.visible_characters = 0
	hint_label.text = ""
