extends RefCounted
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#	https://github.com/CodeNameTwister/GDWatermark-Example
#
#	author:	"Twister"
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #


var show_popup_dialog : bool = true

var components : Array = [
	preload("res://watermark/src/mesh.gd").new(),
	preload("res://watermark/src/png.gd").new(),
	preload("res://watermark/src/wav16.gd").new()
]

func hide_message(file_path : String, file_out_path, message : String) -> void:
	if !FileAccess.file_exists(file_path):
		printerr("Error!, file not exist: ", file_path)
		show_popup("Error", "file not exist\n" + file_path)
		return
		
	elif file_path == file_out_path:
		print("Warn, file be remplaced: ", file_path)
		
	for x in components:
		if x.is_valid(file_path):
			if x.hide_message(file_path, file_out_path , message) == OK:
				if message.length() > 0:
					show_popup("Create Message", "Message create at\n{0}".format([file_out_path]))
					return
				else:
					show_popup("Create With Empty Message", "Empty message create at\n{0}".format([file_out_path]))
			else:
				show_popup("Error", "Can not hide message at\n" + file_path)
			return
			
	show_popup("Invalid File", "Can not find a valid component for this file!\n[{0}]\n\nTry check the import settings".format([file_path.get_file()]))
			
	
func show_message(file_path : String) -> String:
	if !FileAccess.file_exists(file_path):
		printerr("Error!, file not exist: ", file_path)
		show_popup("Invalid File", "File Note exist!\n" + file_path)
		return ""
		
	for x in components:
		if x.is_valid(file_path):
			var message : String = x.show_message(file_path)
			if message.length() > 0:
				show_popup("Show Message", message)
			else:
				show_popup("Show Message", "Message Not Found!")
			return message
	
	show_popup("Invalid File", "Can not find a valid component for this file!\n[{0}]\n\nTry check the import settings".format([file_path.get_file()]))
		
	return ""

func show_popup(title: String, body: String) -> AcceptDialog:
	if !show_popup_dialog:
		return null
		
	var dialog : AcceptDialog = AcceptDialog.new()
	
	var caller : Callable = func():
		if is_instance_valid(dialog):
			dialog.queue_free()
			
	dialog.title = title
	dialog.dialog_text = body
	dialog.ok_button_text = "OK"
	dialog.unresizable = true
	dialog.min_size.x = 300
	dialog.min_size.y = 100
	
	dialog.focus_exited.connect(caller)
	dialog.confirmed.connect(caller)
	dialog.canceled.connect(caller)
	
	Engine.get_main_loop().root.add_child(dialog)
	dialog.popup_centered()
	
	return dialog
