extends CharacterBody2D
class_name Player

@export var speed := 200.0
@export var jump_force := -400.0
@export var gravity := 900.0

var agarrando = false
var facing_direction: int = 1  # 1 = derecha, -1 = izquierda
var last_direction: float = 0
var is_walking: bool = false
var footstep_timer: float = 0.0

var mose_default = preload("res://assets/sprites/mouse/puntero.png")
var mose_to_hold = preload("res://assets/sprites/mouse/to_hold.png")
var mose_hold = preload("res://assets/sprites/mouse/hold.png")
var objeto_agarrado: ObjetoAgarrar = null

@onready var pose_alernativa: Sprite2D = $sprites/pose_alernativa
@onready var sprites: Node2D = $sprites
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Audio
@onready var footsteps: AudioStreamPlayer2D = $Footsteps
@onready var jump_sound: AudioStreamPlayer2D = $JumpSound
@onready var grab_sound: AudioStreamPlayer2D = $GrabSound
@onready var landing_sound: AudioStreamPlayer2D = $LandingSound
@onready var charge_sound: AudioStreamPlayer2D = $ChargeSound  # Para animación "carga"

# Guardar la escala original
var original_scale: Vector2
var was_on_floor: bool = true

# Configuración de sonidos
@export var footstep_interval: float = 0.4  # Tiempo entre pasos (segundos)
@export var footstep_pitch_variation: float = 0.1  # Variación de tono

func _ready():
	# Guardar la escala original del nodo sprites
	if sprites:
		original_scale = sprites.scale
		sprites.scale.x = abs(original_scale.x)
		facing_direction = 1
	
	# Reproducir animación idle al inicio
	if animation_player:
		footsteps.stop()
		animation_player.play("idle")
	
	# Configurar sonidos si existen
	setup_audio()

func setup_audio():
	# Si los nodos de audio no existen, los creamos
	if not footsteps:
		footsteps = AudioStreamPlayer2D.new()
		footsteps.name = "Footsteps"
		add_child(footsteps)
	
	if not jump_sound:
		jump_sound = AudioStreamPlayer2D.new()
		jump_sound.name = "JumpSound"
		add_child(jump_sound)
	
	if not grab_sound:
		grab_sound = AudioStreamPlayer2D.new()
		grab_sound.name = "GrabSound"
		add_child(grab_sound)
	
	if not landing_sound:
		landing_sound = AudioStreamPlayer2D.new()
		landing_sound.name = "LandingSound"
		add_child(landing_sound)
	
	if not charge_sound:
		charge_sound = AudioStreamPlayer2D.new()
		charge_sound.name = "ChargeSound"
		add_child(charge_sound)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		
		if event.pressed:
			var obj = get_object_under_mouse()
			if obj is ObjetoAgarrar:
				objeto_agarrado = obj
				agarrando = true
				play_sound(grab_sound)  # Sonido de agarrar
		
		else:
			agarrando = false
			objeto_agarrado = null

	# Lógica del cursor
	if agarrando and objeto_agarrado != null:
		Input.set_custom_mouse_cursor(mose_hold)
	else:
		var obj_hover = get_object_under_mouse()
		if obj_hover is ObjetoAgarrar:
			Input.set_custom_mouse_cursor(mose_to_hold)
		else:
			Input.set_custom_mouse_cursor(mose_default)

func _physics_process(delta):
	var was_on_floor_before = is_on_floor()
	
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
		
		# Manejar sonido de pasos
		handle_footsteps(direction, delta)

		# Salto
		if Input.is_action_just_pressed("ui_accept") and is_on_floor():
			velocity.y = jump_force
			play_sound(jump_sound)  # Sonido de salto
	else:
		velocity.x = 0
		# Si está agarrando, mantener la animación "carga"
		if animation_player.current_animation != "carga":
			animation_player.play("carga")
			# Sonido de carga (loop opcional)
			if charge_sound and not charge_sound.playing:
				charge_sound.play()

	# Detectar aterrizaje
	var just_landed = is_on_floor() and not was_on_floor_before
	if just_landed and velocity.y >= 0:
		play_sound(landing_sound)  # Sonido de aterrizaje

	# Mover el personaje
	move_and_slide()

func handle_footsteps(direction: float, delta: float):
	# Verificar si está caminando
	var is_moving = direction != 0 and is_on_floor()
	
	if is_moving:
		# Reducir el timer
		footstep_timer -= delta
		
		# Reproducir paso cuando el timer llega a 0
		if footstep_timer <= 0:
			play_footstep()
			# Resetear timer con variación aleatoria
			footstep_timer = footstep_interval + randf_range(-0.05, 0.05)
	else:
		# No está caminando, resetear timer
		footstep_timer = 0

func play_footstep():
	if not footsteps or not footsteps.stream:
		return
	
	# Variar el tono para que no suene siempre igual
	footsteps.pitch_scale = 1.0 + randf_range(-footstep_pitch_variation, footstep_pitch_variation)
	play_sound(footsteps)

func play_sound(audio_player: AudioStreamPlayer2D):
	if audio_player and audio_player.stream:
		audio_player.play()

func update_facing_direction(direction: float):
	if not sprites:
		return
	
	# Actualizar dirección si hay movimiento
	if direction != 0:
		var new_direction = sign(direction)
		
		if new_direction != facing_direction:
			facing_direction = new_direction
			
			# Aplicar la escala manteniendo el tamaño original
			sprites.scale.x = abs(original_scale.x) * facing_direction
			sprites.scale.y = original_scale.y

func update_animation(direction: float):
	if not animation_player:
		return
	
	# Determinar qué animación reproducir
	if direction != 0:
		# Está caminando
		if animation_player.current_animation != "walk":
			animation_player.play("walk")
			# Detener sonido de carga si estaba sonando
			if charge_sound and charge_sound.playing:
				charge_sound.stop()
	else:
		# Está quieto
		if animation_player.current_animation != "idle":
			animation_player.play("idle")
			# Detener sonido de carga si estaba sonando
			if charge_sound and charge_sound.playing:
				charge_sound.stop()

func get_object_under_mouse() -> Node:
	var mouse_pos = get_global_mouse_position()
	var space_state = get_world_2d().direct_space_state
	
	var query = PhysicsPointQueryParameters2D.new()
	query.position = mouse_pos
	query.collision_mask = 0xFFFFFFFF
	query.collide_with_areas = true
	query.collide_with_bodies = true
	
	var results = space_state.intersect_point(query)
	
	if results.size() > 0:
		return results[0].collider
	return null
