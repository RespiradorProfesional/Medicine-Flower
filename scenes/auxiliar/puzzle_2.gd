extends PuzzleBase

@onready var marker_2d: Marker2D = $Marker2D

func _on_area_2d_body_entered(body: Node2D) -> void:
	print("entro")
	
	if body is Player:
		body.global_position = marker_2d.global_position
	
	# Si es un RigidBody2D
	if body is RigidBody2D:
		# Obtener la escena del objeto que cayó
		var scene = body.scene_file_path
		
		# Cargar e instanciar la misma escena
		if scene:
			var nuevo_objeto = load(scene).instantiate()
			call_deferred("add_child", nuevo_objeto)

			# Esperar a que esté en el árbol
			await nuevo_objeto.ready

			nuevo_objeto.global_position = marker_2d.global_position
		
		# USAR CALL_DEFERRED para eliminar el original
		body.call_deferred("queue_free")
