extends Node2D
class_name Building

@export var data: Resource
@onready var type = data.type

@onready var sprite = $Sprite2D
@onready var collider = $Area2D
@onready var build_timer_ui = $BuildTimerUI

@onready var pulse_shader = preload("res://src/buildings/shaders/pulse.gdshader")

@onready var build_start_sfx = preload("res://assets/audio/sfx/Building_Start.mp3")
@onready var build_finish_sfx = preload("res://assets/audio/sfx/Building_Finish.mp3")
@onready var cant_place_sfx = preload("res://assets/audio/sfx/Cant_Place_Building_There.mp3")

# Build menu vars
var preview = false
var outside_gridmap = false
var original_color: Color
var placeable = false
@export var placed = false

# Building process vars
var ticks_left_to_build: int
@export var building_complete: bool = false

# Deletion
var is_selected: bool = false
var can_delete: bool = true
var is_deconstructing: bool = false
var ticks_left_to_delete: int

enum TYPES {
	HabBuilding,
	FoodBuilding,
	WaterBuilding,
	AirBuilding
}


func _ready():
#	sprite.texture = data.sprite
#	collider = data.collision_data
	set_original_color()
	build_timer_ui.visible = false
	TickManager.tick.connect(_on_tick)


func build_in_progress():
	# Update the building to show it's under construction
	var pulse_colour = Color("#ffd4a3")
	pulse_colour.a = 0.5
	var pulse_mat = ShaderMaterial.new()
	pulse_mat.shader = pulse_shader
	sprite.material = pulse_mat
	sprite.material.set_shader_parameter("shine_color", pulse_colour)
	sprite.material.set_shader_parameter("full_pulse_cycle", true)
	sprite.material.set_shader_parameter("mode", 1)


func deconstruct_in_progress():
	var deconstruct_colour: Color = Color("#853519")
	deconstruct_colour.a = 0.5
	var deconstruct_mat = ShaderMaterial.new()
	deconstruct_mat.shader = pulse_shader
	sprite.material = deconstruct_mat
	sprite.material.set_shader_parameter("shine_color", deconstruct_colour)
	sprite.material.set_shader_parameter("full_pulse_cycle", true)
	sprite.material.set_shader_parameter("mode", 1)


func _physics_process(delta):
	if Input.is_action_just_pressed("cancel_place_building"):
		if is_selected and can_delete and not preview:
			set_building_remove()
			

func _process(delta):
	if not placed and preview:
		if collider.has_overlapping_areas() or collider.has_overlapping_bodies() or outside_gridmap:
			color_sprite(1, 0, 0, 0.5)
			placeable = false
		else:
			color_sprite(0, 1, 0, 0.5)
			placeable = true


func _on_tick():
	if not placed:
		return
	if not building_complete:
		if ticks_left_to_build <= 1:
			building_complete = true
			build_timer_ui.visible = false
			ResourceManager.add_building(self)
			ResourceManager.retrieve_workers(self)
			SoundManager.play_sound(build_finish_sfx, "SFX")
			sprite.material.set_shader_parameter("mode", 0)
		else:
			ticks_left_to_build -= 1
			build_timer_ui.label.text = str(ticks_left_to_build)
	elif is_deconstructing:
		if ticks_left_to_delete <= 1:
			build_timer_ui.visible = false
			ResourceManager.retrieve_workers(self)
			SoundManager.play_sound(build_finish_sfx, "SFX")
			self.queue_free()
		else:
			ticks_left_to_delete -= 1
			build_timer_ui.label.text = str(ticks_left_to_delete)


func set_building_placed():
	placed = true
	preview = false
	#
	ResourceManager.assign_workers(self)
	# Restore the building's true colour outside of preview UI
	color_sprite(original_color.r, original_color.g, original_color.b, original_color.a)
	# Update build timer/construction effects
	ticks_left_to_build = data.construction_time
	build_timer_ui.label.text = str(ticks_left_to_build)
	build_timer_ui.visible = true
	build_in_progress()
	SoundManager.play_sound(build_start_sfx, "SFX")


func set_building_remove():
	if ResourceManager.worker_amount >= data.people_cost:
		is_deconstructing = true
		# Costs workers to deconstruct
		ResourceManager.assign_workers(self)
		# Update build timer/construction effects
		ticks_left_to_delete = data.destruction_time
		build_timer_ui.label.text = str(ticks_left_to_delete)
		build_timer_ui.visible = true
		deconstruct_in_progress()
		SoundManager.play_sound(build_start_sfx, "SFX")
	else:
		BuildingManager.emit_signal("not_enough_workers")
		SoundManager.play_sound(cant_place_sfx, "SFX")


func set_original_color():
	if sprite is Sprite2D:
		original_color = sprite.modulate
	elif sprite is Node2D and sprite.get_child_count() > 0:
		original_color = sprite.get_children()[0].modulate


func color_sprite(r, g, b, a):
	if sprite is Sprite2D:
		sprite.modulate = Color(r, g, b, a)
	elif sprite is Node2D and sprite.get_child_count() > 0:
		# This is a group of rectangle, used in testing only
		for item in sprite.get_children():
			item.modulate = Color(r, g, b, a)


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_PREDELETE:
			on_predelete()


func on_predelete() -> void:
	ResourceManager.remove_building(self)


func _on_area_2d_mouse_entered():
	# TODO add popup or highlight
	is_selected = true
	print(self.data.name + " selected")


func _on_area_2d_mouse_exited():
	is_selected = false
	print(self.data.name + " deselected")

