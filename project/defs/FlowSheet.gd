extends Resource
class_name FlowSheet

export(Array, Resource) var nodes: Array = []
export(Array, Resource) var links: Array = []
export(Dictionary) var node_positions: Dictionary = {}
export(Theme) var user_theme: Theme
export(Dictionary) var style_overrides: Dictionary = {}


func add_node(node: FlowNode, position: Vector2) -> void:
	nodes.append(node)
	node_positions[node.id] = position


func remove_node(node: FlowNode) -> void:
	node_positions.erase(node.id)
	var index := nodes.find(node)
	nodes.remove(index)


func add_link(link: FlowLink) -> void:
	links.append(link)


func remove_link(link: FlowLink) -> void:
	var index = links.find(link)
	links.remove(index)
