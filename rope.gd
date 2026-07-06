class_name Rope extends Node3D
## z-position will just be wherever it's set on z in 3D space.

@export var draw_debug_lines: bool = true

class VerletNode:
	var position: Vector2
	var old_position: Vector2

	func set_start(start_position: Vector2) -> void:
		self.position = start_position
		self.old_position = start_position

func step_verlet(delta: float, node: VerletNode) -> void:
	var temp: Vector2 = node.position
	node.position += (node.position - node.old_position) + gravity * delta * delta
	node.old_position = temp

var iterations: int = 80;

var total_nodes: int = 40;
var node_distance: float = .1;
@export var gravity = Vector2(0, -9.8)

var nodes: Array[VerletNode]

@onready var rope_plane: Plane = Plane(Vector3(0, 0, 1), self.position.z)

func _ready() -> void:
	nodes = []
	nodes.resize(total_nodes)

	var pos: Vector2 = Vector2(position.x, position.y)
	for i in nodes.size():
		nodes[i] = VerletNode.new()
		nodes[i].set_start(pos)
		pos.y -= node_distance
	
	if draw_debug_lines:
		create_debug_lines()

func _process(_delta: float) -> void:
	if draw_debug_lines:
		update_debug_lines()

func _physics_process(delta: float) -> void:
	simulate(delta)
	for _i in range(iterations):
		apply_constraints()

func simulate(delta: float) -> void:
	for i in nodes.size():
		var node: VerletNode = nodes[i]

		step_verlet(delta, node)

func apply_constraints() -> void:
	for i in nodes.size()-1:
		var node_1: VerletNode = nodes[i]
		var node_2: VerletNode = nodes[i + 1]

		if i == 0 && Input.is_action_pressed("LeftClick"):
			var viewport: Viewport = get_viewport()
			var camera_3d: Camera3D = viewport.get_camera_3d()

			var mouse_position = viewport.get_mouse_position()

			var origin: Vector3 = camera_3d.project_ray_origin(mouse_position)
			var direction: Vector3 = camera_3d.project_ray_normal(mouse_position)

			var result = rope_plane.intersects_ray(origin, direction)

			node_1.position = Vector2(result.x, result.y)

		var diff_x: float = node_1.position.x - node_2.position.x		
		var diff_y: float = node_1.position.y - node_2.position.y
		var dist: float = node_1.position.distance_to(node_2.position)
		var difference: float = 0.0

		if (dist > 0):
			difference = (node_distance - dist) / dist;

		@warning_ignore("SHADOWED_VARIABLE_BASE_CLASS")
		var translate: Vector2 = Vector2(diff_x, diff_y) * (0.5 * difference)

		node_1.position += translate
		node_2.position -= translate

var gizmo_lines: Array[GizmoLine]

func create_debug_lines() -> void:
	gizmo_lines = []
	gizmo_lines.resize(nodes.size() - 1)
	for i in nodes.size() - 1:
		var gizmo_line: GizmoLine = GizmoLine.new()
		gizmo_lines[i] = gizmo_line

	for line in gizmo_lines:
		add_child(line)

	update_debug_lines()

func update_debug_lines() -> void:
	for i in nodes.size() - 1:
		var gizmo_line = gizmo_lines[i]
		gizmo_line.set_start(Vector3(
			nodes[i].position.x, 
			nodes[i].position.y, 
			0.0
		))
		gizmo_line.set_end(Vector3(
			nodes[i + 1].position.x, 
			nodes[i + 1].position.y, 
			0.0
		))
		if i % 2:
			gizmo_line.set_color(Color.GREEN)
		else:
			gizmo_line.set_color(Color.WHITE)
