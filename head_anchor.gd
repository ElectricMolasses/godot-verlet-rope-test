extends Node3D

@onready var rope_plane: Plane = Plane(Vector3(0, 0, 1), self.position.z)

func _process(_delta: float) -> void:
	if Input.is_action_pressed("LeftClick"):
		var viewport: Viewport = get_viewport()
		var camera_3d: Camera3D = viewport.get_camera_3d()

		var mouse_position = viewport.get_mouse_position()

		var origin: Vector3 = camera_3d.project_ray_origin(mouse_position)
		var direction: Vector3 = camera_3d.project_ray_normal(mouse_position)

		var result = rope_plane.intersects_ray(origin, direction)
		self.position = result
