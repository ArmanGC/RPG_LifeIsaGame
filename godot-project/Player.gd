extends CharacterBody2D

const SPEED = 220.0

func _ready() -> void:
	var shape = CollisionShape2D.new()
	var circle = CircleShape2D.new()
	circle.radius = 14
	shape.shape = circle
	add_child(shape)

	var body = Polygon2D.new()
	body.color = Color(0.35, 0.72, 0.98)
	body.polygon = PackedVector2Array([Vector2(0, -16), Vector2(14, 12), Vector2(0, 6), Vector2(-14, 12)])
	add_child(body)

	var outline = Line2D.new()
	outline.points = PackedVector2Array([Vector2(0, -16), Vector2(14, 12), Vector2(0, 6), Vector2(-14, 12), Vector2(0, -16)])
	outline.width = 1.5
	outline.default_color = Color(0.1, 0.3, 0.45)
	add_child(outline)

func _physics_process(_delta: float) -> void:
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = input_dir * SPEED
	move_and_slide()
