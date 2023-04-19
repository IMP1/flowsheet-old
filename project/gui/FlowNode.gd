extends Panel

signal moved(new_position)
signal deleted()
signal type_changed()
signal initial_value_changed()
signal start_connection()
signal end_connection()

var node: FlowNode

onready var _edit := $Edit as Control
onready var _view := $View as Control
onready var _style := $Style as Control
onready var _input := $InitalValue as Control
onready var _connection_in := $Edit/ConnectIn as FlowsheetNodeConnector
onready var _connection_out := $Edit/ConnectOut as FlowsheetNodeConnector
onready var _node_info := $Edit/EditMenu/NodeInfo as Label


func _ready():
	set_mode(0)
	_node_info.text = "Node ID: %d" % node.id
	_connection_in.node = self
	_connection_in.is_output_connector = false
	_connection_out.node = self
	_connection_out.accept_incoming = false
	_input.set_type(node.type)
	_view.editable = node.accepts_input
	set_value(node.value)


func connection_point_out() -> Vector2:
	return rect_position + _connection_out.rect_position + _connection_out.rect_size / 2


func connection_point_in() -> Vector2:
	return rect_position + _connection_in.rect_position + _connection_in.rect_size / 2


func set_mode(mode: int) -> void:
	_edit.active = false
	_edit.visible = false
	_view.active = false
	_view.visible = false
	_style.active = false
	_style.visible = false
	match mode:
		0:
			_edit.active = true
			_edit.visible = true
		1:
			_view.active = true
			_view.visible = true
		2:
			_style.active = true
			_style.visible = true


func _deleted() -> void:
	emit_signal("deleted")


func _move_by(movement: Vector2) -> void:
	rect_position += movement
	emit_signal("moved", rect_position)


func _move_to(position: Vector2) -> void:
	rect_global_position = position
	emit_signal("moved", rect_position)


func _type_changed(new_type: int) -> void:
	node.type = new_type
	node.initial_value = FlowNode.default_value(new_type)
	_input.set_type(new_type)
	_edit.set_initial_value(node.initial_value, node.type)
	emit_signal("type_changed")


func _initial_value_changed(new_value) -> void:
	node.initial_value = new_value
	_edit.set_initial_value(node.initial_value, node.type)
	emit_signal("initial_value_changed")


func _editable_changed(new_value: bool) -> void:
	node.accepts_input = new_value
	_view.editable = node.accepts_input


func _start_connection() -> void:
	emit_signal("start_connection")


func _end_connection(source, target) -> void:
	emit_signal("end_connection", source, target)


func prepare_for_connection() -> void:
	_connection_in.highlight()


func stop_connection() -> void:
	yield(get_tree(), "idle_frame")
	_connection_in.reset()
	_connection_out.reset()


func set_value(value) -> void:
	node.value = value
	_edit.set_value(value)
	_view.set_value(value)
