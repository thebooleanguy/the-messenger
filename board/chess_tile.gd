extends Node2D

#var grid_position := Vector2.ZERO
var piece := Pieces.NULL
var team := Team.UNDEFINED
@onready var color_rect := $Sprite2D/ColorRect
@onready var color_rect_default_color = color_rect.color 


func _ready() -> void:
	pass



func _process(delta: float) -> void:
	pass


func _on_color_rect_mouse_entered() -> void:
	color_rect.color = Color(0.8, 0.8, 0.8, 0.5)
	print(piece, ' ' , team)
	#print(grid_position, position)
	#print(self)


func _on_color_rect_mouse_exited() -> void:
	color_rect.color = color_rect_default_color
	
	
enum Pieces {
	NULL, # 0
	PAWN, # 1
	ROOK, # 2
	BISHOP, # 3
	KNIGHT, # 4
	QUEEN, # 5
	KING # 6
}

enum Team {
	UNDEFINED, # 0
	BLACK, # 1
	WHITE # 2
}
