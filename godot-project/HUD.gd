extends CanvasLayer

var level_label: Label
var xp_bar: ProgressBar
var xp_label: Label
var streak_label: Label
var toast_label: Label
var toast_timer: Timer

func _ready() -> void:
	layer = 10

	var panel = Panel.new()
	panel.position = Vector2(20, 20)
	panel.size = Vector2(360, 74)
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.11, 0.12, 0.15, 0.92)
	style.border_color = Color(0.2, 0.22, 0.27)
	style.set_border_width_all(1)
	style.set_corner_radius_all(12)
	panel.add_theme_stylebox_override("panel", style)
	add_child(panel)

	level_label = Label.new()
	level_label.position = Vector2(16, 8)
	level_label.add_theme_font_size_override("font_size", 15)
	level_label.add_theme_color_override("font_color", Color(0.89, 0.7, 0.3))
	panel.add_child(level_label)

	xp_label = Label.new()
	xp_label.position = Vector2(200, 10)
	xp_label.add_theme_font_size_override("font_size", 12)
	xp_label.add_theme_color_override("font_color", Color(0.57, 0.6, 0.66))
	panel.add_child(xp_label)

	xp_bar = ProgressBar.new()
	xp_bar.position = Vector2(16, 34)
	xp_bar.size = Vector2(328, 10)
	xp_bar.show_percentage = false
	panel.add_child(xp_bar)

	streak_label = Label.new()
	streak_label.position = Vector2(16, 50)
	streak_label.add_theme_font_size_override("font_size", 12)
	streak_label.add_theme_color_override("font_color", Color(0.89, 0.4, 0.3))
	panel.add_child(streak_label)

	toast_label = Label.new()
	toast_label.position = Vector2(20, 104)
	toast_label.add_theme_font_size_override("font_size", 15)
	toast_label.add_theme_color_override("font_color", Color(0.89, 0.7, 0.3))
	toast_label.visible = false
	add_child(toast_label)

	toast_timer = Timer.new()
	toast_timer.one_shot = true
	toast_timer.wait_time = 2.2
	add_child(toast_timer)
	toast_timer.timeout.connect(func(): toast_label.visible = false)

	GameData.xp_changed.connect(_refresh)
	GameData.level_up.connect(_on_level_up)
	_refresh()

func _refresh() -> void:
	var p = GameData.player
	level_label.text = "Nivel " + str(p["level"])
	xp_label.text = str(p["xp"]) + " / " + str(GameData.xp_for_level(p["level"])) + " XP"
	xp_bar.max_value = GameData.xp_for_level(p["level"])
	xp_bar.value = p["xp"]
	streak_label.text = str(p.get("streak", 0)) + " días de racha"

func _on_level_up(new_level: int) -> void:
	toast_label.text = "¡Subiste a nivel " + str(new_level) + "!"
	toast_label.visible = true
	toast_timer.start()
