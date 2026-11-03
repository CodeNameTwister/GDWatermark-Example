extends Button
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#	https://github.com/CodeNameTwister/GDWatermark-Example
#
#	author:	"Twister"
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

const HideMessage = preload("uid://dcu4ji4gh50pe")

@export var origin : LineEdit
@export var area : TextEdit

func _pressed() -> void:
	if origin.text.length() < 1:
		printerr("Origin file path can not be empty!")
		return
	
	print("Trying get message from ", origin.text)
	area.text = HideMessage.new().show_message(origin.text)
