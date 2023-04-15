extends Panel

signal moved(new_position)
signal deleted()
signal type_changed(new_type)
signal initial_value_changed()
signal start_connection()
signal end_connection()

export(Resource) var node

onready var _edit := $Edit as Control
onready var _view := $View as Control
onready var _style := $Style as Control

func _ready():
	_set_mode(0)
	$Edit/ID.text = str(node.id)
	$Edit/Value.text = str(node.value)
	$Edit/ConnectOut.node = self
	$Edit/ConnectOut.accept_incoming = false
	$Edit/ConnectIn.node = self

func connection_point_out() -> Vector2:
	return rect_position + $Edit/ConnectOut.rect_position + $Edit/ConnectOut.rect_size / 2

func connection_point_in() -> Vector2:
	return rect_position + $Edit/ConnectIn.rect_position + $Edit/ConnectIn.rect_size / 2

func _set_mode(mode: int) -> void:
	_edit.active = false
	_view.active = false
	_style.active = false
	match mode:
		0:
			_edit.active = true
		1:
			_view.active = true
		2:
			_style.active = true

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
	emit_signal("type_changed", new_type)

func _initial_value_changed(new_value) -> void:
	node.initial_value = new_value
	print("new value is " + str(new_value))
	emit_signal("initial_value_changed")

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

func set_input_node(val: bool) -> void:
	# TODO: This will be used in the VIEW mode
	node.accepts_input = val

func set_value(value) -> void:
	print("Setting value to %s" % str(value))
	node.value = value
	$Edit/Value.text = str(node.value)
