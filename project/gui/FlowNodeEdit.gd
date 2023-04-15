extends Control

signal type_changed(new_type)
signal initial_value_changed(new_value)
signal moved_by(movement)
signal moved_to(position)

var active: bool = false

var _is_being_dragged: bool = false
var _pre_drag_position: Vector2

onready var edit_menu := $EditMenu as Control
onready var value_setter := $InitialValue as Control
onready var value_setter_origin := $EditMenu/InitialValue/Label


func _ready():
	edit_menu.visible = false


func _input(event: InputEvent) -> void:
	if not active:
		return
	if event.is_action_pressed("drag_cancel") and _is_being_dragged:
		_cancel_drag()
	if event is InputEventMouseMotion and _is_being_dragged:
		_move(event.relative)


func _drag() -> void:
	_is_being_dragged = true
	_pre_drag_position = rect_global_position


func _drop() -> void:
	_is_being_dragged = false


func _move(movement: Vector2) -> void:
	emit_signal("moved_by", movement)


func _cancel_drag() -> void:
	emit_signal("moved_to", _pre_drag_position)


func _toggle_edit_menu(open: bool = false) -> void:
	if _is_being_dragged and _pre_drag_position != rect_global_position: 
		return
	edit_menu.visible = not edit_menu.visible


func _new_type_selected(new_type: int) -> void:
	emit_signal("type_changed", new_type)
	var parent: Control = value_setter.get_parent()
	parent.remove_child(value_setter)
	match new_type:
		FlowNode.Type.BOOL: # Switch
			value_setter = CheckButton.new()
			value_setter.connect("toggled", self, "_initial_value_set")
		FlowNode.Type.INT: # Integer
			value_setter = SpinBox.new()
			value_setter.allow_greater = true
			value_setter.allow_lesser = true
			value_setter.rounded = true
			value_setter.connect("value_changed", self, "_initial_value_set")
		FlowNode.Type.DECIMAL: # Decimal
			value_setter = SpinBox.new()
			value_setter.allow_greater = true
			value_setter.allow_lesser = true
			value_setter.step = 0.01
			value_setter.connect("value_changed", self, "_initial_value_set")
		FlowNode.Type.PERCENTAGE: # Percentage
			value_setter = HSlider.new()
			value_setter.max_value = 1.0
			value_setter.min_value = 0.0
			value_setter.step = 0.01
			value_setter.connect("value_changed", self, "_initial_value_set")
		FlowNode.Type.SHORT_TEXT: # Short Text
			value_setter = LineEdit.new()
			value_setter.connect("text_changed", self, "_initial_value_set")
		FlowNode.Type.LONG_TEXT:
			value_setter = LineEdit.new()
			value_setter.connect("text_changed", self, "_initial_value_set")
		_: # Other
			print("INVALID NODE TYPE")
	value_setter.anchor_right = 1.0
	value_setter.anchor_bottom = 1.0
	parent.add_child(value_setter)
	parent.move_child(value_setter, 0)
	$EditMenu/InitialValue/Value.text = str(FlowNode.default_value(new_type))


func _initial_value_set(value) -> void:
	var text: String
	match get_parent().node.type:
		FlowNode.Type.BOOL: # Switch
			text = "ON" if value else "OFF"
		FlowNode.Type.INT: # Integer
			text = str(value)
		FlowNode.Type.DECIMAL: # Decimal
			text = "%.2f" % value
		FlowNode.Type.PERCENTAGE: # Percentage
			text = "%.1f%%" % (value * 100.0)
		FlowNode.Type.SHORT_TEXT: # Short Text
			text = value
		FlowNode.Type.LONG_TEXT: # Long Text
			text = value
	$EditMenu/InitialValue/Value.text = text
	emit_signal("initial_value_changed", value)

