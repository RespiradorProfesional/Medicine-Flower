extends Node2D

var can_interact= false
@export var dialogue_resource : DialogueResource

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("interact") and can_interact:
		DialogueManager.show_dialogue_balloon(dialogue_resource,"",[self])

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		can_interact= true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is Player:
		can_interact= false
