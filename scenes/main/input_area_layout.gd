extends HBoxContainer

export var text_edit_height_limit:float=128.0

onready var _text_edit:TextEdit=$TextEdit
onready var _text_edit_font:=_text_edit.get_font("font")


func _ready():
	pass


func _on_TextEdit_text_changed():
	var size_request:=_text_edit_font.get_wordwrap_string_size(_text_edit.text,_text_edit.rect_size.x)
	if _text_edit.rect_size.y!=size_request.y:
		rect_min_size=Vector2(rect_size.x,min(size_request.y,text_edit_height_limit))
