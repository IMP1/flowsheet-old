extends Control

var active: bool = false

var editable: bool = false setget _set_editable

# TODO: Connect Input node to propogate initial values for nodes


func _set_editable(val: bool) -> void:
	$Label.visible = (not val)
	$Input.visible = val


func set_type(type: int) -> void:
	pass # TODO: Set input node based on type


func set_value(value) -> void:
	$Label.text = str(value)

