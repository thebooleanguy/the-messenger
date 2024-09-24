extends Node2D

const CHESS_TILE: PackedScene = preload("res://board/ChessTile.tscn")
const PAWN: PackedScene = preload("res://pieces/Pawn.tscn")
const GRID_SIZE: int = 8
const TILE_SIZE: float = 63
const CENTERED_TILE_OFFSET := Vector2(TILE_SIZE / 2, TILE_SIZE / 2)
const CHESSBOARD_SIZE := TILE_SIZE * GRID_SIZE
var tile_grid: Array = []
var selected_piece: Node = null
var selected_tile: Node = null

func _ready() -> void:
	# Center board on viewport
	position.x = (get_viewport_rect().size.x - CHESSBOARD_SIZE) / 2
	position.y = (get_viewport_rect().size.y - CHESSBOARD_SIZE) / 2
	draw_board()
	place_piece(PAWN, Vector2(2,0), 0)
	move_piece(Vector2(2,0), Vector2(2,1))
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
	var piece_instance := piece_scene.instantiate()
	piece_instance.position = tile.position + CENTERED_TILE_OFFSET
	piece_instance.set_team(team)
	add_child(piece_instance)
	tile.piece = piece_instance


func move_piece(curr_pos: Vector2, new_pos: Vector2) -> void:
	var tile_from: Node = tile_grid[curr_pos.y][curr_pos.x] 
	var tile_to: Node = tile_grid[new_pos.y][new_pos.x] 
	var piece: Node = tile_from.piece
	if piece:
		piece.position = tile_to.position + CENTERED_TILE_OFFSET
		tile_to.piece = piece
		tile_from.piece = null


func _on_tile_clicked(grid_pos: Vector2) -> void:
	var clicked_tile: Node = tile_grid[grid_pos.y][grid_pos.x]
	# If tile already selected
	if selected_piece == null:
		if clicked_tile.piece != null:
			selected_piece = clicked_tile.piece
			selected_tile = clicked_tile
			selected_tile.color_rect.color = Color(0.5, 0.5, 0.5, 0.8) 
			selected_tile.is_selected = true
	# If tile already selected
	else:
		if clicked_tile != selected_tile:
			move_piece(selected_tile.grid_position, grid_pos)
			selected_tile.color_rect.color = selected_tile.color_rect_default_color
			selected_tile.is_selected = false
			selected_piece = null
			selected_tile = null


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
