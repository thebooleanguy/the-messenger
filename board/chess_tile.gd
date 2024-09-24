extends Node2D

@export var piece: Node = null
@onready var color_rect := $Sprite2D/ColorRect
@onready var color_rect_default_color = color_rect.color 
var grid_position :Vector2 = Vector2.ZERO
var is_selected: bool = false 

signal tile_clicked(grid_position)

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass


func _on_color_rect_mouse_entered() -> void:
	if not is_selected:
		color_rect.color = Color(0.8, 0.8, 0.8, 0.5)
		print(piece)


func _on_color_rect_mouse_exited() -> void:
	if not is_selected:
		color_rect.color = color_rect_default_color


func _on_color_rect_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("select"):
		tile_clicked.emit(grid_position)
		#is_selected = true
		color_rect.color = Color(0.5, 0.5, 0.5, 0.8)
