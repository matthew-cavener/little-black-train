extends OptionButton

@onready var characters = get_tree().get_nodes_in_group("character")

func _ready() -> void:
    for character in characters:
        add_item(character.character_name)

func _on_item_selected(index: int) -> void:
    for character in characters:
        character.is_player_controlled = false
        if character.character_name == get_item_text(index):
            character.is_player_controlled = true
