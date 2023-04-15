extends Object
class_name FormulaContext

# TODO: Define FlowSheet functions here
#       SUM(), etc?

func IF(cond, then_val, else_val):
	if cond:
		return then_val
	else:
		return else_val
