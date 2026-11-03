extends LineEdit
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#	https://github.com/CodeNameTwister/GDWatermark-Example
#
#	author:	"Twister"
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #


func _ready() -> void:
	var l : LineEdit = $"../../HBoxContainer/LineEdit"
	l.text_submitted.connect(_on_change)
	
func _on_change(txt : String) -> void:
	if text.is_empty():
		var sp : PackedStringArray = txt.rsplit(".", true, 1)
		sp[0] += "_hided_message"
		text = ".".join(sp)
		caret_column = text.length()
