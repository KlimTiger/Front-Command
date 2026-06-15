class_name Army
extends "res://scripts/domain/command/command_unit.gd"

func _init(new_id: String = "", new_display_name: String = "Army", new_commander_name: String = "Army Commander") -> void:
	super(new_id, new_display_name, Level.ARMY, new_commander_name)