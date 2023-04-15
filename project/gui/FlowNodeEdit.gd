extends Control

signal type_changed(new_type)
signal initial_value_changed(new_value)
signal moved_by(movement)
signal moved_to(position)

var active: bool = false

var _is_being_dragged: bool = false
var _pre_drag_position: Vector2

onready var edit_menu := $EditMenu as Control
onready var value_setter := $EditMenu/InitalValue as Control

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

func _toggle_edit_menu(open: bool) -> void:
	edit_menu.visible = open

func _new_type_selected(option: int) -> void:
	emit_signal("type_changed", option)
	edit_menu.remove_child(value_setter)
	match option:
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
			value_setter.max_value = 100.0
			value_setter.min_value = 1.0
			value_setter.step = 1.0
			value_setter.connect("value_changed", self, "_initial_value_set")
		FlowNode.Type.SHORT_TEXT: # Short Text
			value_setter = LineEdit.new()
			value_setter.connect("text_changed", self, "_initial_value_set")
		FlowNode.Type.LONG_TEXT:
			value_setter = LineEdit.new()
			value_setter.connect("text_changed", self, "_initial_value_set")
		_: # Other
			print("INVALID NODE TYPE")
	edit_menu.add_child_below_node($EditMenu/ChangeType, value_setter)

func _initial_value_set(value) -> void:
	emit_signal("initial_value_changed", value)

