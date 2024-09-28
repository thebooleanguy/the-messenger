extends Node2D

enum Team {
	BLACK,
	WHITE
}

@export var team: Team
@export var black_texture: Texture2D
@export var white_texture: Texture2D
@onready var board: Node = get_parent();
@onready var lives_label = $Label
var grid_position :Vector2 = Vector2.ZERO
var damaged: bool = false
var lives: int = 0

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
	if damaged == true:
		print("Lives: " + str(lives))
		$Label.position.x = $Sprite2D.position.x - 4
		$Label.position.y = $Sprite2D.position.y - 33
		$Label.text = str(lives)
	else:
		print("Health full")

func _process(_delta: float) -> void:
	pass
