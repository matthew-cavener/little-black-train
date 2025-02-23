extends CharacterBody2D

const SPEED = 300.0
const DIALOGUE_EXIT_DELAY = 0.1
const RESTING_LOCATION_THRESHOLD = 3.0
const PLAYER_VELOCITY_MULTIPLIER = 1.5

@export var is_player_controlled: bool = true
@export var character_name: String = "Alice"
@export var resting_location: Vector2 = Vector2(0, 0)
@export var traits: Array
@export var traits_known_to_player: Array

@onready var actionable = $Actionable
@onready var actionable_shape = $Actionable/ActionableShape
@onready var actionable_finder = $ActionableFinder
@onready var actionable_finder_shape = $ActionableFinder/ActionableFinderShape
@onready var camera = get_tree().get_first_node_in_group("camera")

var is_in_dialogue: bool = false

func _ready() -> void:
    DialogueManager.dialogue_started.connect(_on_dialogue_started)
    DialogueManager.dialogue_ended.connect(_on_dialogue_finished)
    $Emote.modulate.a = 0
    add_to_group(character_name)
    var base_dialogue_resource = "res://dialogue/%s/%s_base.dialogue" % [character_name.to_lower(), character_name.to_lower()]
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
    elif not is_player_controlled and not is_in_dialogue:
        return_to_resting_location()
    move_and_slide()

func _on_dialogue_started(_resource) -> void:
    is_in_dialogue = true

# Need to have a slight delay before re-enabling player control, or else ending dialogue using the "ui_accept" input will immediately re-trigger the dialogue
func _on_dialogue_finished(_resource) -> void:
    get_tree().create_timer(DIALOGUE_EXIT_DELAY).connect("timeout", _on_dialogue_exited)

func _on_dialogue_exited() -> void:
    is_in_dialogue = false

func switch_character(new_character_name: String) -> void:
    var new_character = get_tree().get_first_node_in_group(new_character_name)
    var current_character = get_tree().get_first_node_in_group("player")
    if new_character == null:
        print("Tried switching to non-existent character: %s" % new_character_name)
        return
    if current_character == null:
        print("Tried switching from non-existent character, check the group assignment for player is working." )
        return
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

    camera.follow_target = new_character

func handle_player_input() -> void:
    if Input.is_action_just_pressed("ui_accept"):
        var actionables = actionable_finder.get_overlapping_areas()
        if actionables.size() > 0:
            actionables[0].parent.velocity = Vector2(0, 0)
            actionables[0].action()
    var direction := Input.get_axis("ui_left", "ui_right")
    if direction:
        velocity.x = direction * SPEED * PLAYER_VELOCITY_MULTIPLIER
    else:
        velocity.x = move_toward(velocity.x, 0, SPEED)

func return_to_resting_location() -> void:
    if abs(position.x - resting_location.x) < 3:
        position.x = resting_location.x
        velocity.x = 0
    else:
        var direction: float = signf(resting_location.x - position.x)
        velocity.x = direction * SPEED

func show_emote() -> void:
    var tween = create_tween()
    tween.tween_property($Emote, "modulate:a", 1, 0.1)
    tween.tween_property($Emote, "scale", Vector2(1.5, 1.5), 0.1)
    tween.tween_property($Emote, "scale", Vector2(1, 1), 0.5)

func hide_emote() -> void:
    var tween = create_tween()
    tween.tween_property($Emote, "modulate:a", 0, 0.5)

func _on_actionable_finder_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
    if area.has_method("action"):
        area.get_parent().show_emote()

func _on_actionable_finder_area_shape_exited(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
    if area.has_method("action"):
        area.get_parent().hide_emote()
