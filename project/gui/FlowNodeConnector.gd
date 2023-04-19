extends Panel
class_name FlowsheetNodeConnector

# Using this reference: https://www.reddit.com/r/godot/comments/7ystqs/drag_and_drop/

signal start_connection
signal end_connection

export var highlight_colour: Color = Color.red
export var accept_incoming: bool = false
export var is_output_connector: bool = true

var node: Control
var _previous_border_colour: Color

onready var panel := get("custom_styles/panel") as StyleBoxFlat


func reset() -> void:
	panel.border_color = _previous_border_colour
	accept_incoming = false


func highlight() -> void:
	if panel.border_color == highlight_colour:
		return
	_previous_border_colour = panel.border_color
	panel.border_color = highlight_colour
	accept_incoming = true


func get_drag_data(_position):
	if is_output_connector:
		emit_signal("start_connection")
		_previous_border_colour = panel.border_color
		panel.border_color = highlight_colour
		return node
	else:
		return null


func can_drop_data(_position, data):
	return accept_incoming and (data != node)


func drop_data(_position, data):
	emit_signal("end_connection", data, node)
