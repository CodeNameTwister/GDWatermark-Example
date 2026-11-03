extends Node

const HideMessage = preload("uid://dcu4ji4gh50pe")

@export var file_path : String = "" # Example of ArrayMesh: "res://samples/mesh/models/godette_plush_head.res"
@export var secret_message : String = ""

func _ready() -> void:
	var hider : HideMessage = HideMessage.new()
	var file_to_save : String = "user://my_new_file.{0}".format([file_path.get_extension()])
	
	hider.show_popup_dialog = true
	
	## Hide message {This Example Support PNG | Uncompressed Wav PCM 16 | ArrayMesh}
	hider.hide_message(file_path, file_to_save, secret_message)
	
	## Show Message	
	var file_saved : String = file_to_save
	var message : String = hider.show_message(file_saved)
	
	print("The hide message is {0}".format([message]))
