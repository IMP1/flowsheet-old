extends Control

var active: bool = false
var editable: bool = false setget _set_editable

onready var input := $Input as Control
onready var output := $Label as Control


func _set_editable(val: bool) -> void:
	output.visible = (not val)
	input.visible = val


func set_type(type: int) -> void:
	var parent: Control = input.get_parent()
	parent.remove_child(input)
	match type:
		FlowNode.Type.BOOL: # Switch
			input = CheckButton.new()
			input.connect("toggled", self, "_initial_value_set")
		FlowNode.Type.INT: # Integer
			input = SpinBox.new()
			input.allow_greater = true
			input.allow_lesser = true
			input.rounded = true
			input.connect("value_changed", self, "_initial_value_set")
		FlowNode.Type.DECIMAL: # Decimal
			input = SpinBox.new()
			input.allow_greater = true
			input.allow_lesser = true
			input.step = 0.01
			input.connect("value_changed", self, "_initial_value_set")
		FlowNode.Type.PERCENTAGE: # Percentage
			input = HSlider.new()
			input.max_value = 1.0
			input.min_value = 0.0
			input.step = 0.01
			input.connect("value_changed", self, "_initial_value_set")
		FlowNode.Type.SHORT_TEXT: # Short Text
			input = LineEdit.new()
			input.connect("text_changed", self, "_initial_value_set")
		FlowNode.Type.LONG_TEXT:
			input = LineEdit.new()
			input.connect("text_changed", self, "_initial_value_set")
		_: # Other
			print("INVALID NODE TYPE")
	parent.add_child(input)
	parent.move_child(input, 0)
	input.anchor_right = 1.0
	input.anchor_bottom = 1.0


func set_value(value) -> void:
	output.text = str(value)

