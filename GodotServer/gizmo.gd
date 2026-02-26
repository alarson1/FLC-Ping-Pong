extends Node3D
## Provide a simple 3D position gizmo to position objects in the
## Godot player window. 
## 
## Attach "Slave Node" in the properties. 
 
@onready var camera= $"/root/FLCRoot/CameraRig/Camera3D"
@export var slave_node: Node3D

signal position_changed()
signal position_changing()

var _node = null
var _axes = {"x_axes":0,"y_axes":1,"z_axes":2}

const RAY_LENGTH = 1000

func _ready() -> void:
	if slave_node != null:
		global_position = slave_node.global_position

func _input(event):	
	if event is InputEventMouseButton:
		if event.is_pressed():
			if ray_cast() != null and _node == null and _axes.keys().has(ray_cast().name):
				_node = ray_cast()
		else: 
			_node = null
			emit_signal("position_changed")
	
	if event is InputEventMouseMotion and _node != null:
		var mousepos = get_viewport().get_mouse_position()
		var origin = camera.project_ray_origin(mousepos)
		var end = camera.project_ray_normal(mousepos)
		var depth= origin.distance_to(global_position)
		var final_position= origin + end * depth
		global_position[_axes[_node.name]]=final_position[_axes[_node.name]]
		if slave_node != null:
			slave_node.global_position[_axes[_node.name]]=final_position[_axes[_node.name]]
			emit_signal("position_changing")

func ray_cast():
	var space_state = get_world_3d().direct_space_state
	var mousepos = get_viewport().get_mouse_position()
	var origin = camera.project_ray_origin(mousepos)
	var end = origin + camera.project_ray_normal(mousepos) * RAY_LENGTH
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_areas = true
	var result = space_state.intersect_ray(query)
	result = result.get("collider")
	return result
