class_name ItemText
extends HBoxContainer

signal fitted_to_text()

var edit_mode:=false setget set_edit_mode

onready var _label:Label=$Label
onready var _text_edit:TextEdit=$TextEdit
onready var _buttons_container:CenterContainer=$ButtonsContainer
onready var _text_edit_font:=_text_edit.get_font("font")


func _ready():
	pass


func set_edit_mode(flag:bool):
	edit_mode=flag
	_label.visible=!flag
	_text_edit.disabled=!flag
	_text_edit.visible=flag
	_buttons_container.visible=flag
	if edit_mode:
		_text_edit.text=_label.text
		_text_edit.rect_min_size=Vector2(_label.rect_size.x*2,_label.rect_size.y)
		_text_edit.rect_size=_text_edit.rect_min_size
		_on_TextEdit_text_changed()


func toggle_edit_mode():
	set_edit_mode(!edit_mode)


func accept_text_edit():
	_label.text=_text_edit.text
	# magic: update rect_min_size with an appropriate value (same or close to the desired rect_size)
	_label.rect_min_size.y=_text_edit.rect_size.y
	rect_size.y=_text_edit.rect_size.y


func reject_text_edit():
	_text_edit.text=_label.text
	_on_TextEdit_text_changed()
	rect_size.y=_label.rect_size.y


func _on_TextEdit_text_changed():
	var size_request:=_text_edit_font.get_wordwrap_string_size(_text_edit.text,_text_edit.rect_size.x)
	if size_request.y==0:
		size_request.y=24
	if _text_edit.rect_size.y!=size_request.y:
		_text_edit.rect_min_size=Vector2(_text_edit.rect_min_size.x,size_request.y)
		fit_child_in_rect(_text_edit,Rect2(_text_edit.get_rect().position,Vector2(_text_edit.rect_size.x,size_request.y)))
		rect_min_size.y=size_request.y
		rect_size.y=size_request.y
		emit_signal("fitted_to_text")
