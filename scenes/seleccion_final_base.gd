extends Node2D


var can_interact= false
@export var dialogue_resource : DialogueResource

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var color_rect: ColorRect = $CanvasLayer/ColorRect

func _ready() -> void:
	DialogueManager.dialogue_ended.connect(_on_dialogue_finished)

func _on_dialogue_finished(dialogue)->void:
	print(dialogue)

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("interact") and can_interact:
		DialogueManager.show_dialogue_balloon(dialogue_resource,"",[self])
		color_rect.visible=true

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		can_interact= true
		sprite_2d.visible=true


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is Player:
		can_interact= false
		sprite_2d.visible=false
