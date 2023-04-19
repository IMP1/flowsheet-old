extends Panel
class_name FlowsheetNodeConnector

# Using this reference: https://www.reddit.com/r/godot/comments/7ystqs/drag_and_drop/

signal start_connection
signal end_connection
signal reorder_links

export var highlight_colour: Color = Color.red # TODO: Get this from the theme
export var accept_incoming: bool = false
export var is_incoming_connector: bool = true

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
	if is_incoming_connector:
		return null
	emit_signal("start_connection")
	_previous_border_colour = panel.border_color
	panel.border_color = highlight_colour
	return node


func can_drop_data(_position, data):
	return accept_incoming and (data != node)


func drop_data(_position, data):
	emit_signal("end_connection", data, node)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and not event.pressed and is_incoming_connector:
		emit_signal("reorder_links")
