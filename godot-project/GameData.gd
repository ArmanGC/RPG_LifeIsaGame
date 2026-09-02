extends Node

# ---------------------------------------------------------
# GameData: singleton (autoload) con el estado del jugador
# y todas las misiones. Se guarda solo en user://savegame.json
# ---------------------------------------------------------

signal xp_changed
signal level_up(new_level)
signal quests_changed

var player: Dictionary = {"xp": 0, "level": 1, "streak": 0, "last_active_date": ""}
var quests: Array = []

const SAVE_PATH = "user://savegame.json"

func _ready() -> void:
	load_game()
	_check_streak()

func xp_for_level(lvl: int) -> int:
	return 80 + (lvl - 1) * 40

func _today_str() -> String:
	var dt = Time.get_date_dict_from_system()
	return "%04d-%02d-%02d" % [dt.year, dt.month, dt.day]

func _check_streak() -> void:
	var today = _today_str()
	if player.get("last_active_date", "") != today:
		var yesterday_unix = Time.get_unix_time_from_system() - 86400
		var yd = Time.get_date_dict_from_unix_time(int(yesterday_unix))
		var yesterday_str = "%04d-%02d-%02d" % [yd.year, yd.month, yd.day]
		if player.get("last_active_date", "") == yesterday_str:
			player["streak"] = player.get("streak", 0) + 1
		else:
			player["streak"] = 1
		player["last_active_date"] = today
		save_game()

func add_xp(amount: int) -> void:
	player["xp"] = player.get("xp", 0) + amount
	var leveled = false
	while player["xp"] >= xp_for_level(player["level"]):
		player["xp"] -= xp_for_level(player["level"])
		player["level"] += 1
		leveled = true
	save_game()
	xp_changed.emit()
	if leveled:
		level_up.emit(player["level"])

func remove_xp(amount: int) -> void:
	player["xp"] -= amount
	if player["xp"] < 0:
		if player["level"] > 1:
			player["level"] -= 1
			player["xp"] += xp_for_level(player["level"])
		else:
			player["xp"] = 0
	save_game()
	xp_changed.emit()

func new_id() -> String:
	return str(Time.get_ticks_usec()) + "_" + str(randi() % 100000)

func add_quest(pos: Vector2) -> Dictionary:
	var q = {
		"id": new_id(),
		"title": "Nueva misión",
		"client": "",
		"priority": 2,
		"deadline": "",
		"status": "active",
		"pos_x": pos.x,
		"pos_y": pos.y,
		"objectives": []
	}
	quests.append(q)
	save_game()
	quests_changed.emit()
	return q

func get_quest(id: String) -> Variant:
	for q in quests:
		if q["id"] == id:
			return q
	return null

func delete_quest(id: String) -> void:
	quests = quests.filter(func(q): return q["id"] != id)
	save_game()
	quests_changed.emit()

func update_quest_field(id: String, field: String, value) -> void:
	var q = get_quest(id)
	if q:
		q[field] = value
		save_game()
		quests_changed.emit()

func add_objective(quest_id: String, text: String) -> void:
	var q = get_quest(quest_id)
	if q and text.strip_edges() != "":
		q["objectives"].append({"id": new_id(), "text": text.strip_edges(), "xp": 10, "done": false, "today": false})
		q["status"] = "active"
		save_game()
		quests_changed.emit()

func delete_objective(quest_id: String, obj_id: String) -> void:
	var q = get_quest(quest_id)
	if q:
		q["objectives"] = q["objectives"].filter(func(o): return o["id"] != obj_id)
		save_game()
		quests_changed.emit()

func update_objective_text(quest_id: String, obj_id: String, text: String) -> void:
	var q = get_quest(quest_id)
	if q:
		for o in q["objectives"]:
			if o["id"] == obj_id:
				o["text"] = text
		save_game()

func toggle_objective(quest_id: String, obj_id: String) -> void:
	var q = get_quest(quest_id)
	if q:
		for o in q["objectives"]:
			if o["id"] == obj_id:
				o["done"] = !o["done"]
				if o["done"]:
					add_xp(o["xp"])
				else:
					remove_xp(o["xp"])
		var all_done = q["objectives"].size() > 0
		for o in q["objectives"]:
			if not o["done"]:
				all_done = false
		q["status"] = "done" if all_done else "active"
		save_game()
		quests_changed.emit()

func toggle_today(quest_id: String, obj_id: String) -> void:
	var q = get_quest(quest_id)
	if q:
		for o in q["objectives"]:
			if o["id"] == obj_id:
				o["today"] = !o["today"]
		save_game()
		quests_changed.emit()

func save_game() -> void:
	var data = {"player": player, "quests": quests}
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))
		file.close()

func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var text = file.get_as_text()
		file.close()
		var result = JSON.parse_string(text)
		if result != null:
			player = result.get("player", player)
			quests = result.get("quests", quests)
