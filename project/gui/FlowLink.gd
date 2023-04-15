extends Control

signal deleted()
signal formula_changed()

export(Resource) var link
export(Color) var selected_colour = Color.royalblue

const SOURCE_NODE_LINE_INDEX = 0
const TARGET_NODE_LINE_INDEX = 1

var source_node: Control
var target_node: Control
var _is_mouse_over: bool = false

onready var line := $Edit/LineContainer/Line2D as Line2D
onready var border_line := $Edit/LineContainer/Border as Line2D
onready var path := $Edit/LineContainer/Path2D as Path2D
onready var edit_button := $Edit/Edit as Button
onready var edit_menu := $Edit/EditMenu as Control
onready var _edit := $Edit as Control

# TODO: Draw a different colour line if there is no formula (or if an invalid formula)


func _ready() -> void:
	edit_menu.visible = false


func set_mode(mode: int) -> void:
	_edit.visible = false
	match mode:
		0:
			_edit.visible = true


func _set_menu_visible(val: bool) -> void:
	edit_menu.visible = val
	edit_menu.rect_global_position = get_global_mouse_position() + Vector2(0, 24)
	if val:
		border_line.default_color = selected_colour


func set_connection(source: Control, target: Control) -> void:
	source_node = source
	target_node = target
	source_node.connect("deleted", self, "_node_deleted")
	target_node.connect("deleted", self, "_node_deleted")
	source_node.connect("moved", self, "_source_node_moved")
	target_node.connect("moved", self, "_target_node_moved")
	_refresh()


func _refresh() -> void:
#	var middle_point: Vector2 = source_node.connection_point_out()
#	middle_point += target_node.connection_point_in()
#	middle_point /= 2
#	rect_position = middle_point
#	$Edit/LineContainer.rect_position = -middle_point
	line.clear_points()
	border_line.clear_points()
	path.curve.clear_points()
	line.add_point(source_node.connection_point_out())
	border_line.add_point(source_node.connection_point_out())
	path.curve.add_point(source_node.connection_point_out())
	# TODO: Add elbow bends to make it look nicer
	#       Change TARGET_NODE_LINE_INDEX when this happens
	line.add_point(target_node.connection_point_in())
	border_line.add_point(target_node.connection_point_in())
	path.curve.add_point(target_node.connection_point_in())


func _source_node_moved(position: Vector2) -> void:
	_refresh()


func _target_node_moved(position: Vector2) -> void:
	_refresh()


func _formula_changed(new_formula: String) -> void:
	link.formula = new_formula
	emit_signal("formula_changed")


func _node_deleted() -> void:
	emit_signal("deleted")


func _delete() -> void:
	emit_signal("deleted")


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if _is_point_over(get_local_mouse_position()):
			_set_menu_visible(not edit_menu.visible)


func _is_point_over(point: Vector2) -> bool:
	var mouse_pos := path.get_local_mouse_position()
	var line_pos := path.curve.get_closest_point(mouse_pos)
	var distance_squared = (line_pos - mouse_pos).length_squared()
	return distance_squared <= 64
