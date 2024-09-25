extends Node2D

const CHESS_TILE: PackedScene = preload("res://board/ChessTile.tscn")
const GRID_SIZE: int = 6
const TILE_SIZE: float = 63
const CENTERED_TILE_OFFSET := Vector2(TILE_SIZE / 2, TILE_SIZE / 2)
const CHESSBOARD_SIZE := TILE_SIZE * GRID_SIZE
var tile_grid: Array = []
var selected_piece: Node = null
var selected_tile: Node = null
var valid_move_tiles: Array = []

# Pieces for debugging Purposes, remove later
const PAWN: PackedScene = preload("res://pieces/Pawn.tscn")
const ROOK: PackedScene = preload("res://pieces/Rook.tscn")
const QUEEN: PackedScene = preload("res://pieces/Queen.tscn")
const BISHOP: PackedScene = preload("res://pieces/Bishop.tscn")
const KNIGHT: PackedScene = preload("res://pieces/Knight.tscn")

func _ready() -> void:
	# Center board on viewport
	position.x = (get_viewport_rect().size.x - CHESSBOARD_SIZE) / 2
	position.y = (get_viewport_rect().size.y - CHESSBOARD_SIZE) / 2
	draw_board()
	
	# For Debugging Purposes
	place_piece(ROOK, Vector2(2,0), 0)
	place_piece(PAWN, Vector2(3,2), 1)
	place_piece(QUEEN, Vector2(4,4), 0)
	place_piece(BISHOP, Vector2(1,4), 1)
	place_piece(KNIGHT, Vector2(4,5), 0)
	#move_piece(Vector2(2,0), Vector2(2,1))
	#print(has_piece_at(Vector2(2,11)))
	#print(has_enemy_piece_at(Vector2(2,1), 1))
	#print(tile_grid)

func draw_board() -> void:
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
	var tile: Node = tile_grid[pos.y][pos.x]
	if !tile.piece:
		var piece_instance := piece_scene.instantiate()
		piece_instance.position = tile.position + CENTERED_TILE_OFFSET
		piece_instance.set_team(team)
		piece_instance.grid_position = tile.grid_position
		add_child(piece_instance)
		tile.piece = piece_instance


func move_piece(curr_pos: Vector2, new_pos: Vector2) -> void:
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
	
	# If a piece is already selected
	else:
		if clicked_tile != selected_tile:
			# Check if the clicked tile is a valid move
			if grid_pos in valid_move_tiles:
				move_piece(selected_tile.grid_position, grid_pos)
				
			# Unhighlight the selected tile and valid move tiles
			selected_tile.color_rect.color = selected_tile.color_rect_default_color
			selected_tile.is_selected = false
			
			for move: Vector2 in valid_move_tiles:
				var tile: Node = tile_grid[move.y][move.x]
				tile.color_rect.color = tile.color_rect_default_color
				tile.is_selected = false
			
			# Reset selection
			selected_piece = null
			selected_tile = null
			valid_move_tiles = []


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

func _process(_delta: float) -> void:
	pass
