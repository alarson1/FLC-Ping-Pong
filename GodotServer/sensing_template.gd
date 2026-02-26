extends SensingConnect
# abstracts away all netowrking

signal message_received()   # connect to other scripts


func _ready() -> void:
	super._ready()
	
	
func handle_msg(msg: String):
	"""
	This method handles incoming messages from the Sensing device.
	"""
	print(msg)
