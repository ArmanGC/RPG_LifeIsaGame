extends CanvasLayer

var current_id: String = ""
var content: VBoxContainer

func _ready() -> void:
	layer = 20
	visible = false

	var bg = ColorRect.new()
	bg.color = Color(0, 0, 0, 0.55)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(bg)

	var panel = Panel.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.position = Vector2(-260, -260)
	panel.size = Vector2(520, 520)
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.11, 0.12, 0.15, 0.98)
	style.border_color = Color(0.2, 0.22, 0.27)
	style.set_border_width_all(1)
	style.set_corner_radius_all(14)
	panel.add_theme_stylebox_override("panel", style)
	add_child(panel)

	var scroll = ScrollContainer.new()
	scroll.position = Vector2(20, 20)
	scroll.size = Vector2(480, 480)
	panel.add_child(scroll)

	content = VBoxContainer.new()
	content.custom_minimum_size = Vector2(460, 0)
	content.add_theme_constant_override("separation", 10)
	scroll.add_child(content)

	GameData.quests_changed.connect(func():
		if visible and current_id != "":
			refresh()
	)

func open_quest(id: String) -> void:
	current_id = id
	visible = true
	refresh()

func close() -> void:
	visible = false
	current_id = ""

func _label(text: String, size: int = 12, color: Color = Color(0.57, 0.6, 0.66)) -> Label:
	var l = Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	return l

func refresh() -> void:
	for c in content.get_children():
		c.queue_free()

	var q = GameData.get_quest(current_id)
	if q == null:
		close()
		return

	var header = HBoxContainer.new()
	content.add_child(header)
	var title_edit = LineEdit.new()
	title_edit.text = q["title"]
	title_edit.custom_minimum_size = Vector2(370, 0)
	title_edit.add_theme_font_size_override("font_size", 17)
	title_edit.focus_exited.connect(func(): GameData.update_quest_field(current_id, "title", title_edit.text))
	header.add_child(title_edit)
	var close_btn = Button.new()
	close_btn.text = "Cerrar"
	close_btn.pressed.connect(close)
	header.add_child(close_btn)

	content.add_child(_label("CLIENTE / ÁREA"))
	var client_edit = LineEdit.new()
	client_edit.text = q["client"]
	client_edit.placeholder_text = "Ej: Cliente Acme"
	client_edit.focus_exited.connect(func(): GameData.update_quest_field(current_id, "client", client_edit.text))
	content.add_child(client_edit)

	content.add_child(_label("FECHA LÍMITE (AAAA-MM-DD)"))
	var deadline_edit = LineEdit.new()
	deadline_edit.text = q["deadline"]
	deadline_edit.placeholder_text = "2026-09-15"
	deadline_edit.focus_exited.connect(func(): GameData.update_quest_field(current_id, "deadline", deadline_edit.text))
	content.add_child(deadline_edit)

	content.add_child(_label("ESTADO"))
	var status_option = OptionButton.new()
	status_option.add_item("En curso", 0)
	status_option.add_item("En pausa", 1)
	status_option.add_item("Completada", 2)
	var status_map = {"active": 0, "paused": 1, "done": 2}
	var status_map_rev = {0: "active", 1: "paused", 2: "done"}
	status_option.select(status_map.get(q["status"], 0))
	status_option.item_selected.connect(func(idx): GameData.update_quest_field(current_id, "status", status_map_rev[idx]))
	content.add_child(status_option)

	content.add_child(_label("DIFICULTAD"))
	var diff_box = HBoxContainer.new()
	diff_box.add_theme_constant_override("separation", 6)
	for n in range(1, 5):
		var gem_btn = Button.new()
		gem_btn.text = str(n)
		gem_btn.custom_minimum_size = Vector2(32, 32)
		gem_btn.toggle_mode = true
		gem_btn.button_pressed = (n <= q["priority"])
		gem_btn.pressed.connect(func(): GameData.update_quest_field(current_id, "priority", n))
		diff_box.add_child(gem_btn)
	content.add_child(diff_box)

	content.add_child(_label("OBJETIVOS (dan XP al completarlos)"))
	for o in q["objectives"]:
		var row = HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)
		var obj_id = o["id"]

		var check = CheckBox.new()
		check.button_pressed = o["done"]
		check.toggled.connect(func(_pressed): GameData.toggle_objective(current_id, obj_id))
		row.add_child(check)

		var text_edit = LineEdit.new()
		text_edit.text = o["text"]
		text_edit.custom_minimum_size = Vector2(210, 0)
		text_edit.focus_exited.connect(func(): GameData.update_objective_text(current_id, obj_id, text_edit.text))
		row.add_child(text_edit)

		var star_btn = Button.new()
		star_btn.text = "★" if o["today"] else "☆"
		star_btn.tooltip_text = "Marcar para hoy"
		star_btn.pressed.connect(func(): GameData.toggle_today(current_id, obj_id))
		row.add_child(star_btn)

		row.add_child(_label("+" + str(o["xp"]), 12, Color(0.89, 0.7, 0.3)))

		var del_btn = Button.new()
		del_btn.text = "✕"
		del_btn.pressed.connect(func(): GameData.delete_objective(current_id, obj_id))
		row.add_child(del_btn)

		content.add_child(row)

	var add_row = HBoxContainer.new()
	var new_obj_edit = LineEdit.new()
	new_obj_edit.placeholder_text = "Añadir objetivo nuevo…"
	new_obj_edit.custom_minimum_size = Vector2(360, 0)
	new_obj_edit.text_submitted.connect(func(t):
		GameData.add_objective(current_id, t)
		new_obj_edit.text = ""
	)
	add_row.add_child(new_obj_edit)
	var add_btn = Button.new()
	add_btn.text = "+"
	add_btn.pressed.connect(func():
		GameData.add_objective(current_id, new_obj_edit.text)
		new_obj_edit.text = ""
	)
	add_row.add_child(add_btn)
	content.add_child(add_row)

	var delete_quest_btn = Button.new()
	delete_quest_btn.text = "Eliminar misión"
	delete_quest_btn.pressed.connect(func():
		GameData.delete_quest(current_id)
		close()
	)
	content.add_child(delete_quest_btn)
