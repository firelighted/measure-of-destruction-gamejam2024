extends Node
class_name Interactable

# parent of all meshes that will be displayed
@onready var displaymeshes: Node3D = $DisplayMeshes
# simplified collision shape encompassing all displayed meshes 
@onready var coll: CollisionShape3D = $CollisionShape3D
@onready var timer: Timer = $MeasureTimer

@onready var select_mat: Material = load("res://src/Materials/default_selected.tres")
@export var normal_mats: Array[Material] = [load("res://src/Materials/default_unselected.tres")]

func _ready() -> void:
	set_measure_text("")
	var i = 0
	normal_mats = []
	# record the original materials so they can be reapplied
	for mesh_instance in displaymeshes.get_children():
		if mesh_instance.material_override != select_mat:
			normal_mats.append(mesh_instance.material_override)
		i+=1

func get_interaction_text():
	return "Interact"
	
func interact():
	print("Interacted with %s" % name)
	for mesh_instance in displaymeshes.get_children():
		mesh_instance.material_override = select_mat
	measure()

func end_interact():
	print("end interaction with %s" % name)
	for i in displaymeshes.get_child_count():
		displaymeshes.get_child(i).material_override = normal_mats[i]
	set_measure_text("")
	

func set_measure_text(text):
	$Label3D.text = text

func measure():
	set_measure_text("MEASURING...")
	timer.start()

func _on_measure_timer_timeout() -> void:
	# horrible rough approx of size based on the first mesh
	var size_adjusted = displaymeshes.get_child(0).mesh.get_aabb().size \
		* displaymeshes.get_child(0).scale * self.scale
	set_measure_text("TOO LARGE!!\n%d x %d" % \
		[size_adjusted.x, size_adjusted.y])
