extends Area2D

@export var dialogue_resource: DialogueResource
@export var dialogue_start: String = "start"

@onready var parent = get_parent()

func action() -> void:
    DialogueManager.show_example_dialogue_balloon(dialogue_resource, dialogue_start, [self])
