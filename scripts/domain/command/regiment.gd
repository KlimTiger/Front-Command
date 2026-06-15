class_name Regiment
extends "res://scripts/domain/command/command_unit.gd"

func _init(new_id: String = "", new_display_name: String = "Regiment", new_commander_name: String = "Regiment Commander") -> void:
	super(new_id, new_display_name, Level.REGIMENT, new_commander_name)