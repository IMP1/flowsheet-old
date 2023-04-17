extends Control

signal deleted()
signal formula_changed()

export(Color) var selected_colour := Color.royalblue
export(Color) var no_formula := Color.gray
export(Color) var invalid_formula := Color.red

const SOURCE_NODE_LINE_INDEX = 0
const TARGET_NODE_LINE_INDEX = 3

var link: FlowLink
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
	# Links are only viewable in EDIT mode
	_edit.visible = (mode == 0)


func _set_menu_visible(val: bool) -> void:
	edit_menu.visible = val
	edit_menu.rect_global_position = get_global_mouse_position() + Vector2(0, 24)
	if val:
		border_line.default_color = selected_colour
	else:
		border_line.default_color = Color.black # TODO: Get from theme


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
	var source_pos: Vector2 = source_node.connection_point_out() + Vector2(10, 0)
	var target_pos: Vector2 = target_node.connection_point_in() + Vector2(-10, 0)
	line.clear_points()
	border_line.clear_points()
	path.curve.clear_points()
	line.add_point(source_pos)
	border_line.add_point(source_pos)
	path.curve.add_point(source_pos)
	
	var elbow_pos_1: Vector2
	var elbow_pos_2: Vector2
	var dist := target_pos.x - source_pos.x
	if dist < 0:
		if target_pos.y < source_pos.y:
			elbow_pos_1 = source_pos - Vector2(0, 16)
			elbow_pos_2 = target_pos + Vector2(0, 16)
		else:
			elbow_pos_1 = source_pos + Vector2(0, 16)
			elbow_pos_2 = target_pos - Vector2(0, 16)
	elif dist < 24:
		elbow_pos_1 = source_pos + Vector2(0, 0)
		elbow_pos_2 = target_pos + Vector2(0, 0)
	elif dist < 128:
		elbow_pos_1 = source_pos + Vector2(dist / 2, 0)
		elbow_pos_2 = Vector2(elbow_pos_1.x, target_pos.y)
	else:
		elbow_pos_1 = source_pos + Vector2(64, 0)
		elbow_pos_2 = Vector2(elbow_pos_1.x, target_pos.y)
	
	line.add_point(elbow_pos_1)
	border_line.add_point(elbow_pos_1)
	path.curve.add_point(elbow_pos_1)
	
	line.add_point(elbow_pos_2)
	border_line.add_point(elbow_pos_2)
	path.curve.add_point(elbow_pos_2)
	
	line.add_point(target_pos)
	border_line.add_point(target_pos)
	path.curve.add_point(target_pos)


func _source_node_moved(_position: Vector2) -> void:
	_refresh()


func _target_node_moved(_position: Vector2) -> void:
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
		if _is_point_over(path.get_local_mouse_position()):
			_set_menu_visible(not edit_menu.visible)


func _is_point_over(point: Vector2) -> bool:
	var line_pos := path.curve.get_closest_point(point)
	var distance_squared := (line_pos - point).length_squared()
	return distance_squared <= 64
