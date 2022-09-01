class_name ListItem
extends ColorRect

signal edit_started(ref_self)
signal edit_completed(ref_self)
signal clicked(ref_self,key_flags)

export var base_color:Color=Color(0.168627, 0.192157, 0.25098)
export var hover_color:Color=Color(0.25098, 0.270588, 0.32549)

var mouse_entered:=false
var selected:=false setget set_selected
# Bug?: Using self class_name specifier causes instance leaking
#var parent_item:ListItem
var parent_item:ColorRect
var _ctrl_pressed:=false
var _shift_pressed:=false
var _hbox_container:HBoxContainer
onready var item_text:ItemText=$HBoxContainer/Text
onready var check_box:CheckBox=$HBoxContainer/CheckBox
onready var item_text_label:Label=$HBoxContainer/Text/Label
onready var item_text_edit:TextEdit=$HBoxContainer/Text/TextEdit
onready var buttons_container:CenterContainer=$HBoxContainer/Text/ButtonsContainer

enum KEY_FLAGS{
	NONE=0,
	SHIFT_PRESSED=1,
	CTRL_PRESSED=2,
}


func _ready():
	pass


func _input(event:InputEvent):
	if event is InputEventMouseButton:
		var mb:=event as InputEventMouseButton
		if mb.pressed and mouse_entered:
			if mb.doubleclick:
				if item_text.edit_mode:
					cancel_edit()
				else:
					start_edit()
			else:
				if !item_text.edit_mode:
					var key_flags:int=KEY_FLAGS.NONE
					if _shift_pressed:
						key_flags|=KEY_FLAGS.SHIFT_PRESSED
					if _ctrl_pressed:
						key_flags|=KEY_FLAGS.CTRL_PRESSED
					emit_signal("clicked",self,key_flags)
	if event is InputEventKey:
		var k:=event as InputEventKey
		if k.scancode==KEY_SHIFT:
			_shift_pressed=k.pressed
		elif k.scancode==KEY_CONTROL:
			_ctrl_pressed=k.pressed


func get_level()->int:
	if !parent_item:
		return 0
	else:
		return parent_item.get_level()+1


func to_dictionary()->Dictionary:
	var dic:={}
	dic["indents"]=get_level()
	if check_box.pressed:
		dic["check_state"]="v"
	else:
		dic["check_state"]=" "
	dic["text"]=item_text_label
	return dic


func to_string()->String:
	var indents:="\t".repeat(get_level())
	var check_state:String
	if check_box.pressed:
		check_state="[v] "
	else:
		check_state="[ ] "
	return indents+check_state+item_text_label.text.replace("\n","\n"+indents+"\t")+"\n"


func set_selected(flag:bool):
	selected=flag
	if flag:
		color=hover_color
	else:
		color=base_color
		if item_text.edit_mode:
			cancel_edit()


func toggle_selected():
	set_selected(!selected)


func start_edit():
	item_text.set_edit_mode(true)
	emit_signal("edit_started",self)


func complete_edit():
	item_text.accept_text_edit()
	item_text.set_edit_mode(false)
	emit_signal("edit_completed",self)


func cancel_edit():
	item_text.reject_text_edit()
	item_text.set_edit_mode(false)
	emit_signal("edit_completed",self)


func _on_ListItem_mouse_entered():
	mouse_entered=true


func _on_ListItem_mouse_exited():
	mouse_entered=false


func _on_ListItem_resized():
	if !_hbox_container:
		_hbox_container=$HBoxContainer
	_hbox_container.rect_size=rect_size


func _on_Text_fitted_to_text():
	_hbox_container.fit_child_in_rect(item_text,item_text.get_rect())
	rect_min_size.y=item_text.rect_size.y


func _on_Label_resized():
	rect_min_size.y=item_text_label.rect_size.y
