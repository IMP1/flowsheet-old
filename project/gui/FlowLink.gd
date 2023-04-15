extends Control

signal deleted()

const SOURCE_NODE_LINE_INDEX = 0
const TARGET_NODE_LINE_INDEX = 1

var source_node: Control
var target_node: Control

# TODO: On source node deletion, queue_free
# TODO: On target node deletion, queue_free

# TODO: On source node moved, move this
# TODO: On target node moved, move this

onready var line := $Edit/Line2D as Line2D
onready var edit_menu := $Edit/EditMenu as Control

func _ready() -> void:
	edit_menu.visible = false

func set_connection(source: Control, target: Control) -> void:
	source_node = source
	target_node = target
	source_node.connect("deleted", self, "_node_deleted")
	target_node.connect("deleted", self, "_node_deleted")
	source_node.connect("moved", self, "_source_node_moved")
	target_node.connect("moved", self, "_target_node_moved")
	_refresh()

func _refresh() -> void:
	line.clear_points()
	line.add_point(source_node.connection_point_out())
	# TODO: Add elbow bends to make it look nicer
	line.add_point(target_node.connection_point_in())

func _source_node_moved(position: Vector2) -> void:
	line.set_point_position(SOURCE_NODE_LINE_INDEX, source_node.connection_point_out())

func _target_node_moved(position: Vector2) -> void:
	line.set_point_position(TARGET_NODE_LINE_INDEX, target_node.connection_point_in())

func _node_deleted() -> void:
	emit_signal("deleted")
