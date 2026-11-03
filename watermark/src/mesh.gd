extends RefCounted
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#	https://github.com/CodeNameTwister/GDWatermark-Example
#
#   Source for Mesh Resource Files
#	author:	"Twister"
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #


func is_valid(resource : String) -> bool:
	if ResourceLoader.exists(resource):
		var res : Resource = ResourceLoader.load(resource)
		return res is ArrayMesh
		
	return false
	
const GRID_STEP : float = 0.01
const WATERMARK_SCALE : float = 0.0001

func hide_message(file_in : String, file_out : String, message : String, in_surface : int = -1) -> int:
	var mesh : ArrayMesh = ResourceLoader.load(file_in)
	var surfaces : Array = []
	
	for x : int in mesh.get_surface_count():
		if in_surface != -1 and x != in_surface:
			continue
			
		var arrays : Array = mesh.surface_get_arrays(x)
		var vertex : PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
		
		var sig_bytes : PackedByteArray = message.to_utf8_buffer()
		var data_size : int = sig_bytes.size()
		
		if vertex.size() < (4 + data_size):
			printerr("Error!, The mesh is too small!")
			return ERR_FILE_CANT_WRITE
			
		var payload : PackedByteArray = PackedByteArray()
		payload.resize(4 + data_size)
		payload.encode_u32(0, data_size)
		
		for z : int in range(data_size):
			payload[4 + z] = sig_bytes[z]
			
		for z : int in range(payload.size()):
			var byte_val : int = payload[z]
			var v : Vector3 = vertex[z]
			
			var base_x : float = snappedf(v.x, GRID_STEP)
			var offset : float = (float(byte_val) / 255.0) * WATERMARK_SCALE
			v.x = base_x + offset
			
			vertex[z] = v
			
		arrays[Mesh.ARRAY_VERTEX] = vertex
		surfaces.append(arrays)
		
	if surfaces.size() > 0:
		var new_mesh : ArrayMesh = ArrayMesh.new()
		
		for surface : Array in surfaces:
			new_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface)
		
		return ResourceSaver.save(new_mesh, file_out)
		
	return ERR_FILE_CANT_WRITE
	
func show_all_messages(file_in : String) -> PackedStringArray:
	var mesh : ArrayMesh = ResourceLoader.load(file_in)
	var dout : PackedStringArray = []
	
	for x : int in mesh.get_surface_count():
		dout.append(_get_message(mesh, x))
		
	return dout
	
	
func show_message(file_in : String, surface : int = 0) -> String:
	var mesh : ArrayMesh = ResourceLoader.load(file_in)
	return _get_message(mesh, surface)
	
func _get_message(mesh : ArrayMesh, surface : int) -> String:	
	if mesh.get_surface_count() <= surface or surface < 0:
		printerr("Invalid surface {0}".format([surface]))
		return ""
	
	var arrays : Array = mesh.surface_get_arrays(surface)
	var vertex : PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
	
	if vertex.size() < 4:
		return ""
		
	var size_bytes : PackedByteArray = PackedByteArray()
	size_bytes.resize(4)
	
	for x : int in range(4):
		var v : Vector3 = vertex[x]
		var base_x : float = snappedf(v.x, GRID_STEP)
		var offset : float = v.x - base_x
		var byte_val : int = int(round((offset / WATERMARK_SCALE) * 255.0))
		size_bytes[x] = clamp(byte_val, 0, 255)
		
	var data_size : int = size_bytes.decode_u32(0)
	if vertex.size() < (4 + data_size):
		return ""
		
	var sig_bytes : PackedByteArray = PackedByteArray()
	sig_bytes.resize(data_size)
	
	for x : int in range(data_size):
		var v : Vector3 = vertex[4 + x]
		var base_x : float = snappedf(v.x, GRID_STEP)
		var offset : float = v.x - base_x
		var byte_val = int(round((offset / WATERMARK_SCALE) * 255.0))
		sig_bytes[x] = clamp(byte_val, 0, 255)
		
	return sig_bytes.get_string_from_utf8()
