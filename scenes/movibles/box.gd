# Objeto_Agarrar.gd
extends RigidBody2D
class_name ObjetoAgarrar

var agarrado := false
var agarre_offset := Vector2.ZERO

# Parámetros ajustables
@export var fuerza_agarre: float = 2000.0
@export var amortiguacion: float = 10.0
@export var limite_velocidad: float = 5000.0

func _ready():
	pass

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and not agarrado:
			_intentar_agarrar()
		elif not event.pressed and agarrado:
			_soltar()

func _intentar_agarrar() -> void:
	var click_global = get_global_mouse_position()
	
	# Verificar si el click está dentro del objeto
	if _punto_dentro(click_global):
		
		agarrado = true
		agarre_offset = click_global - global_position
		# Desactivar gravedad mientras se agarra
		gravity_scale = 0.0
		
		# Reducir fricción para movimiento más suave
		linear_damp = 0.5
		agarrado_func()

func agarrado_func():
	pass

func _soltar() -> void:
	agarrado = false
	gravity_scale = 1.0
	linear_damp = 0.1  # Restaurar fricción original

func _physics_process(delta: float) -> void:
	if agarrado:
		var mouse_pos = get_global_mouse_position()
		var target_pos = mouse_pos - agarre_offset
		var desplazamiento = target_pos - global_position
		
		# Calcular fuerza basada en el desplazamiento (como un resorte)
		var fuerza = desplazamiento * fuerza_agarre * delta
		
		# Limitar fuerza máxima
		if fuerza.length() > limite_velocidad:
			fuerza = fuerza.normalized() * limite_velocidad
		
		# Aplicar fuerza en el punto de agarre (esto causa rotación)
		apply_force(fuerza, mouse_pos - global_position)
		
		# Amortiguación para evitar oscilaciones
		linear_velocity *= (1.0 - amortiguacion * delta)

func _punto_dentro(punto: Vector2) -> bool:
	# Método más simple: usar el área de colisión directamente
	var shape = $CollisionShape2D.shape
	var transform = $CollisionShape2D.global_transform
	
	if shape is CircleShape2D:
		var radio = shape.radius
		return punto.distance_to(global_position) <= radio
	elif shape is RectangleShape2D:
		var extents = shape.extents
		var local_point = transform.affine_inverse() * punto
		return abs(local_point.x) <= extents.x and abs(local_point.y) <= extents.y
	
	return false

func restore_default_cursor():
	# Volver al cursor por defecto
	Input.set_default_cursor_shape(Input.CursorShape.CURSOR_ARROW)
