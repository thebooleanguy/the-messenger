extends Node2D

const CHESS_TILE := preload("res://board/ChessTile.tscn")
const BLACK_PAWN := preload("res://pieces/pawn.tscn")
const TILE_SIZE := 63
const CENTERED_TILE_OFFSET := Vector2(TILE_SIZE / 2, TILE_SIZE / 2)
var tile_grid :Array = []

func _ready() -> void:
	draw_board()
	place_piece(BLACK_PAWN, Vector2(2,0))
	move_piece(Vector2(2,0), Vector2(2,1))
	#print(tile_grid)


func draw_board() -> void:
	for y in range(8):
		var row := []
		for x in range(8):
			var tile := CHESS_TILE.instantiate()
			tile.position = Vector2(x * TILE_SIZE, y * TILE_SIZE)
			add_child(tile)
			row.append(tile)
		tile_grid.append(row)


func place_piece(piece_scene: PackedScene, pos: Vector2) -> void:
	var tile = tile_grid[pos.y][pos.x]
	var piece_instance := piece_scene.instantiate()
	piece_instance.position = tile.position + CENTERED_TILE_OFFSET
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

func _process(delta: float) -> void:
	pass
