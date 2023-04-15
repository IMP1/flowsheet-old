extends Control

enum EditorMode { EDIT, VIEW, STYLE }

const NODE = preload("res://gui/FlowNode.tscn")
const LINK = preload("res://gui/FlowLink.tscn")

var flowsheet: FlowSheet
var _next_node_id: int = 1

onready var undo_stack := $UndoStack as Node
onready var canvas := $Container/Flowsheet as Control
onready var _partial_connection := $Container/Flowsheet/PartialConnection as Line2D
onready var _nodes := $Container/Flowsheet/Nodes as Control
onready var _links := $Container/Flowsheet/Links as Control

func _ready() -> void:
	_partial_connection.visible = false

func _set_mode(mode: int) -> void:
	print("new mode is %d" % mode)
	$EditActions.visible = (mode == EditorMode.EDIT)
	# TODO: Go throw every node and set its mode

func refresh() -> void:
	_propogate()

func _propogate() -> void:
	pass

func add_node(pos: Vector2) -> void:
	var node: Control = NODE.instance()
	node.node = FlowNode.new()
	node.node.id = _next_node_id
	flowsheet.add_node(node.node, pos)
	_nodes.add_child(node)
	node.margin_left = pos.x
	node.margin_top = pos.y
	_next_node_id += 1
	# TODO: Add node to flowsheet data resource
	node.connect("deleted", self, "delete_node", [node])
	node.connect("start_connection", self, "_start_connection", [node])
	node.connect("end_connection", self, "_end_connection")

func delete_node(node: Control) -> void:
	node.queue_free()

func _start_connection(node: Control) -> void:
	_partial_connection.visible = true
	_partial_connection.clear_points()
	_partial_connection.add_point(node.connection_point_out())
	_partial_connection.add_point(get_global_mouse_position() - canvas.rect_global_position)
	for n in _nodes.get_children():
		if node == n:
			continue
		print(n)
		n.prepare_for_connection()

func _end_connection(source_node: Control, target_node: Control) -> void:
	var link: Control = LINK.instance()
	_links.add_child(link)
	link.set_connection(source_node, target_node)
	link.connect("deleted", self, "_delete_link", [link])
	print("ended connection")

func _delete_link(link: Control) -> void:
	link.queue_free()

func _process(_delta: float) -> void:
	if _partial_connection.visible:
		# TODO: Add snapping?
		_partial_connection.set_point_position(1, get_global_mouse_position() - canvas.rect_global_position)

func _input(event: InputEvent) -> void:
	if _partial_connection.visible and event.is_action_released("drag"):
		_partial_connection.visible = false
		for n in _nodes.get_children():
			n.stop_connection()
