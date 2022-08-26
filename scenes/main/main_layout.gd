extends VBoxContainer

onready var _input_area_layout:HBoxContainer=$InputAreaLayout


func _ready():
	pass


func _on_InputAreaLayout_resized():
	fit_child_in_rect(_input_area_layout,_input_area_layout.get_rect())
