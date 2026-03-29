extends CharacterBody2D
class_name Player

@export var speed := 200.0
@export var jump_force := -400.0
@export var gravity := 900.0

var agarrando = false
var facing_direction: int = 1  # 1 = derecha, -1 = izquierda
var last_direction: float = 0

var mose_default = preload("res://assets/sprites/mouse/puntero.png")
var mose_to_hold = preload("res://assets/sprites/mouse/to_hold.png")
var mose_hold = preload("res://assets/sprites/mouse/hold.png")
var objeto_agarrado: ObjetoAgarrar = null

@onready var pose_alernativa: Sprite2D = $sprites/pose_alernativa

# Referencia al nodo de sprites
@onready var sprites: Node2D = $sprites
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Guardar la escala original
var original_scale: Vector2
@onready var pasos: AudioStreamPlayer2D = $pasos

func _ready():
	# Guardar la escala original del nodo sprites
	if sprites:
		original_scale = sprites.scale
		# Asegurar que la escala X sea positiva
		sprites.scale.x = abs(original_scale.x)
		facing_direction = 1
	
	# Reproducir animación idle al inicio
	if animation_player:
		animation_player.play("idle")

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		
		if event.pressed:
			# SOLO al hacer click, detectas el objeto
			var obj = get_object_under_mouse()
			if obj is ObjetoAgarrar:
				objeto_agarrado = obj
				agarrando = true
		
		else:
			# Al soltar, limpias
			agarrando = false
			objeto_agarrado = null

	# 🎯 Lógica del cursor
	if agarrando and objeto_agarrado != null:
		Input.set_custom_mouse_cursor(mose_hold)
	else:
		var obj_hover = get_object_under_mouse()
		if obj_hover is ObjetoAgarrar:
			Input.set_custom_mouse_cursor(mose_to_hold)
		else:
			Input.set_custom_mouse_cursor(mose_default)

func _physics_process(delta):
	# Aplicar gravedad
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0

	# Movimiento horizontal
	if not agarrando:
		var direction := Input.get_axis("ui_left", "ui_right")
		velocity.x = direction * speed
		
		# Guardar última dirección para cuando se detenga
		if direction != 0:
			last_direction = direction
		
		# Actualizar dirección visual y animación
		update_facing_direction(direction)
		update_animation(direction)

		# Salto
		if Input.is_action_just_pressed("ui_accept") and is_on_floor():
			velocity.y = jump_force
	else:
		velocity.x = 0
		# Si está agarrando, mantener la animación idle con la última dirección
		animation_player.play("carga")

	# Mover el personaje
	move_and_slide()

func update_facing_direction(direction: float):
	if not sprites:
		return
	
	# Actualizar dirección si hay movimiento
	if direction != 0:
		var new_direction = sign(direction)
		
		if new_direction != facing_direction:
			facing_direction = new_direction
			
			# Aplicar la escala manteniendo el tamaño original
			# Escala X = (valor absoluto de la escala original) * dirección
			sprites.scale.x = abs(original_scale.x) * facing_direction
			# Mantener la escala Y original
			sprites.scale.y = original_scale.y

func update_animation(direction: float):
	if not animation_player:
		return
	
	# Determinar qué animación reproducir
	if direction != 0:
		# Está caminando
		if animation_player.current_animation != "walk":
			animation_player.play("walk")
	else:
		# Está quieto
		if animation_player.current_animation != "idle":
			animation_player.play("idle")

func get_object_under_mouse() -> Node:
	var mouse_pos = get_global_mouse_position()
	var space_state = get_world_2d().direct_space_state
	
	var query = PhysicsPointQueryParameters2D.new()
	query.position = mouse_pos
	query.collision_mask = 0xFFFFFFFF  # Todas las capas
	query.collide_with_areas = true
	query.collide_with_bodies = true
	
	var results = space_state.intersect_point(query)
	
	if results.size() > 0:
		return results[0].collider
	return null
