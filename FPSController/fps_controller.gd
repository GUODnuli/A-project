extends CharacterBody3D

@export var look_sensitivity : float = 0.006
@export var jump_velocity := 6
@export var auto_bhop := true
@export var walk_speed := 7.0
@export var sprint_speed := 11.0
@export var current_speed = walk_speed

const HEADBOB_MOVE_AMOUNT = 0.06
const HEADBOB_FREQUENCY = 2.4
var headbob_time := 0.0

# Air movement settings. Need to tweak these to get the feeling dialed in.
@export var air_cap := 0.85
@export var air_accel := 8.0
@export var air_move_speed := 5.0

var wish_dir := Vector3.ZERO

func _ready():
	for child in %WorldModel.find_children("*", "VisualInstance3D"):
		child.set_layer_mask_value(1, false)
		child.set_layer_mask_value(2, true)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			rotate_y(-event.relative.x * look_sensitivity)
			%Camera3D.rotate_x(-event.relative.y * look_sensitivity)
			%Camera3D.rotation.x = clamp(%Camera3D.rotation.x, deg_to_rad(-90.0), deg_to_rad(90.0))

func _headbob_effect(delta):
	headbob_time += delta * self.velocity.length()
	%Camera3D.transform.origin = Vector3(
		cos(headbob_time * HEADBOB_FREQUENCY * 0.5) * HEADBOB_MOVE_AMOUNT,
		sin(headbob_time * HEADBOB_FREQUENCY) * HEADBOB_MOVE_AMOUNT,
		0	
	)

func _physics_process(delta):
	var input_dir := Input.get_vector("left", "right", "up", "down").normalized()
	wish_dir = self.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)

	current_speed = walk_speed
	if Input.is_action_pressed("run"):
		current_speed = sprint_speed

	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			self.velocity.y = jump_velocity
		_handle_ground_physics(delta)
	else:
		_handle_air_physics(delta)
	
	move_and_slide()

func _process(delta):
	pass

func _handle_air_physics(delta) -> void:
	self.velocity.y -= ProjectSettings.get_setting("physics/3d/default_gravity") * delta

	#Classic battle tested & fan favorite source/quake air movement recipe.
	#CSS players gonna feel their gamer instincts kick in with this one
	var current_speed_in_wish_dir = self.velocity.dot(wish_dir)
	#Wish speed(if wish_dir >0 length)capped to air_cad
	var capped_speed = min((air_move_speed * wish_dir).length(), air_cap)
	# How much to get to the speed the player wishes (in the new dir)
	# Notice this allows for infinite speed. If wish _dir is perpendicular, we always need to add velocity
	# no matter how fast we're going. This is what allows for things like bhop in css & Quake.
	# Also happens to just give some very nice feeling movement & responsiveness when in the air.
	var add_speed_till_cap = capped_speed - current_speed_in_wish_dir
	if add_speed_till_cap > 0:
		var accel_speed = air_accel * air_move_speed * delta
		accel_speed = min(accel_speed, add_speed_till_cap)
		self.velocity += accel_speed * wish_dir	

func _handle_ground_physics(delta) -> void:
	self.velocity.x = wish_dir.x * current_speed
	self.velocity.z = wish_dir.z * current_speed
	_headbob_effect(delta)