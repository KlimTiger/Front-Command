class_name Company
extends "res://scripts/domain/command/command_unit.gd"

func _init(new_id: String = "", new_display_name: String = "Company", new_commander_name: String = "Company Commander") -> void:
	super(new_id, new_display_name, Level.COMPANY, new_commander_name)