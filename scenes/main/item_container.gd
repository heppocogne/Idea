extends VBoxContainer

const _scene_list_item:=preload("res://scenes/item/list_item.tscn")

onready var _text_edit:TextEdit=get_node("../../../InputAreaLayout/TextEdit")
var _eidting_item:ListItem
var _item_shift_pressed:ListItem
var _focused_items:=[]


func _ready():
	pass


func clear():
	_eidting_item=null
	_item_shift_pressed=null
	_focused_items.clear()
	for c in get_children():
		c.queue_free()


func _on_AddButton_pressed():
	if _text_edit.text=="":
		return
	var new_item:ListItem=_scene_list_item.instance()
	add_list_item(new_item)
	new_item.item_text_label.text=_text_edit.text
	_text_edit.text=""
	_text_edit.emit_signal("text_changed")


func add_list_item(new_item:ListItem):
	add_child(new_item)
# warning-ignore:return_value_discarded
	new_item.connect("clicked",self,"_on_ListItem_clicked")


func _on_Item_edit_started(edit_target:ListItem):
	if _eidting_item:
		_eidting_item.complete_edit()
	_eidting_item=edit_target


func _on_Item_edit_completed(edit_target:ListItem):
	if _eidting_item==edit_target:
		_eidting_item=null


func child_index(node:Node)->int:
	return get_children().find(node)


func _on_ListItem_clicked(item:ListItem,key_flags:int):
	if key_flags==ListItem.KEY_FLAGS.NONE or _focused_items.size()==0:
		if item.focused and _focused_items.size()==1:
			_focused_items.erase(item)
			item.set_focused(false)
		else:
			for i in _focused_items:
				i.set_focused(false)
			_focused_items.clear()
			_focused_items.push_back(item)
			item.set_focused(true)
		
		_item_shift_pressed=null
		return
	elif key_flags==ListItem.KEY_FLAGS.CTRL_PRESSED:
		if item.focused:
			_focused_items.erase(item)
			item.set_focused(false)
		else:
			_focused_items.push_back(item)
			item.set_focused(true)
		
		_item_shift_pressed=null
		return
	elif key_flags&ListItem.KEY_FLAGS.SHIFT_PRESSED:
		var begin_index:int
		var ctrl_pressed:int=(key_flags&ListItem.KEY_FLAGS.CTRL_PRESSED)
		if _item_shift_pressed:
			begin_index=child_index(_item_shift_pressed)
		else:
			begin_index=child_index(_focused_items.back())
			_item_shift_pressed=_focused_items.back()
		var end_index:=child_index(item)
		if end_index<begin_index:
			var temp:=begin_index
			begin_index=end_index
			end_index=temp
		var children:=get_children()
		for index in range(children.size()):
			var check_item:ListItem=children[index]
			if begin_index<=index and index<=end_index:
				if !check_item.focused:
					_focused_items.push_back(check_item)
					check_item.set_focused(true)
			elif !ctrl_pressed and check_item.focused:
				_focused_items.erase(check_item)
				check_item.set_focused(false)
