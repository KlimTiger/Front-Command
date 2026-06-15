class_name Division
extends "res://scripts/domain/command/command_unit.gd"

func _init(new_id: String = "", new_display_name: String = "Division", new_commander_name: String = "Division Commander") -> void:
	super(new_id, new_display_name, Level.DIVISION, new_commander_name)