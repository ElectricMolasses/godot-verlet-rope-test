class_name Rope2_5D extends Node3D
## A verlet rope designed for 3D space, that is only calculated within 2D space.

@export var head_anchor: Node3D
@export var tail_anchor: Node3D

@export var use_tail_anchor: bool = true

@export var draw_debug_lines: bool = true

@export var iterations: int = 80;

@export var total_nodes: int = 40;
@export var node_distance: float = .1;

@export var gravity = Vector2(0, -9.8)

var nodes: Array[VerletNode]

@onready var rope_plane: Plane = Plane(Vector3(0, 0, 1), self.position.z)

class VerletNode:
	var position: Vector2
	var old_position: Vector2

	func set_start(start_position: Vector2) -> void:
		self.position = start_position
		self.old_position = start_position

	func step(delta: float, gravity: Vector2) -> void:
		var temp: Vector2 = self.position
		self.position += (self.position - self.old_position) + gravity * delta * delta
		self.old_position = temp

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

		node.step(delta, gravity)

func apply_constraints() -> void:
	for i in nodes.size()-1:
		var node_1: VerletNode = nodes[i]
		var node_2: VerletNode = nodes[i + 1]

		if i == 0 && head_anchor:
			node_1.position = Vector2(head_anchor.position.x, head_anchor.position.y)
		if use_tail_anchor && i == nodes.size()-2:
			node_2.position = Vector2(tail_anchor.position.x, tail_anchor.position.y)

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
