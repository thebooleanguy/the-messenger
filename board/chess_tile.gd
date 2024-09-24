extends Node2D

@export var piece: Node = null
@onready var color_rect := $Sprite2D/ColorRect
@onready var color_rect_default_color = color_rect.color 


func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass


func _on_color_rect_mouse_entered() -> void:
	color_rect.color = Color(0.8, 0.8, 0.8, 0.5)
	print(piece)


func _on_color_rect_mouse_exited() -> void:
	color_rect.color = color_rect_default_color
