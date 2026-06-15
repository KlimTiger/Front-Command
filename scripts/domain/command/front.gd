class_name Front
extends "res://scripts/domain/command/command_unit.gd"

func _init(new_id: String = "", new_display_name: String = "Front Headquarters", new_commander_name: String = "Front Staff") -> void:
	super(new_id, new_display_name, Level.FRONT, new_commander_name)