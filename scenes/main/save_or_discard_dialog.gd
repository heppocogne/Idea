class_name SaveOrDiscardDialog
extends WindowDialog

signal action_completed(user_choice)

enum UserChoice{
	SAVE,
	DISCARD,
	CANCEL,
}

onready var save_button:Button=$VBoxContainer/HBoxContainer/Save
onready var discard_button:Button=$VBoxContainer/HBoxContainer/Discard
onready var cancel_button:Button=$VBoxContainer/HBoxContainer/Cancel


func _ready():
	pass


func _on_Save_pressed():
	emit_signal("action_completed",UserChoice.SAVE)
	hide()


func _on_Discard_pressed():
	emit_signal("action_completed",UserChoice.DISCARD)
	hide()


func _on_Cancel_pressed():
	emit_signal("action_completed",UserChoice.CANCEL)
	hide()
