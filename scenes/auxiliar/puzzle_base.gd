extends Node2D
class_name PuzzleBase

@onready var npc_camera: PhantomCamera2D = $npc_camera
@onready var player_camera: PhantomCamera2D = $player_camera

@onready var phantom_camera_2d: PhantomCamera2D = $PhantomCamera2D
@onready var colision_invisible_wall: CollisionShape2D = $inivisble_wall/colision_invisible_wall
var firts_entry=false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	DialogueManager.dialogue_ended.connect(_on_dialogue_finished)

func _on_dialogue_finished(dialogue):
	player_camera.priority=0
	npc_camera.priority=0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_enter_area_body_entered(body: Node2D) -> void:
	if body is Player:
		phantom_camera_2d.priority=15
		firts_entry_action()
		firts_entry=true

func firts_entry_action():
	pass

func _on_exit_area_body_entered(body: Node2D) -> void:
	if body is Player:
		phantom_camera_2d.priority=0

func finished_puzzle() ->void:
	colision_invisible_wall.set_deferred("disabled", true)

func focus_player_camera() -> void:
	player_camera.priority=20
	npc_camera.priority=0

func focus_npc_camera() -> void:
	player_camera.priority=0
	npc_camera.priority=20


var area_1_complete=false
var area_2_complete=false

func _on_area_2d_2_body_entered(body: Node2D) -> void:
	area_2_complete=true
	if area_1_complete and area_2_complete:
		finished_puzzle()

func _on_area_2d_2_body_exited(body: Node2D) -> void:
	area_2_complete=false
	if !area_1_complete or !area_2_complete:
		colision_invisible_wall.set_deferred("disabled", false)

func _on_area_2d_body_entered(body: Node2D) -> void:
	area_1_complete=true
	if area_1_complete and area_2_complete:
		finished_puzzle()


func _on_area_2d_body_exited(body: Node2D) -> void:
	area_1_complete=false
	if !area_1_complete or !area_2_complete:
		colision_invisible_wall.set_deferred("disabled", false)
