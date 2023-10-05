extends Node2D

@onready var star_particles = $Space/StarCPUParticles2D
@export var tutorial_disabled: bool = false

# We don't use the same variable in EventManager to avoid race condition
var n_hab_built = 0
var n_food_built = 0
var bgm_audio_player: AudioStreamPlayer
var bgm_music



func _ready():
	TickManager.tick_changed.connect(_update_star_particles)
	#
	ScreenTransitionManager.fade_in(1.5)

	# For tutorial only
	EventManager.building_finished.connect(tutorial_tracker)

	await ScreenTransitionManager.transitioned
	#
	if tutorial_disabled:
		EventManager.tutorial_progress = -1
	
	TickManager.start_ticks()
	bgm_music = load("res://assets/audio/music/ld54-bgm-medley-no-alarms-1.1.mp3")
	bgm_audio_player = SoundManager.play_music(bgm_music, 0.2, "Music")
	bgm_audio_player.finished.connect(play_bgm_again)


func tutorial_tracker(type: Building.TYPES):
	if EventManager.tutorial_progress >= 2 or EventManager.tutorial_progress <= -1 :
		return

	match type:
		Building.TYPES.HabBuilding:
			n_hab_built += 1
		Building.TYPES.FoodBuilding:
			n_food_built += 1	

	if n_food_built >= 2 and EventManager.tutorial_progress == 0:
		EventManager.play_specific_event("tutorial2_event")
		EventManager.tutorial_progress = 1
		return
	if n_hab_built >= 2:
		if EventManager.tutorial_progress == 1:
			EventManager.play_specific_event("tutorial3_event")
			EventManager.tutorial_progress = 2
		elif EventManager.tutorial_progress == -1:
			EventManager.play_specific_event("disabled_tutorial_event")
			EventManager.tutorial_progress = 2
		return


func _update_star_particles(tick_speed, is_paused):
	var tween = get_tree().create_tween()
	if is_paused:
		tween.tween_property(
			star_particles, "speed_scale", 0, 0.55
		).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	else:
		match tick_speed:
			TickManager.SLOW_TICK_SPEED:
				tween.tween_property(
					star_particles, "speed_scale", 1, 0.35
				).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
			TickManager.FAST_TICK_SPEED:
				tween.tween_property(
					star_particles, "speed_scale", 4, 0.2
				).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)


func _on_start_tutorial_timer_timeout() -> void:
	if EventManager.tutorial_progress == 0 and not tutorial_disabled:
		EventManager.play_specific_event("tutorial1_event")


func play_bgm_again():
	bgm_audio_player = SoundManager.play_music(bgm_music, 0.2, "Music")