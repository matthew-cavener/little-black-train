extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@export var is_player_controlled: bool = true
@export var character_name: String = "Alice"
@export var resting_location: Vector2 = Vector2(0, 0)
@export var player_velocity_multiplier: float = 1.5

@onready var actionable = $Actionable
@onready var actionable_finder = $ActionableFinder

func _ready() -> void:
    DialogueManager.dialogue_started.connect(_on_dialogue_started)
    DialogueManager.dialogue_ended.connect(_on_dialogue_finished)

func _physics_process(delta: float) -> void:
    if not is_on_floor():
        velocity += get_gravity() * delta
    if is_player_controlled:
        $Actionable/ActionableShape.set_deferred("disabled", true)
        $ActionableFinder/ActionableFinderShape.set_deferred("disabled", false)
        handle_player_input()
    else:
        $Actionable/ActionableShape.set_deferred("disabled", false)
        $ActionableFinder/ActionableFinderShape.set_deferred("disabled", true)
        return_to_resting_location()
    move_and_slide()

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
        var direction: int = signi(resting_location.x - position.x)
        velocity.x = direction * SPEED

func _on_dialogue_finished():
    set_process_input(true)

func _on_dialogue_started():
    set_process_input(false)
