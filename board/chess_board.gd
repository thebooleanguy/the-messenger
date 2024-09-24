extends Node2D

const CHESS_TILE := preload("res://board/ChessTile.tscn")
const PAWN := preload("res://pieces/Pawn.tscn")
const TILE_SIZE := 63
const CENTERED_TILE_OFFSET := Vector2(TILE_SIZE / 2, TILE_SIZE / 2)
var tile_grid :Array = []
var selected_piece = null
var selected_tile = null

func _ready() -> void:
	draw_board()
	place_piece(PAWN, Vector2(2,0), 0)
	move_piece(Vector2(2,0), Vector2(2,1))
	#print(tile_grid)


func draw_board() -> void:
	for y in range(8):
		var row := []
		for x in range(8):
			var tile := CHESS_TILE.instantiate()
			tile.position = Vector2(x * TILE_SIZE, y * TILE_SIZE)
			tile.grid_position = Vector2(x, y)
			add_child(tile)
			tile.connect("tile_clicked", _on_tile_clicked)
			row.append(tile)
		tile_grid.append(row)


func place_piece(piece_scene: PackedScene, pos: Vector2, team: int) -> void:
	var tile = tile_grid[pos.y][pos.x]
	var piece_instance := piece_scene.instantiate()
	piece_instance.position = tile.position + CENTERED_TILE_OFFSET
	piece_instance.set_team(team)
	add_child(piece_instance)
	tile.piece = piece_instance


func move_piece(curr_pos: Vector2, new_pos: Vector2) -> void:
	var tile_from = tile_grid[curr_pos.y][curr_pos.x] 
	var tile_to = tile_grid[new_pos.y][new_pos.x] 
	var piece = tile_from.piece
	if piece:
		piece.position = tile_to.position + CENTERED_TILE_OFFSET
		tile_to.piece = piece
		tile_from.piece = null

func _on_tile_clicked(grid_pos: Vector2) -> void:
	var clicked_tile = tile_grid[grid_pos.y][grid_pos.x]
	
	if selected_piece == null:
		if clicked_tile.piece != null:
			selected_piece = clicked_tile.piece
			selected_tile = clicked_tile
			highlight_tile(selected_tile, true)
			clicked_tile.is_selected = true
	else:
		if clicked_tile != selected_tile:
			move_piece(selected_tile.grid_position, grid_pos)
			highlight_tile(selected_tile, false)
			clicked_tile.is_selected = false
			selected_piece = null
			selected_tile = null 

func highlight_tile(tile, highlight: bool) -> void:
	if highlight:
		tile.color_rect.color = Color(0.5, 0.5, 0.5, 0.8) 
	else:
		tile.color_rect.color = tile.color_rect_default_color

func _process(delta: float) -> void:
	pass
