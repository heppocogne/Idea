extends TextEdit

signal enter_key_pressed()

export var disabled:=false
var _shift_pressed:=false


func _ready():
	pass


func _input(event:InputEvent):
	if event is InputEventKey:
		var key:=event as InputEventKey
		if key.scancode==KEY_ENTER:
			if disabled:
				return
			if !_shift_pressed and key.pressed:
				emit_signal("enter_key_pressed")
				accept_event()
		elif key.scancode==KEY_SHIFT:
			_shift_pressed=key.pressed
