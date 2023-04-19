extends Control

var editable: bool = true
var active: bool = false setget _set_active

export(NodePath) var input

onready var _input := get_node(input) as Control
onready var _output := $Label as Control


func _set_active(value: bool) -> void:
	active = value
	if active:
		_input.visible = editable
		_output.visible = (not editable)
	else:
		_input.visible = true


func set_value(value) -> void:
	_output.text = str(value)
