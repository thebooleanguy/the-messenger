extends Node2D

enum Team {
	BLACK,
	WHITE
}

@export var team: Team
@export var black_texture: Texture2D
@export var white_texture: Texture2D

# Override this method
func get_valid_moves(board: Array) -> Array:
	return[]

func set_team(team_color: Team) -> void:
	team = team_color
	var sprite = $Sprite2D
	if team == Team.BLACK:
		$Sprite2D.texture = black_texture
	else:
		$Sprite2D.texture = white_texture

func _ready() -> void:
	pass 

func _process(delta: float) -> void:
	pass
