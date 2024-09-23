extends Node2D

const CHESS_TILE = preload("res://board/ChessTile.tscn")
const TILE_SIZE := 63
var tile_grid = []

func _ready() -> void:
	draw_board()


func draw_board() -> void:
	for row in range(8):
		for col in range(8):
			var tile = CHESS_TILE.instantiate()
			tile.position = Vector2(col * TILE_SIZE, row * TILE_SIZE)
			add_child(tile)
			tile_grid.append(tile.position)

func _process(delta: float) -> void:
	pass
