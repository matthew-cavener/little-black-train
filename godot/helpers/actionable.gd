extends Area2D

@export var dialogue_resource: DialogueResource
@export var dialogue_start: String = "start"

@onready var parent = get_parent()
@onready var player_character = get_tree().get_first_node_in_group("player")

func action() -> void:
	player_character = get_tree().get_first_node_in_group("player")
	DialogueManager.show_example_dialogue_balloon(dialogue_resource, dialogue_start, [self])
