extends ColorRect

@onready var default_color := color

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_mouse_entered() -> void:
	color = Color(0.8, 0.8, 0.8, 0.5)


func _on_mouse_exited() -> void:
	color = default_color
