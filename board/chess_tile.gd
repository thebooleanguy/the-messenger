extends Node2D

@export var piece: Node = null
var grid_position :Vector2 = Vector2.ZERO
var is_selected: bool = false
@onready var board: Node = get_parent()  
@onready var color_rect := $Sprite2D/ColorRect
@onready var color_rect_default_color: Color = color_rect.color

signal tile_clicked(grid_position: Vector2)

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	pass


func _on_color_rect_mouse_entered() -> void:
	if not is_selected:
		color_rect.color = Color(0.8, 0.8, 0.8, 0.5)
		#print(piece, ' ', grid_position)


func _on_color_rect_mouse_exited() -> void:
	if not is_selected:
		color_rect.color = color_rect_default_color


func _on_color_rect_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("select") and board.turn == 1 and (!piece or piece.team == 1 or (board.player_move_in_progress and piece.team == 0)):
		tile_clicked.emit(grid_position)
		if not is_selected:
			color_rect.color = Color(0.5, 0.5, 0.5, 0.8)
