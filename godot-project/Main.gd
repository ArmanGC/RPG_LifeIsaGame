extends Node2D

const PlayerScene = preload("res://Player.tscn")
const HUDScript = preload("res://HUD.gd")
const QuestPanelScript = preload("res://QuestPanel.gd")

var player: CharacterBody2D
var quest_markers: Dictionary = {}
var nearby_quest_id: String = ""
var prompt_label: Label
var quest_panel: CanvasLayer

func _ready() -> void:
	randomize()
	_build_world_background()
	_spawn_player()
	add_child(HUDScript.new())
	_build_prompt_layer()
	quest_panel = QuestPanelScript.new()
	add_child(quest_panel)

	_rebuild_all_quest_markers()
	GameData.quests_changed.connect(_rebuild_all_quest_markers)

	# Si es la primera vez (sin misiones), crea una misión de ejemplo
	if GameData.quests.is_empty():
		var q = GameData.add_quest(Vector2(150, -60))
		GameData.update_quest_field(q["id"], "title", "Mi primer proyecto")
		GameData.add_objective(q["id"], "Explora el mapa con las flechas")
		GameData.add_objective(q["id"], "Presiona N para crear una misión nueva")
		GameData.add_objective(q["id"], "Acércate y presiona Espacio para abrir esta misión")

func _build_world_background() -> void:
	var bg = ColorRect.new()
	bg.color = Color(0.07, 0.08, 0.1)
	bg.size = Vector2(4000, 4000)
	bg.position = Vector2(-2000, -2000)
	bg.z_index = -10
	add_child(bg)
	for gx in range(-1800, 1800, 90):
		for gy in range(-1800, 1800, 90):
			var dot = ColorRect.new()
			dot.color = Color(1, 1, 1, 0.035)
			dot.size = Vector2(3, 3)
			dot.position = Vector2(gx, gy)
			dot.z_index = -9
			add_child(dot)

func _spawn_player() -> void:
	player = PlayerScene.instantiate()
	player.position = Vector2.ZERO
	add_child(player)
	var cam = Camera2D.new()
	cam.zoom = Vector2(1.4, 1.4)
	cam.position_smoothing_enabled = true
	player.add_child(cam)
	cam.make_current()

func _build_prompt_layer() -> void:
	var layer_node = CanvasLayer.new()
	layer_node.layer = 5
	add_child(layer_node)

	prompt_label = Label.new()
	prompt_label.add_theme_font_size_override("font_size", 15)
	prompt_label.add_theme_color_override("font_color", Color(0.89, 0.7, 0.3))
	prompt_label.position = Vector2(20, 560)
	prompt_label.visible = false
	layer_node.add_child(prompt_label)

	var hint = Label.new()
	hint.text = "Flechas: moverse    N: nueva misión aquí    Espacio: interactuar"
	hint.add_theme_font_size_override("font_size", 12)
	hint.add_theme_color_override("font_color", Color(0.5, 0.53, 0.58))
	hint.position = Vector2(20, 586)
	layer_node.add_child(hint)

func _rebuild_all_quest_markers() -> void:
	for m in quest_markers.values():
		if is_instance_valid(m):
			m.queue_free()
	quest_markers.clear()
	for q in GameData.quests:
		_create_quest_marker(q)

func _create_quest_marker(q: Dictionary) -> void:
	var marker = Node2D.new()
	marker.position = Vector2(q.get("pos_x", 0.0), q.get("pos_y", 0.0))
	add_child(marker)

	var color = Color(0.89, 0.7, 0.3)
	if q["status"] == "done":
		color = Color(0.25, 0.72, 0.55)
	elif q["status"] == "paused":
		color = Color(0.4, 0.43, 0.5)

	var gem = Polygon2D.new()
	gem.color = color
	gem.polygon = PackedVector2Array([Vector2(0, -18), Vector2(16, 0), Vector2(0, 18), Vector2(-16, 0)])
	marker.add_child(gem)

	var outline = Line2D.new()
	outline.points = PackedVector2Array([Vector2(0, -18), Vector2(16, 0), Vector2(0, 18), Vector2(-16, 0), Vector2(0, -18)])
	outline.width = 1.5
	outline.default_color = Color(0, 0, 0, 0.25)
	marker.add_child(outline)

	var label = Label.new()
	label.text = q["title"]
	label.add_theme_font_size_override("font_size", 13)
	label.add_theme_color_override("font_color", Color(0.93, 0.93, 0.95))
	label.position = Vector2(-60, -42)
	label.custom_minimum_size = Vector2(120, 20)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	marker.add_child(label)

	var done_count = 0
	for o in q["objectives"]:
		if o["done"]:
			done_count += 1
	var progress_label = Label.new()
	progress_label.text = str(done_count) + "/" + str(q["objectives"].size())
	progress_label.add_theme_font_size_override("font_size", 11)
	progress_label.add_theme_color_override("font_color", Color(0.6, 0.63, 0.68))
	progress_label.position = Vector2(-15, 20)
	marker.add_child(progress_label)

	quest_markers[q["id"]] = marker

func _process(_delta: float) -> void:
	_check_nearby_quest()
	if Input.is_action_just_pressed("ui_accept") and nearby_quest_id != "" and not quest_panel.visible:
		quest_panel.open_quest(nearby_quest_id)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_N and not quest_panel.visible:
			var q = GameData.add_quest(player.position + Vector2(0, -50))
			quest_panel.open_quest(q["id"])
		elif event.keycode == KEY_ESCAPE and quest_panel.visible:
			quest_panel.close()

func _check_nearby_quest() -> void:
	nearby_quest_id = ""
	var closest_dist = 70.0
	for id in quest_markers.keys():
		var m = quest_markers[id]
		if not is_instance_valid(m):
			continue
		var d = player.position.distance_to(m.position)
		if d < closest_dist:
			closest_dist = d
			nearby_quest_id = id
	if nearby_quest_id != "" and not quest_panel.visible:
		var q = GameData.get_quest(nearby_quest_id)
		prompt_label.text = "Espacio: abrir \"" + q["title"] + "\""
		prompt_label.visible = true
	else:
		prompt_label.visible = false
