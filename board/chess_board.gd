extends Node2D

const CHESS_TILE := preload("res://board/ChessTile.tscn")
const BLACK_PAWN := preload("res://pieces/pawn.tscn")
const TILE_SIZE := 63
var tile_grid :Array = []

func _ready() -> void:
	draw_board()
	set_piece(1, Vector2(0, 2))
	draw_piece(Vector2(2,0))
	#move_piece(Vector2(0,2), Vector2(0,4))
	print(tile_grid)


func draw_board() -> void:
	for row_y in range(8):
		var row := []
		for column_x in range(8):
			var tile := CHESS_TILE.instantiate()
			#tile.grid_position = Vector2(column_x, row_y)
			tile.position = Vector2(column_x * TILE_SIZE, row_y * TILE_SIZE)
			add_child(tile)
			row.append(tile)
			#tile_grid.append(tile)
		tile_grid.append(row)
			
			#var black_pawn := BLACK_PAWN.instantiate()
			#black_pawn.position = Vector2(column_x * TILE_SIZE + 32, row_y * TILE_SIZE + 32)
			#add_child(black_pawn)
	
	
func set_piece(piece: int, pos: Vector2) -> void:
	tile_grid[pos.x][pos.y].piece = piece
	#black_pawn.position = Vector2(7,7)
	#tile_grid[pos.x][pos.y].add_child(black_pawn)
	
	
func move_piece(curr_pos: Vector2, new_pos: Vector2) -> void:
	#print('Before: ', tile_grid)
	var piece = tile_grid[curr_pos.x][curr_pos.y].piece
	tile_grid[curr_pos.x][curr_pos.y].piece = 0
	tile_grid[new_pos.x][new_pos.y].piece = piece
	#print('After: ', tile_grid)


func draw_piece(pos: Vector2) -> void:
	var drawing_pos := Vector2(pos.x * TILE_SIZE + 32, pos.y * TILE_SIZE + 32)
	var black_pawn := BLACK_PAWN.instantiate()
	black_pawn.position = drawing_pos
	#tile_grid[pos.x][pos.y].add_child(black_pawn)
	add_child(black_pawn)
	
	

func _process(delta: float) -> void:
	pass
