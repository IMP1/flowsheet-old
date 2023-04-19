extends Control

signal type_changed(new_type)
signal editable_changed(new_value)
signal moved_by(movement)
signal moved_to(position)

var active: bool = false

var _is_being_dragged: bool = false
var _pre_drag_position: Vector2

onready var _edit_menu := $EditMenu as Control
onready var _initial_value_info := $EditMenu/InitialValue/Value as Label


func _ready():
	_edit_menu.visible = false


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
	_is_being_dragged = false


func _toggle_edit_menu(open: bool = false) -> void:
	if _is_being_dragged and _pre_drag_position != rect_global_position: 
		return
	_edit_menu.visible = not _edit_menu.visible


func set_initial_value(value, type: int) -> void:
	_initial_value_info.text = FlowNode.to_text(value, type)


func set_value(value) -> void:
	$Value/Label.text = str(value)
