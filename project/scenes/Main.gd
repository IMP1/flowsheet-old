# https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html#code-order
extends Control

var _any_unsaved_changes: bool = false

onready var project := $Project as Control


func _ready() -> void:
	OS.window_maximized = true
	project.flowsheet = FlowSheet.new()
	project.refresh()


func _new_project() -> void:
	project.flowsheet = FlowSheet.new()
	project.refresh()


func _open_project() -> void:
	pass


func _save_project() -> void:
	pass


func _exit() -> void:
	get_tree().quit(0)
