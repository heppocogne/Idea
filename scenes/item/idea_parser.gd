class_name IdeaParser
extends Reference

var _regex:RegEx
var _space:=" ".ord_at(0)
var _tab:="\t".ord_at(0)
var _linebreak:="\n".ord_at(0)
var _sqbracket_l:="[".ord_at(0)
var _sqbracket_r:="]".ord_at(0)
var parser_error_state:int


func _init():
	_regex=RegEx.new()
# warning-ignore:return_value_discarded
	_regex.compile("^\\t*\\[.\\] .*$")
	assert(_regex.is_valid())


func parse_file(filename:String)->Array:
	var file:=File.new()
	var open_result:=file.open(filename,File.READ)
	if open_result==OK:
		var array:=parse(file.get_as_text())
		file.close()
		return array
	else:
		printerr("failed to open ",filename,"\nerror code:",open_result)
		parser_error_state=open_result
		return []


func parse(src:String)->Array:
	parser_error_state=-1
	var begin:=0
	var dic:={}
	var result:=[]
	for _l in range(src.count("\n")+1):
		if src.length()<=begin:
			break
		var end:=src.find("\n",begin)
		if end<0:
			end=src.length()
		var line:=src.substr(begin,end-begin)
		if _regex.search(line):
			# indents, checkbox, text
			# accept current text
			if dic.size():
				if !dic.keys().has("indents") or !dic.keys().has("check_state"):
					parser_error_state=ERR_PARSE_ERROR
					return []
				else:
					result.push_back(dic)
					dic={}
			
			var indents:=0
			var index:=begin
			while src[index]=="\t":
				indents+=1
				index+=1
			dic["indents"]=indents
			var check_state:=src[index+1]
			dic["check_state"]=check_state
			index+=4
			
			dic["text"]=src.substr(index,end-index)
		else:
			# indents, text
			var indents:=0
			var index:=begin
			while src[index]=="\t":
				indents+=1
				index+=1
# warning-ignore:narrowing_conversion
			indents=min(indents,dic["indents"]+1)
			if 0<indents:
				line=line.substr(indents)
			dic["text"]+="\n"+line
		begin=end+1
	
	if dic.size():
		if !dic.keys().has("indents") or !dic.keys().has("check_state"):
			parser_error_state=ERR_PARSE_ERROR
			return []
		else:
			result.push_back(dic)
	parser_error_state=OK
	return result
