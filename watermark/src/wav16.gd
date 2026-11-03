extends RefCounted
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#	https://github.com/CodeNameTwister/GDWatermark-Example
#
#	Hide message in Wav 16 bits, require PCM (Uncompressed) in import settings
#	author:	"Twister"
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

func is_valid(resource : String) -> bool:
	if ResourceLoader.exists(resource):
		var res : Resource = ResourceLoader.load(resource)
		if res is AudioStreamWAV:
			return res.format == AudioStreamWAV.FORMAT_16_BITS
			
	elif resource.ends_with(".wav"):
		var wav : AudioStreamWAV = AudioStreamWAV.load_from_file(resource, {"format": AudioStreamWAV.FORMAT_16_BITS,})
		return wav.format == AudioStreamWAV.FORMAT_16_BITS
	return false

func hide_message(file_in : String, file_out : String, message : String) -> int:
	var wav : AudioStreamWAV
	
	if ResourceLoader.exists(file_in):
		wav = ResourceLoader.load(file_in)
		if wav.format == 3:
			wav.format = AudioStreamWAV.FORMAT_16_BITS
	else:
		wav = AudioStreamWAV.load_from_file(file_in, {"format": AudioStreamWAV.FORMAT_16_BITS})
	
	if wav.format != AudioStreamWAV.FORMAT_16_BITS:
		printerr("Error, AudioStreamWAV should be 16 bits.")
		return ERR_FILE_CANT_READ
	
	
	const HEADER : int = 32

	var bit_index : int = 0
	var byte_index : int = 0
	var data : PackedByteArray = wav.data
	var bytes : PackedByteArray = message.to_utf8_buffer()
	
	bytes.append(0) 
	
	var bits : int = bytes.size() * 8
	var samples : int = data.size() / 2
	
	if samples < bits + HEADER:
		push_error("Too small wav audio for hide the message. Size(Samples: [{0}] Message: [{1}])".format([bits, samples]))
		return ERR_FILE_CANT_WRITE
	
	for x in range(0, data.size(), 2):
		if byte_index >= bytes.size():
			break
			
		var low : int = data[x]
		var high : int  = data[x + 1]
		var value : int  = (high << 8) | low
		var bit_current : int = (bytes[byte_index] >> (7 - (bit_index % 8))) & 1
		
		value = (value & ~1) | bit_current
		data[x] = value & 0xFF
		data[x + 1] = (value >> 8) & 0xFF
		
		bit_index += 1
		if bit_index % 8 == 0:
			byte_index += 1

	var new_wav : AudioStreamWAV = AudioStreamWAV.new()
	new_wav.format = wav.format
	new_wav.mix_rate = wav.mix_rate
	new_wav.stereo = wav.stereo
	new_wav.data = data
	
	print("New audio wav created")
	
	return new_wav.save_to_wav(file_out)
	

func show_message(file_in : String) -> String:
	var audio_wav : AudioStreamWAV
	
	if ResourceLoader.exists(file_in):
		audio_wav = ResourceLoader.load(file_in)
		if audio_wav.format == 3:
			audio_wav.format = AudioStreamWAV.FORMAT_16_BITS
	else:
		audio_wav = AudioStreamWAV.load_from_file(file_in, {"format": AudioStreamWAV.FORMAT_16_BITS})
	
	
	if audio_wav.format != AudioStreamWAV.FORMAT_16_BITS:
		printerr("Error, AudioStreamWAV should be 16 bits.")
		return ""

	var byte : int = 0
	var bit : int = 0
	var data : PackedByteArray = audio_wav.data
	var bytes : PackedByteArray = PackedByteArray()
	
	for x in range(0, data.size(), 2):
		var low : int = data[x]
		var high : int = data[x + 1]
		var value : int = (high << 8) | low
		var current_bit : int = value & 1
		
		byte = (byte << 1) | current_bit
		bit += 1
		
		if bit == 8:
			if byte == 0:
				break
				
			bytes.append(byte)
			byte = 0
			bit = 0
			
	return bytes.get_string_from_utf8()
