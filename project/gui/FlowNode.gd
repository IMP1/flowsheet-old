extends Panel

signal moved(new_position)
signal deleted()
signal type_changed()
signal initial_value_changed()
signal start_connection()
signal end_connection()

export(Resource) var node

onready var _edit := $Edit as Control
onready var _view := $View as Control
onready var _style := $Style as Control


func _ready():
	set_mode(0)
	$Edit/EditMenu/NodeInfo.text = "Node ID: %d" % node.id
	$Edit/Value/Label.text = str(node.value)
	$Edit/ConnectOut.node = self
	$Edit/ConnectOut.accept_incoming = false
	$Edit/ConnectIn.node = self
	_edit._new_type_selected(node.type)


func connection_point_out() -> Vector2:
	return rect_position + $Edit/ConnectOut.rect_position + $Edit/ConnectOut.rect_size / 2


func connection_point_in() -> Vector2:
	return rect_position + $Edit/ConnectIn.rect_position + $Edit/ConnectIn.rect_size / 2


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
	emit_signal("type_changed")


func _initial_value_changed(new_value) -> void:
	print("initial value changed for node #%d" % node.id)
	node.initial_value = new_value
	emit_signal("initial_value_changed")
	_view.input.value = new_value # TODO: This won't work with all node types
	_edit.value_setter.value = new_value # TODO: This won't work with all node types


func _editable_changed(new_value: bool) -> void:
	node.accepts_input = new_value
	_view._set_editable(new_value)


func _start_connection() -> void:
	emit_signal("start_connection")


func _end_connection(source, target) -> void:
	emit_signal("end_connection", source, target)


func prepare_for_connection() -> void:
	$Edit/ConnectIn.highlight()


func stop_connection() -> void:
	yield(get_tree(), "idle_frame")
	$Edit/ConnectIn.reset()
	$Edit/ConnectOut.reset()


func set_value(value) -> void:
	node.value = value
	$Edit/Value/Label.text = str(value)
	_view.set_value(value)
