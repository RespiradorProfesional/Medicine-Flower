extends PuzzleBase

@export var ovejas_total=3
@export var dialogue_resource : DialogueResource 
@export var dialogue_resource_2 : DialogueResource 

var ovejas_count=0
var already_finished=false

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is OvejaSimple:
		ovejas_count+=1
		print(ovejas_count)
		if ovejas_count>=ovejas_total and not already_finished:
			print("finish")
			finished_puzzle()
			already_finished=true

func finished_puzzle() ->void:
	colision_invisible_wall.set_deferred("disabled", true)
	DialogueManager.show_dialogue_balloon(dialogue_resource_2 ,"",[self])

func firts_entry_action():
	if not firts_entry:
		DialogueManager.show_dialogue_balloon(dialogue_resource ,"",[self])

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is OvejaSimple:
		ovejas_count-=1
