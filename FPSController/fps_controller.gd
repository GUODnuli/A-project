extends CharacterBody3D

func _ready():
	for child in %WorldModel.find_children("*", "VisualInstance3D"):
		child.set_layer_mask_value(1, false)
		child.set_layer_mask_value(2, true)

func _physics_process(float):
	pass

func _process(float):
	pass
