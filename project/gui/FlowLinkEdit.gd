extends Control

const CONNECTOR = preload("res://gui/FlowNodeConnector.tscn")

var links: Array = []

onready var _area := $ActiveArea as Control
onready var _connectors := $VBoxContainer as Control

func _ready():
	for link in links:
		var connector = CONNECTOR.instance()
		_connectors.add_child(connector)
		connector.size_flags_horizontal -= SIZE_FILL
		connector.size_flags_horizontal += SIZE_SHRINK_CENTER
	for i in links.size():
		var link = links[i]
		var connector = _connectors.get_child(i) 
		link.override_target_position = true
		var container_pos := Vector2(0, _connectors.rect_position.y)
		var connector_pos: Vector2 = Vector2(0, connector.rect_position.y) + connector.rect_size / 2
		link.temp_target_offset = container_pos + connector_pos
		link._refresh()
	_area.margin_top = _connectors.margin_top - 32
	_area.margin_bottom = _connectors.margin_bottom + 32


func _mouse_left() -> void:
	for link in links:
		link.override_target_position = false
		link._refresh()
	queue_free()
