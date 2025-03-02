extends StaticBody2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    DialogueManager.dialogue_started.connect(_on_dialogue_started)
    DialogueManager.dialogue_ended.connect(_on_dialogue_finished)

func _on_dialogue_started(_resource) -> void:
    var tween = create_tween()
    tween.tween_property($Exterior, "modulate:a", 0, 1)

func _on_dialogue_finished(_resource) -> void:
    var tween = create_tween()
    tween.tween_property($Exterior, "modulate:a", 1, 1)
