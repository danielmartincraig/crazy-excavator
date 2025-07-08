extends Node2D

@onready var excavator = $Excavator
@onready var dirt_terrain = $DirtTerrain

var dirt_tiles_dug = 0
var score = 0

func _ready():
	# Initialize the dirt terrain
	setup_dirt_terrain()
	
	# Connect signals if needed
	print("Crazy Excavator game started!")
	print("Use arrow keys to move, down arrow to dig!")

func setup_dirt_terrain():
	# Create a simple dirt terrain using TileMap
	# Note: You'll need to set up a TileSet resource in the editor
	# with dirt textures for this to work properly
	
	# For now, we'll just set up the basic structure
	# The actual terrain creation would need to be done in the editor
	# or with a proper TileSet resource
	
	print("Setting up dirt terrain...")
	
	# Example of how you might generate dirt terrain:
	# (This requires a TileSet to be assigned in the editor)
	"""
	var dirt_source_id = 0  # ID of your dirt tile source
	var dirt_atlas_coords = Vector2i(0, 0)  # Atlas coordinates of dirt tile
	
	# Create a layer of dirt underground
	for x in range(-20, 21):
		for y in range(5, 15):
			dirt_terrain.set_cell(0, Vector2i(x, y), dirt_source_id, dirt_atlas_coords)
	"""
	
	# Set the terrain position
	dirt_terrain.position = Vector2(0, 0)

func _process(_delta):
	# Update game logic
	update_ui()

func update_ui():
	# Update score display, health, etc.
	# This could be connected to UI elements
	pass

func on_dirt_dug(dig_position: Vector2):
	# Called when the excavator digs dirt
	dirt_tiles_dug += 1
	score += 10
	
	print("Dirt dug at: ", dig_position)
	print("Total dirt dug: ", dirt_tiles_dug)
	print("Score: ", score)

func _input(event):
	# Handle global input events
	if event.is_action_pressed("ui_cancel"):
		# Could be used for pausing or quitting
		print("Game paused/quit")
