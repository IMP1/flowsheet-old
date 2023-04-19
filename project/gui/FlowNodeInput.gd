extends Control
class_name FlowsheetNodeInput

signal value_changed(new_value)

var _type: int

onready var _input_node := $Input as Control


func _ready() -> void:
	pass


func _setup(type: int, value) -> void:
	pass


func set_type(new_type: int) -> void:
	remove_child(_input_node)
	match new_type:
		FlowNode.Type.BOOL: # Switch
			_input_node = CheckButton.new()
			_input_node.connect("toggled", self, "_initial_value_set")
		FlowNode.Type.INT: # Integer
			_input_node = SpinBox.new()
			_input_node.allow_greater = true
			_input_node.allow_lesser = true
			_input_node.rounded = true
			_input_node.connect("value_changed", self, "_initial_value_set")
		FlowNode.Type.DECIMAL: # Decimal
			_input_node = SpinBox.new()
			_input_node.allow_greater = true
			_input_node.allow_lesser = true
			_input_node.step = 0.01
			_input_node.connect("value_changed", self, "_initial_value_set")
		FlowNode.Type.PERCENTAGE: # Percentage
			_input_node = HSlider.new()
			_input_node.max_value = 1.0
			_input_node.min_value = 0.0
			_input_node.step = 0.01
			_input_node.connect("value_changed", self, "_initial_value_set")
		FlowNode.Type.SHORT_TEXT: # Short Text
			_input_node = LineEdit.new()
			_input_node.connect("text_changed", self, "_initial_value_set")
		FlowNode.Type.LONG_TEXT:
			_input_node = LineEdit.new()
			_input_node.connect("text_changed", self, "_initial_value_set")
		_: # Other
			print("INVALID NODE TYPE")
	_input_node.anchor_right = 1.0
	_input_node.anchor_bottom = 1.0
	add_child(_input_node)


func _initial_value_set(new_value) -> void:
	emit_signal("value_changed", new_value)
