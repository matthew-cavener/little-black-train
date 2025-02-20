extends CharacterBody2D


const SPEED = 300.0

@export var is_player_controlled: bool = true
@export var character_name: String = "Alice"
@export var resting_location: Vector2 = Vector2(0, 0)
@export var player_velocity_multiplier: float = 1.5

@onready var actionable = $Actionable
@onready var actionable_shape = $Actionable/ActionableShape
@onready var actionable_finder = $ActionableFinder
@onready var actionable_finder_shape = $ActionableFinder/ActionableFinderShape

var base_dialogue_resource: String
var is_in_dialogue: bool = false

func _ready() -> void:
    DialogueManager.dialogue_started.connect(_on_dialogue_started)
    DialogueManager.dialogue_ended.connect(_on_dialogue_finished)
    add_to_group(character_name)
    base_dialogue_resource = "res://dialogue/%s/%s_base.dialogue" % [character_name.to_lower(), character_name.to_lower()]
    actionable.dialogue_resource = load(base_dialogue_resource)
    if is_player_controlled:
        add_to_group("player")
        actionable_shape.set_deferred("disabled", true)
        actionable_finder_shape.set_deferred("disabled", false)
    else:
        actionable_shape.set_deferred("disabled", false)
        actionable_finder_shape.set_deferred("disabled", true)

func _physics_process(delta: float) -> void:
    if not is_on_floor():
        velocity += get_gravity() * delta
    if is_player_controlled and not is_in_dialogue:
        handle_player_input()
    elif not is_player_controlled:
        return_to_resting_location()
    move_and_slide()

func _on_dialogue_started(_resource) -> void:
    is_in_dialogue = true

# Need to have a slight delay before re-enabling player control, or else using the "ui_accept" input will immediately re-trigger the dialogue
func _on_dialogue_finished(_resource) -> void:
    get_tree().create_timer(0.1).connect("timeout", _on_dialogue_exited)

func _on_dialogue_exited() -> void:
    is_in_dialogue = false

func switch_character(character_name: String) -> void:
    var new_character = get_tree().get_first_node_in_group(character_name)
    var current_character = get_tree().get_first_node_in_group("player")
    if new_character == current_character:
        print("Tried switching to current character")
        return
    current_character.is_player_controlled = false
    current_character.remove_from_group("player")
    current_character.actionable_shape.set_deferred("disabled", false)
    current_character.actionable_finder_shape.set_deferred("disabled", true)

    new_character.is_player_controlled = true
    new_character.add_to_group("player")
    new_character.actionable_shape.set_deferred("disabled", true)
    new_character.actionable_finder_shape.set_deferred("disabled", false)


func handle_player_input() -> void:
    if Input.is_action_just_pressed("ui_accept"):
        var actionables = actionable_finder.get_overlapping_areas()
        if actionables.size() > 0:
            actionables[0].action()
    var direction := Input.get_axis("ui_left", "ui_right")
    if direction:
        velocity.x = direction * SPEED * player_velocity_multiplier
    else:
        velocity.x = move_toward(velocity.x, 0, SPEED * player_velocity_multiplier)

func return_to_resting_location() -> void:
    if abs(position.x - resting_location.x) < 3:
        position.x = resting_location.x
        velocity.x = 0
    else:
        var direction: float = signf(resting_location.x - position.x)
        velocity.x = direction * SPEED
