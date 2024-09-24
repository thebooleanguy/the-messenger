extends Node2D

const CHESS_TILE := preload("res://board/ChessTile.tscn")
const BLACK_PAWN := preload("res://pieces/pawn.tscn")
const TILE_SIZE := 63
var tile_grid :Array = []

func _ready() -> void:
	draw_board()
	#move_piece(Vector2(0,2), Vector2(0,4))
	place_piece(BLACK_PAWN, Vector2(2,3))
	print(tile_grid)


func draw_board() -> void:
	for y in range(8):
		var row := []
		for x in range(8):
			var tile := CHESS_TILE.instantiate()
			#tile.grid_position = Vector2(x, y)
			tile.position = Vector2(x * TILE_SIZE, y * TILE_SIZE)
			add_child(tile)
			row.append(tile)
		tile_grid.append(row)
	

	
func move_piece(curr_pos: Vector2, new_pos: Vector2) -> void:
	#print('Before: ', tile_grid)
	var piece = tile_grid[curr_pos.x][curr_pos.y].piece
	tile_grid[curr_pos.x][curr_pos.y].piece = 0
	tile_grid[new_pos.x][new_pos.y].piece = piece
	#print('After: ', tile_grid)
	
	
func place_piece(piece_scene: PackedScene, pos: Vector2) -> void:
	var tile = tile_grid[pos.y][pos.x]
	var piece_instance := piece_scene.instantiate()
	piece_instance.position = tile.position + Vector2(TILE_SIZE / 2, TILE_SIZE / 2)
	add_child(piece_instance)
	tile.piece = piece_instance

func _process(delta: float) -> void:
	pass
