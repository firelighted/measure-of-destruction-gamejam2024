extends RayCast3D

@onready var explosion = $"../../Explosion"
@onready var anim = $"../../AnimationPlayer"
@onready var explosionSound = $ExplosionStreamPlayer
@onready var measureSound = $MeasureStreamPlayer
@onready var interaction_label = get_node("/root/World/UI/InteractionLabel")
const INTERACT_KEY : String = "E"
const EXPLODE_KEY : String = "X"

var current_collider

func _ready() -> void:
	set_interaction_text("")

func _process(_delta):
	var collider = get_collider() 
	if is_colliding() and collider is Interactable:
		# record what we're interacting with
		if current_collider != collider:
			set_interaction_text(collider.get_interaction_text())
			current_collider = collider
		if Input.is_action_just_pressed("interact"):
			collider.interact()
			anim.play("measure")
			$DelayMeasureSoundTimer.start(0.4)
			set_interaction_text(collider.get_interaction_text()) 
		if Input.is_action_just_pressed("explode"):
			explode(collider)
	elif is_instance_valid(current_collider): # no longer interacting with anything
		current_collider.end_interact()
		current_collider = null
		set_interaction_text("")

func explode(collider):
	explosion.global_position = collider.global_position
	explosion.visible = true
	explosion.explode()
	current_collider.end_interact()
	explosionSound.play()
	current_collider = null
	set_interaction_text("")
	collider.queue_free()

func set_interaction_text(text):
	if !text:
		interaction_label.set_text("")
		interaction_label.set_visible(false)
	else:
		interaction_label.set_text("Press %s to %s, %s to %s" % [INTERACT_KEY, text, EXPLODE_KEY, "explode"])
		interaction_label.set_visible(true)


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name != "idle":
		anim.play("idle")


func _on_delay_measure_sound_timer_timeout() -> void:
	measureSound.play()
