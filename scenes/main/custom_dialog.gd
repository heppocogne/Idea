class_name CustomDialog
extends FileDialog

signal action_completed(canceled_or_confirmed)


func _ready():
# warning-ignore:return_value_discarded
	get_cancel().connect("pressed",self,"_on_FileDialog_canceled")


func _on_FileDialog_file_selected(_path):
	emit_signal("action_completed",true)


func _on_FileDialog_canceled():
	emit_signal("action_completed",false)
