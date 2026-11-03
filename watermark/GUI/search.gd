extends Button
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#	https://github.com/CodeNameTwister/GDWatermark-Example
#
#	author:	"Twister"
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

@export var line_edit : LineEdit
@export var dfile : FileDialog
@export var save : bool = false

func _pressed() -> void:
	for d : Dictionary in dfile.file_selected.get_connections():
		dfile.file_selected.disconnect(d.callable)
		
	dfile.file_selected.connect(_on_file, CONNECT_ONE_SHOT)
	dfile.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	dfile.title = tr("Select a File")
	
	if save:
		dfile.file_mode = FileDialog.FILE_MODE_SAVE_FILE
		dfile.title = tr("Save a File")
		
	dfile.popup_centered()
	
func _on_file(file : String) -> void:
	line_edit.text = file
	line_edit.caret_column = line_edit.text.length()
	line_edit.text_submitted.emit(file)
