extends Node

const FILE_MODE_READ: int = 1
const FILE_MODE_WRITE: int = 2

# Array to store level data
var levels: Array = []

func _ready():
	#load_levels()
	pass



# Load level data from a JSON file
func load_level(level_name: String) -> Dictionary:
	var file = FileAccess.open("res://levels/" + level_name + ".json", FileAccess.READ)
	
	if !file:
		print("Failed to open file: " + level_name)
		return {}
	
	var json_data = file.get_as_text()
	file.close()

	var json = JSON.new()  # Create a new instance of JSON
	var result = json.parse(json_data)

	if result != OK:
		print("Failed to parse JSON: " + json.get_error_message())
		return {}

	return json.get_data()  # Returns the parsed JSON data


func start_level(level_index: int):
	if level_index < levels.size():
		var level_data = levels[level_index]
		get_tree().call_group("chessboard", "setup_level", level_data)
	else:
		print("Level index out of bounds")
