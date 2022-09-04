class_name ListItemContainer
extends HBoxContainer

onready var space:Control=$Space
onready var content:ListItem=$Content

var _indent_level:int


func _ready():
	pass


func _on_Content_level_updated(ref_self:ListItem):
	assert(ref_self==content)
	var new_level:=ref_self.get_level()
	if _indent_level==new_level:
		return
	elif new_level<=1:
		for s in get_children():
			if s!=space and s!=content:
				s.queue_free()
		space.visible=(new_level==1)
	elif new_level<_indent_level:
		var children_1:Control=get_child(1)
		assert(children_1!=null)
		while children_1!=content:
			remove_child(children_1)
			children_1.queue_free()
			children_1=get_child(1)
		assert(get_child_count()==new_level+1)
	else:	# _indent_level<new_level
		space.visible=true
		while get_child_count()<new_level+1:
			var new_space:Control=space.duplicate()
			add_child(new_space)
			move_child(new_space,1)
			assert(get_child(0)==space and get_children().back()==content)
	_indent_level=new_level
	return
