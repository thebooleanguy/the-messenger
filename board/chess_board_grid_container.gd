extends GridContainer



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(64):
		var tile = preload("res://board/ChessTile.tscn").instantiate()
		self.add_child(tile)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
