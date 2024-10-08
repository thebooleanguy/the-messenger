extends Node2D

class_name UI

@onready var ui_sound: AudioStreamPlayer = $UISound

func _ready() -> void:
	pass

func _on_start_button_pressed() -> void:
	ui_sound.play()
	await get_tree().create_timer(0.11).timeout
	get_tree().change_scene_to_file("res://board/ChessBoard.tscn")

func _on_instructions_button_pressed() -> void:
	ui_sound.play()
	await get_tree().create_timer(0.11).timeout
	get_tree().change_scene_to_file("res://ui/Instructions.tscn")

func _on_controls_pressed() -> void:
	ui_sound.play()
	await get_tree().create_timer(0.11).timeout
	get_tree().change_scene_to_file("res://ui/Controls.tscn")

func _on_menu_button_pressed() -> void:
	ui_sound.play()
	await get_tree().create_timer(0.11).timeout
	get_tree().change_scene_to_file("res://ui/Intro.tscn")

func _on_back_button_pressed() -> void:
	ui_sound.play()
	await get_tree().create_timer(0.11).timeout
	get_tree().change_scene_to_file("res://ui/Intro.tscn")

func _on_play_button_pressed() -> void:
	ui_sound.play()
	await get_tree().create_timer(0.11).timeout
	get_tree().change_scene_to_file("res://board/ChessBoard.tscn")
