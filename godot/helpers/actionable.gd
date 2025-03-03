extends Area2D

@export var dialogue_resource: DialogueResource
@export var dialogue_start: String = "start"

@onready var parent = get_parent()
@onready var player_character = get_tree().get_first_node_in_group("player")
@onready var character_spoken_to = null

func action(character: CharacterBody2D) -> void:
    player_character = get_tree().get_first_node_in_group("player")
    character_spoken_to = character
    print("alice_and_mr_jones flag: %s" % State.alice_and_mrjones_had_first_conversation)
    print("mr_jones_and_alice flag: %s" % State.mrjones_and_alice_had_first_conversation)
    DialogueManager.show_example_dialogue_balloon(dialogue_resource, dialogue_start, [self])
