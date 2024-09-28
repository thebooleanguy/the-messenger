extends Node2D

enum Team {
	BLACK,
	WHITE
}

@export var team: Team
@export var black_texture: Texture2D
@export var white_texture: Texture2D
@onready var board: Node = get_parent();
var grid_position :Vector2 = Vector2.ZERO

# Override this method
func get_valid_moves() -> Array[Vector2]:
	print("Not Overridden")
	return[]

func set_team(team_color: Team) -> void:
	team = team_color
	if team == Team.BLACK:
		$Sprite2D.texture = black_texture
	else:
		$Sprite2D.texture = white_texture

func _ready() -> void:
	pass 

func _process(_delta: float) -> void:
	pass
