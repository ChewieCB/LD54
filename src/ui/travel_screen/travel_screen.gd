extends Node2D
class_name TravelScreen

@onready var desc_label: Label = $TravelScreen/PathChoiceView/DescLabel
@onready var title_label: Label = $TravelScreen/TitleLabel
@onready var default_path_button: Button = $TravelScreen/PathChoiceView/VBoxContainer/Button
@onready var intergalatic_route_button: Button = $TravelScreen/PathChoiceView/VBoxContainer/Button2
@onready var asteroid_field_button: Button = $TravelScreen/PathChoiceView/VBoxContainer/Button3
@onready var void_field_button: Button = $TravelScreen/PathChoiceView/VBoxContainer/Button4
@onready var path_choice_view = $TravelScreen/PathChoiceView
@onready var change_path_button: Button = $TravelScreen/ChangePathButton
@onready var show_hide_travel_screen_button: Button = $TravelScreen/ShowHideTravelScreen
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var path_follow: PathFollow2D = $TravelScreen/ProgressView/Path2D/PathFollow2D

var trave_screen_open = false
var chose_path_screen_open = false
var path_length

func _ready() -> void:
	chose_path_screen_open = true
	_on_default_path_pressed()
	chose_path_screen_open = false
	TickManager.tick.connect(_update_path_follow)

func _update_path_follow():
	var path_progress = float(EventManager.tick_passed_total) / EventManager.tick_to_victory
	path_progress = clampf(path_progress, 0, 1)
	path_follow.progress_ratio = path_progress


func _on_default_path_pressed() -> void:
	if chose_path_screen_open:
		reset_color_all_buttons()
		default_path_button.self_modulate = Color.GREEN
		EventManager.chosen_path = EventManager.TRAVEL_PATH_TYPE.DEFAULT_PATH
		desc_label.text = "Default path\nYou have equal chance to meet all type of events."

func _on_intergalatic_route_pressed() -> void:
	if chose_path_screen_open:
		reset_color_all_buttons()
		intergalatic_route_button.self_modulate = Color.GREEN
		EventManager.chosen_path = EventManager.TRAVEL_PATH_TYPE.INTERGALATIC_ROUTE
		desc_label.text = "Intergalatic route\nYou are more likely to meet other travellers and refugees."

func _on_asteroid_field_pressed() -> void:
	if chose_path_screen_open:
		reset_color_all_buttons()
		asteroid_field_button.self_modulate = Color.GREEN
		EventManager.chosen_path = EventManager.TRAVEL_PATH_TYPE.ASTEROID_FIELD
		desc_label.text = "Asteroid field\nYou are more likely to get asteroid and planet related events."

func _on_void_field_pressed() -> void:
	if chose_path_screen_open:
		reset_color_all_buttons()
		void_field_button.self_modulate = Color.GREEN
		EventManager.chosen_path = EventManager.TRAVEL_PATH_TYPE.VOID_FIELD
		desc_label.text = "Void field\nThere are rarely anything happened out there. But if you encounter something, you gonna have a bad time...."

func reset_color_all_buttons():
	default_path_button.self_modulate = Color.WHITE
	intergalatic_route_button.self_modulate = Color.WHITE
	asteroid_field_button.self_modulate = Color.WHITE
	void_field_button.self_modulate = Color.WHITE

func _on_change_path_button_toggled(button_pressed:bool) -> void:
	var tween = get_tree().create_tween()
	if button_pressed:
		change_path_button.text = "Close"
		tween.parallel().tween_property(path_choice_view, "modulate:a", 1, 0.5).set_trans(Tween.TRANS_LINEAR)
		chose_path_screen_open = true
	else:
		change_path_button.text = "Change path"
		tween.parallel().tween_property(path_choice_view, "modulate:a", 0, 0.5).set_trans(Tween.TRANS_LINEAR)
		chose_path_screen_open = false


func _on_show_hide_travel_screen_toggled(button_pressed:bool) -> void:
	if button_pressed:
		show_hide_travel_screen_button.text = "Hide travel screen"
		animation_player.play("show")
		trave_screen_open = true
		show_hide_travel_screen_button.button_pressed = button_pressed

	else:
		show_hide_travel_screen_button.text = "Show travel screen"
		animation_player.play("hide")
		trave_screen_open = false
		show_hide_travel_screen_button.button_pressed = button_pressed

func hide_screen():
	if trave_screen_open:
		_on_show_hide_travel_screen_toggled(false)

func show_screen():
	if not trave_screen_open:
		_on_show_hide_travel_screen_toggled(true)
