extends Resource
class_name FlowFunction

export(String) var name: String = ""
export(int) var necessary_args: int = 0
export(int) var optional_args: int = 0
export(FlowNode.Type) var return_type: int
export(String) var action

# https://docs.godotengine.org/en/stable/tutorials/scripting/evaluating_expressions.html
