extends CharacterBody2D

@export var speed = 300.0
@export var jump_velocity = -400.0
@export var dig_power = 5.0
@export var dig_range = 100.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var sprite = $ExcavatorSprite
@onready var camera = $Camera
@onready var dirt_terrain = get_node("../DirtTerrain")

var is_digging = false
var dig_timer = 0.0
var dig_cooldown = 0.3

func _ready():
	# Make the camera current so it follows the excavator
	camera.enabled = true
	
	# Set up the excavator sprite (you'll need to add a texture in the editor)
	sprite.scale = Vector2(0.5, 0.5)  # Adjust size as needed

func _physics_process(delta):
	handle_movement(delta)
	handle_digging(delta)
	
	# Apply gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	
	# Move the character
	move_and_slide()

func handle_movement(delta):
	# Handle jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity
	
	# Handle horizontal movement
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * speed
		# Flip sprite based on direction
		sprite.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

func handle_digging(delta):
	# Update dig timer
	if dig_timer > 0:
		dig_timer -= delta
	
	# Check for dig input
	if Input.is_action_pressed("ui_down") and dig_timer <= 0:
		start_digging()

func start_digging():
	is_digging = true
	dig_timer = dig_cooldown
	
	# Calculate dig position (below the excavator)
	var dig_position = global_position + Vector2(0, 50)
	
	# Try to dig at the position
	dig_at_position(dig_position)
	
	# Add some visual feedback (you can enhance this)
	print("Digging at position: ", dig_position)

func dig_at_position(pos: Vector2):
	# This is a simplified digging system
	# In a full implementation, you'd interact with the TileMap
	# to remove dirt tiles at the specified position
	
	# For now, we'll just print debug info
	print("Excavating dirt at: ", pos)
	
	# TODO: Implement actual tile removal from DirtTerrain
	# Example: dirt_terrain.set_cell(0, dirt_terrain.local_to_map(pos), -1)

func _input(event):
	# Handle additional input events if needed
	if event.is_action_pressed("ui_select"):
		# Could be used for special excavator abilities
		print("Special excavator action!")

# Helper function to check if there's dirt at a position
func has_dirt_at_position(pos: Vector2) -> bool:
	# This would check the TileMap for dirt tiles
	# Return true if there's dirt to dig
	return true  # Placeholder
