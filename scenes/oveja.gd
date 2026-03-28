extends ObjetoAgarrar
class_name OvejaSimple

@export var velocidad_maxima: float = 300.0
@export var fuerza_movimiento: float = 500.0
@export var intervalo_cambio: float = 2.0

var moviendo_derecha: bool = true
var tiempo_cambio: float = 0.0
@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	super._ready()
	tiempo_cambio = randf_range(0.5, intervalo_cambio)

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	if not agarrado:
		# Movimiento automático
		tiempo_cambio -= delta
		if tiempo_cambio <= 0:
			moviendo_derecha = not moviendo_derecha
			tiempo_cambio = intervalo_cambio
			if sprite:
				sprite.scale.x = abs(sprite.scale.x) * (-1 if moviendo_derecha else 1)
		
		# Aplicar fuerza
		var direccion = 1 if moviendo_derecha else -1
		if abs(linear_velocity.x) < velocidad_maxima:
			apply_central_force(Vector2(direccion * fuerza_movimiento, 0))
