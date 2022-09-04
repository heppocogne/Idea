class_name ItemView
extends VBoxContainer

const _scene_list_container:=preload("res://scenes/item/list_item_container.tscn")

onready var _text_edit:TextEdit=get_node("../../../InputAreaLayout/TextEdit")
var _eidting_item:ListItem
var _item_shift_pressed:ListItemContainer
var _selected_items:=[]


func _ready():
	pass


func _gui_input(event:InputEvent):
	if event is InputEventMouseButton:
		var mb:=event as InputEventMouseButton
		if mb.pressed and mb.button_index==BUTTON_LEFT:
			_eidting_item=null
			_item_shift_pressed=null
			for i in _selected_items:
				i.content.set_selected(false)
			_selected_items.clear()


func clear():
	_eidting_item=null
	_item_shift_pressed=null
	_selected_items.clear()
	# remove children to updated hash
	while get_child_count():
		var last:Node=get_children().back()
		remove_child(last)
		last.queue_free()


func _on_AddButton_pressed():
	if _text_edit.text=="":
		return
	var new_list_item_container:ListItemContainer=_scene_list_container.instance()
	add_list_item(new_list_item_container)
	if _selected_items.size()==1:
		var children_indexes:=get_children_item_indexes(_selected_items[0])
		if children_indexes.size():
			move_child(new_list_item_container,children_indexes.back()+1)
		else:
			move_child(new_list_item_container,child_index(_selected_items[0])+1)
		new_list_item_container.content.set_parent_item(_selected_items[0].content)
	new_list_item_container.content.item_text_label.text=_text_edit.text
	_text_edit.text=""
	_text_edit.emit_signal("text_changed")


func get_children_item_indexes(item:ListItemContainer)->Array:
	var result:Array=[]
	var parent_index:=child_index(item)
	var parent_level:int=get_child(parent_index).content.get_level()
	var index:int=parent_index+1
	while index<get_child_count() and parent_level<get_child(index).content.get_level():
		result.push_back(index)
		index+=1
	print_debug(result)
	return result


func add_list_item(new_list_item:ListItemContainer):
	add_child(new_list_item)
# warning-ignore:return_value_discarded
	new_list_item.content.connect("clicked",self,"_on_ListItem_clicked")
	new_list_item.content.connect("edit_started",self,"_on_Item_edit_started")
	new_list_item.content.connect("edit_completed",self,"_on_Item_edit_completed")


func _on_Item_edit_started(edit_target:ListItem):
	if _eidting_item:
		_eidting_item.complete_edit()
	assert(_eidting_item==null)
	_eidting_item=edit_target


func _on_Item_edit_completed(edit_target:ListItem):
	if _eidting_item==edit_target:
		_eidting_item=null


func child_index(node:ListItemContainer)->int:
	return get_children().find(node)


func _on_ListItem_clicked(item:ListItem,key_flags:int):
	if key_flags==ListItem.KEY_FLAGS.NONE or _selected_items.size()==0:
		if item.selected and _selected_items.size()==1:
			_selected_items.erase(item.get_parent())
			item.set_selected(false)
		else:
			for i in _selected_items:
				i.content.set_selected(false)
			_selected_items.clear()
			_selected_items.push_back(item.get_parent())
			item.set_selected(true)
		
		_item_shift_pressed=null
		return
	elif key_flags==ListItem.KEY_FLAGS.CTRL_PRESSED:
		if item.selected:
			_selected_items.erase(item.get_parent())
			item.set_selected(false)
		else:
			_selected_items.push_back(item.get_parent())
			item.set_selected(true)
		
		_item_shift_pressed=null
		return
	elif key_flags&ListItem.KEY_FLAGS.SHIFT_PRESSED:
		var ctrl_pressed:int=(key_flags&ListItem.KEY_FLAGS.CTRL_PRESSED)
		if !_item_shift_pressed:
			_item_shift_pressed=_selected_items.back()
		var begin_index:=child_index(_item_shift_pressed)
		var end_index:=child_index(item.get_parent())
		if end_index<begin_index:
			var temp:=begin_index
			begin_index=end_index
			end_index=temp
		for index in range(get_child_count()):
			var check_item:ListItem=get_child(index).content
			if begin_index<=index and index<=end_index:
				if !check_item.selected:
					_selected_items.push_back(check_item.get_parent())
					check_item.set_selected(true)
			elif !ctrl_pressed and check_item.selected:
				_selected_items.erase(check_item.get_parent())
				check_item.set_selected(false)
