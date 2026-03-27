extends CharacterBody2D
class_name Player

@export var speed := 200.0
@export var jump_force := -400.0
@export var gravity := 900.0

func _physics_process(delta):
	# Aplicar gravedad
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0

	# Movimiento horizontal
	var direction := Input.get_axis("ui_left", "ui_right")
	velocity.x = direction * speed

	# Salto
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_force

	# Mover el personaje
	move_and_slide()
