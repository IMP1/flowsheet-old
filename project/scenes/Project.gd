extends Control

enum EditorMode { EDIT, VIEW, STYLE }

const NODE = preload("res://gui/FlowNode.tscn")
const LINK = preload("res://gui/FlowLink.tscn")

var flowsheet: FlowSheet
var _next_node_id: int = 1
var _graph: DirectedAcyclicGraph = DirectedAcyclicGraph.new()

onready var undo_stack := $UndoStack as Node
onready var canvas := $Container/Flowsheet as Control
onready var _partial_connection := $Container/Flowsheet/PartialConnection as Line2D
onready var _nodes := $Container/Flowsheet/Nodes as Control
onready var _links := $Container/Flowsheet/Links as Control


func _ready() -> void:
	_partial_connection.visible = false


func _set_mode(mode: int) -> void:
	$EditActions.visible = (mode == EditorMode.EDIT)
	for node in _nodes.get_children():
		node.set_mode(mode)
	for link in _links.get_children():
		link.set_mode(mode)


func refresh() -> void:
	_propogate()


func _propogate(changed_node = null) -> void:
	if changed_node == null:
		for id in _graph._root_nodes:
			var node = _nodes.get_node(str(id))
			_propogate(node)
		return
	_calculate_value(changed_node)
	for child_id in _graph.children(changed_node.node.id):
		var child_node = _nodes.get_node(str(child_id))
		_propogate(child_node)


func _calculate_value(node: Control) -> void:
#	print("recalculating value for node %d" % node.node.id)
	var value = node.node.initial_value
#	print("starting value is %s" % str(value))
	for link in _links.get_children():
		if link.target_node == node:
			var code: String = link.link.formula
			if code.empty():
				continue
			var context := FormulaContext.new()
			var expr := Expression.new()
			var parse_result := expr.parse(code, ["IN", "OUT"])
			if parse_result != OK:
				# TODO: Communicate this error to the user
				print("Couldn't parse formula '%s'.\n%s" % [code, expr.get_error_text()])
				continue
			var result = expr.execute([link.source_node.node.value, value], context)
			if expr.has_execute_failed():
				# TODO: Communicate this error to the user
				print("Couldn't execute formula.\n%s" % expr.get_error_text())
				continue
			value = result
#			print("value is now %s" % str(value))
	node.set_value(value)


func add_node(pos: Vector2) -> void:
	var id: int = _next_node_id
	_next_node_id += 1
	
	var node_data := FlowNode.new()
	node_data.id = id
	flowsheet.add_node(node_data, pos)
	
	var node: Control = NODE.instance()
	node.node = node_data
	_nodes.add_child(node)
	node.name = str(id)
	node.margin_left = pos.x
	node.margin_top = pos.y
	node.connect("deleted", self, "delete_node", [node])
	node.connect("start_connection", self, "_start_connection", [node])
	node.connect("end_connection", self, "_add_link")
	node.connect("initial_value_changed", self, "_propogate", [node])
	node.connect("type_changed", self, "_propogate", [node])
	
	_graph.add_node(id)


func delete_node(node: Control) -> void:
	flowsheet.remove_node(node.node)
	_graph.remove_node(node.node.id)
	node.queue_free()


func _start_connection(node: Control) -> void:
	_partial_connection.visible = true
	_partial_connection.clear_points()
	_partial_connection.add_point(node.connection_point_out())
	_partial_connection.add_point(get_global_mouse_position() - canvas.rect_global_position)
	for n in _nodes.get_children():
		if node == n:
			continue
		if not _graph.is_descendent_of(node.node.id, n.node.id):
			n.prepare_for_connection()


func _add_link(source_node: Control, target_node: Control) -> void:
	var link_data := FlowLink.new()
	link_data.source_id = source_node.node.id
	link_data.target_id = target_node.node.id
	link_data.target_ordering = 0 # TODO: Get this somehow
	flowsheet.add_link(link_data)
	
	var link: Control = LINK.instance()
	_links.add_child(link)
	link.link = link_data
	link.set_connection(source_node, target_node)
	link.connect("deleted", self, "_delete_link", [link])
	link.connect("formula_changed", self, "_propogate", [target_node])
	
	_graph.connect_nodes(source_node.node.id, target_node.node.id)
	target_node.set_input_node(false)


func _delete_link(link: Control) -> void:
	link.queue_free()


func _process(_delta: float) -> void:
	if _partial_connection.visible:
		_partial_connection.set_point_position(1, get_global_mouse_position() - canvas.rect_global_position)


func _input(event: InputEvent) -> void:
	if _partial_connection.visible and event.is_action_released("drag"):
		_partial_connection.visible = false
		for n in _nodes.get_children():
			n.stop_connection()
	if event.is_action_pressed("ui_focus_next"):
		_graph.dump()
