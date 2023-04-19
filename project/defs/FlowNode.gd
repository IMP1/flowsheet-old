extends Resource
class_name FlowNode

enum Type { BOOL, INT, DECIMAL, PERCENTAGE, SHORT_TEXT, LONG_TEXT }

export var id: int
export var name: String = ""
export var initial_value = 0
export var type: int = Type.INT
export var accepts_input: bool = true

var value = initial_value


static func default_value(type: int):
	match type:
		Type.BOOL:
			return false
		Type.INT:
			return 0
		Type.DECIMAL, Type.PERCENTAGE:
			return 0.0
		Type.SHORT_TEXT, Type.LONG_TEXT:
			return ""
	print("INVALID TYPE")
	return null

static func to_text(value, type: int) -> String:
	match type:
		Type.BOOL: # Switch
			return "ON" if value else "OFF"
		Type.INT: # Integer
			return "%d" % value
		Type.DECIMAL: # Decimal
			return "%.2f" % value
		Type.PERCENTAGE: # Percentage
			return "%.1f%%" % (value * 100.0)
		Type.SHORT_TEXT: # Short Text
			return "'%s'" % value
		Type.LONG_TEXT: # Long Text
			return "'%s'" % value
	print("INVALID TYPE")
	return "???"
