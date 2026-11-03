extends Button
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#	https://github.com/CodeNameTwister/GDWatermark-Example
#
#	author:	"Twister"
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

const HideMessage = preload("uid://dcu4ji4gh50pe")

@export var origin : LineEdit
@export var target : LineEdit
@export var area : TextEdit

func _pressed() -> void:	
	var str_origin : String = origin.text
	var str_target : String = target.text
	var str_area : String = area.text
	
	for x : String in [str_origin, str_target]:
		if x.length() < 0:
			printerr("Origin/Target File can not be empty!")
			return
			
	print("Trying create custom message at ", target.text)
			
	HideMessage.new().hide_message(str_origin, str_target, str_area)
