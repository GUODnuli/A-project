extends CharacterBody3D

@export var look_sensitivity : float = 0.006
@export var jump_velocity := 6
@export var auto_bhop := true
@export var walk_speed := 7.0
@export var run_speed := 11.0

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

func _physics_process(float):
	pass

func _process(float):
	pass

func _handle_air_physics(delta) -> void:
	pass

func _handle_ground_physics(delta) -> void:
	var input_dir := Input.get_vector("left", "right", "up", "down").normalized()
	wish_dir = self.global_transform.basis * Vector3(-input_dir.x, 0, -input_dir.y)