extends Node

class_name SimLink

@export var host_name: String = "127.0.0.1"
@export var host_port: int = 5000

signal simulation_completed(Dictionary);
signal simulation_failed(String);

var requests: Array[HTTPRequest]
var rrobin: int = 0
var requests_queue_length = 8

const JSON_CONTENT_TYPE = ["Content-Type: application/json"]

class SimulationConfig extends RefCounted:
	# TEMPLATE TODO: remove stub, add necessary simulation state
	var stub: float

func simulate(config: SimulationConfig) -> void:

	var request_data = {
		# TEMPLATE TODO: add input data
	}
	
	var reply = await request("simulate", HTTPClient.METHOD_POST, request_data)
	
	if reply.is_empty():
		printerr("Unable to execute simulation")
		return

	simulation_completed.emit(reply)


func request(endpoint: String, action: HTTPClient.Method, content: Dictionary) -> Dictionary:
	var url = "http://%s:%s/%s" % [host_name, host_port, endpoint]
	var request_data: String
	var request_obj = await _request()

	if content.is_empty():
		request_data = ""
	else:
		request_data = JSON.stringify(content)
		
	#print_debug("Making HTTP request: ", url, " ", content)
	var error = request_obj.request(url, JSON_CONTENT_TYPE, action, request_data)
	
	if error != OK:
		var err_str = ""
		match error:
			ERR_UNCONFIGURED:
				err_str = "ERR_UNCONFIGURED"
			ERR_BUSY:
				err_str = "ERR_BUSY"
			ERR_INVALID_PARAMETER:
				err_str = "ERR_INVALID_PARAMETER"
				
		printerr("Unable to send web request: ", err_str, " ", rrobin)
		simulation_failed.emit("Unable to send web request: %s" % err_str)
		return {}

	var reply = await request_obj.request_completed
	if reply[0] != 0 or reply[1] != 200:
		printerr("Request failed: %s %s" % [reply[0], reply[1]])
		simulation_failed.emit("Request failed: %s %s" % [reply[0], reply[1]])
		return {}
		
	var reply_content: PackedByteArray = reply[-1]
	#print(reply_content.get_string_from_utf8())
	
	var parsed = JSON.parse_string(reply_content.get_string_from_utf8())
	
	if parsed == null:
		printerr("Malformed reply")
		simulation_failed.emit("Malformed reply")
		return {}
	
	#print(parsed)
	return parsed

func _init():
	for i in range(requests_queue_length):
		var request_obj = HTTPRequest.new()
		request_obj.use_threads = true
		requests.append(request_obj)
		add_child(request_obj)
		

func _request() -> HTTPRequest:
	rrobin = (rrobin + 1) % requests.size()
	var request_obj = requests[rrobin]

	# find an available HTTPClient
	var unavailable = 0
	while request_obj.get_http_client_status() != 0:
		unavailable += 1
		rrobin = (rrobin + 1) % requests.size()
		request_obj = requests[rrobin]
		
		if unavailable > requests_queue_length:
			# All our available clients are busy;
			# give them a second to complete
			await get_tree().create_timer(1).timeout
	
	return request_obj
