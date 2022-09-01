extends MenuButton

const _scene_custom_dialog:=preload("res://scenes/main/custom_dialog.tscn")
const _scene_save_or_discard_dialog:=preload("res://scenes/main/save_or_discard_dialog.tscn")
const _scene_list_item:=preload("res://scenes/item/list_item.tscn")
const new_file_name:="new_idea.idea"

export var new_file:ShortCut
export var open_file:ShortCut
#export var open_recent:ShortCut
export var save:ShortCut	# ctrl+s
export var save_as:ShortCut	# ctrl+shift+s
#export var close_file:ShortCut
export var quit:ShortCut	# ctrl+q
var save_process_state:int
var load_process_state:int

onready var _item_container:=get_node("../../ItemListLayout/ScrollContainer/ItemView")
var _item_container_hash:int
var current_file:String setget set_current_file
var _save_dialog:CustomDialog
var _open_dialog:CustomDialog
var _save_or_discard_dialog:SaveOrDiscardDialog


func _ready():
	_save_dialog=_scene_custom_dialog.instance()
	_open_dialog=_scene_custom_dialog.instance()
	_open_dialog.mode=FileDialog.MODE_OPEN_FILE
	_save_or_discard_dialog=_scene_save_or_discard_dialog.instance()
	get_tree().root.call_deferred("add_child",_save_dialog)
	get_tree().root.call_deferred("add_child",_open_dialog)
	get_tree().root.call_deferred("add_child",_save_or_discard_dialog)
# warning-ignore:return_value_discarded
	_save_dialog.connect("file_selected",self,"_on_save_dialog_file_selected")
# warning-ignore:return_value_discarded
	_open_dialog.connect("file_selected",self,"_on_open_dialog_file_selected")
#	_save_dialog.get_cancel().connect("pressed",self,"_on_FileDialog_cancel_pressed")
	
	var p:=get_popup()
# warning-ignore:return_value_discarded
	p.connect("index_pressed",self,"_on_menu_invoked")
	p.add_item("New File")
	p.add_separator()
	p.add_item("Open File")
#	p.add_submenu_item("Open Recent","recent-files")
#	var recent_files:=PopupMenu.new()
#	recent_files.name="recent-files"
#	p.add_child(recent_files)
#	recent_files.add_item("hoge")
#	recent_files.add_item("fuga")
#	recent_files.add_item("piyo")
	
	p.add_separator()
	p.add_item("Save")
	p.add_item("Save As")
#	p.add_separator()
#	p.add_item("Close File")
	p.add_separator()
	p.add_item("Quit")
	
	p.set_item_shortcut(0,new_file)
	p.set_item_shortcut(2,open_file)
#	p.add_shortcut(open_recent,3)
	p.set_item_shortcut(4,save)
	p.set_item_shortcut(5,save_as)
	p.set_item_shortcut(7,quit)
#	p.add_shortcut(close_file,7)
#	p.add_shortcut(exit,9)


func set_current_file(new_filename:String):
	current_file=new_filename
	if new_filename!="":
		OS.set_window_title("Idea - "+new_filename)
	else:
		OS.set_window_title("Idea")


func _calculate_item_container_hash()->int:
	var items:=[]
	for item in _item_container.get_children():
		items.push_back(item.to_dictionary())
	return items.hash()


func _update_item_container_hash():
	_item_container_hash=_calculate_item_container_hash()


func _on_menu_invoked(index:int):
	if index==0 or index==2 or index==7:	# new, open, quit
		if _item_container_hash!=_calculate_item_container_hash():
			_save_or_discard_dialog.call_deferred("popup_centered")
			var user_request:int=yield(_save_or_discard_dialog,"action_completed")
			if user_request==_save_or_discard_dialog.UserChoice.SAVE:
				if current_file=="":
					_save_dialog.current_file=new_file_name
				else:
					_save_dialog.current_file=current_file
				_save_dialog.window_title="Save Cahnges"
				_save_dialog.popup_centered()
				var confirmed:bool=yield(_save_dialog,"action_completed")
				if save_process_state!=OK or !confirmed:
					return
			elif user_request==_save_or_discard_dialog.UserChoice.CANCEL:
				return
		if index==7:	# quit
			get_tree().quit(0)
		else:
			_item_container.clear()
			_update_item_container_hash()
			if index==0:	# new
				_save_dialog.window_title="New File"
				_save_dialog.current_file=new_file_name
				_save_dialog.call_deferred("popup_centered")
			else:	# open
				_open_dialog.window_title="Open File"
				_open_dialog.current_file=""
				_open_dialog.call_deferred("popup_centered")
	elif index==4:	# save
		if current_file=="":
			_save_dialog.window_title="Save a File"
			_save_dialog.current_file=new_file_name
			_save_dialog.popup_centered()
		else:
# warning-ignore:return_value_discarded
			save_to_file(current_file)
			_update_item_container_hash()
	elif index==5:	# save as
		_save_dialog.window_title="Save a File"
		if current_file=="":
			_save_dialog.current_file=new_file_name
		else:
			_save_dialog.current_file=current_file
		_save_dialog.popup_centered()


func _on_save_dialog_file_selected(file_path:String):
# warning-ignore:return_value_discarded
	save_to_file(file_path,true)


func _on_open_dialog_file_selected(file_path:String):
# warning-ignore:return_value_discarded
	load_from_file(file_path)


func save_to_file(filename:String,set_to_current_file:bool=false)->int:
	save_process_state=-1
	var file:=File.new()
	var open_result:=file.open(filename,File.WRITE)
	if open_result==OK:
		for item in _item_container.get_children():
			file.store_string(item.to_string())
		file.close()
		save_process_state=OK
		if set_to_current_file:
			set_current_file(filename)
			_update_item_container_hash()
	else:
		save_process_state=open_result
		printerr("failed to open ",filename,"\nerror code:",open_result)
	return save_process_state


func load_from_file(filename:String)->int:
	load_process_state=-1
	var parser:IdeaParser=preload("res://scenes/item/idea_parser.gd").new()
	var parse_result:=parser.parse_file(filename)
	if parser.parser_error_state==OK:
		for elem in parse_result:
			var new_item:ListItem=_scene_list_item.instance()
			_item_container.add_list_item(new_item)
			new_item.check_box.pressed=(elem["check_state"]=="v")
			# TODO: support indentation
			new_item.item_text_label.text=elem["text"]
		set_current_file(filename)
		_update_item_container_hash()
		load_process_state=OK
		return load_process_state
	else:
		load_process_state=parser.parser_error_state
		printerr("failed to parse ",filename,"\nerror code:",parser.parser_error_state)
	return load_process_state


func _on_ItemContainer_ready():
	_update_item_container_hash()


func _notification(what):
#	if what==MainLoop.NOTIFICATION_WM_QUIT_REQUEST or what==MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST:
#	if what==MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST:
	if what==MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		_on_menu_invoked(7)
