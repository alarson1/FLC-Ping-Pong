extends Node3D
## Root node of the FLC SolarLab Starter simulation
##
@onready var _simlink = $SimLink
@onready var _sim_config = SimLink.SimulationConfig.new()

# Called once all nodes have been added in the scene tree
func _ready():
	#$SimLink.simulation_completed.connect()
	#$SimLink.simulation_failed.connect()
	$SimLink.simulation_completed.connect(intercept_sim)
	$SimLink.simulation_failed.connect(intercept_failed)
	
	# The Camera Rig will try to avoid colliding with objects
	# Tell the rig to ingore these objects


## Handle the return of simulation results
func run_sim():
	# TODO: populate any needed state in the config dictionary
	_simlink.simulate(_sim_config)
	pass

## Handle the return of simulation results
func intercept_sim(sim_results: Dictionary):
	# TODO: add code to handle results from the simulation
	pass

## Handle the failure of a simulation 
func intercept_failed(text):
	print("Error: Simulation failure: ", text)
