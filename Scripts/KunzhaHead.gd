extends Sprite2D

# 游戏参数
@export var speed = 500
@export var body_gap = 30

# 游戏世界边界
const WORLD_WIDTH = 2560
const WORLD_HEIGHT = 1440
const HEAD_RADIUS = 77.78
const BODY_RADIUS = 20
const SAFE_BODY_COUNT = 3

var direction = Vector2.ZERO
var body_parts = []
var position_history = []

var game_started = false
var game_over = false
var score = 0

var score_label: Label = null

# ✅ 你要的核心：连续转弯冷却机制
var turn_count = 0                  # 连续转弯次数
var turn_cooldown = 0.0             # 冷却计时器
const COOLDOWN_TIME = 0.1          # 0.1秒冷却（你要的）

func _ready():
	score_label = get_parent().get_node("CanvasLayer/ScoreLabel")

func _process(delta):
	# 空格保护机制
	if Input.is_action_just_pressed("ui_accept") and (!game_started or game_over):
		restart_game()

	if !game_started or game_over:
		return

	# 冷却时间倒计时
	if turn_cooldown > 0:
		turn_cooldown -= delta

	position_history.insert(0, position)
	position += direction * speed * delta

	check_boundary_collision()
	check_body_collision()
	update_body()

# ✅ 方向控制：连续按2次后，第三次强制冷却0.2秒
func _input(event):
	if !game_started or game_over:
		return

	var new_dir = direction

	if event.is_action_pressed("ui_up"):
		if direction != Vector2.DOWN:
			new_dir = Vector2.UP
	elif event.is_action_pressed("ui_down"):
		if direction != Vector2.UP:
			new_dir = Vector2.DOWN
	elif event.is_action_pressed("ui_left"):
		if direction != Vector2.RIGHT:
			new_dir = Vector2.LEFT
	elif event.is_action_pressed("ui_right"):
		if direction != Vector2.LEFT:
			new_dir = Vector2.RIGHT

	# 方向没变化，直接退出
	if new_dir == direction:
		return

	# ✅ 核心规则：第三次转弯必须等0.2秒
	if turn_count >= 2 and turn_cooldown > 0:
		return  # 冷却中，按了也没用

	# 执行转弯
	direction = new_dir

	# 连续转弯计数
	turn_count += 1
	if turn_count >= 2:
		turn_cooldown = COOLDOWN_TIME  # 开启0.2秒冷却
	else:
		turn_cooldown = 0.0

func update_body():
	for i in range(body_parts.size()):
		var idx = (i+1) * body_gap
		if idx < position_history.size():
			body_parts[i].position = position_history[idx]

func check_boundary_collision():
	var left_edge = position.x - HEAD_RADIUS
	var right_edge = position.x + HEAD_RADIUS
	var top_edge = position.y - HEAD_RADIUS
	var bottom_edge = position.y + HEAD_RADIUS
	
	if left_edge <= 0:
		game_over = true
	if right_edge >= WORLD_WIDTH:
		game_over = true
	if top_edge <= 0:
		game_over = true
	if bottom_edge >= WORLD_HEIGHT:
		game_over = true

func check_body_collision():
	if body_parts.size() <= SAFE_BODY_COUNT:
		return

	for i in range(SAFE_BODY_COUNT, body_parts.size()):
		var body = body_parts[i]
		if position.distance_to(body.position) < BODY_RADIUS * 1.8:
			game_over = true
			return

func _on_Area2D_area_entered(area):
	if !game_started or game_over:
		return
	
	var food_parent = area.get_parent()
	if food_parent.name.find("Furui") != -1 && food_parent.visible:
		get_parent().on_food_eaten()

		score += 10
		if score_label != null:
			score_label.text = "分数：" + str(score)

func add_body(food_texture):
	var new_body = Sprite2D.new()
	new_body.texture = food_texture
	new_body.scale = Vector2(0.05, 0.05)
	get_parent().add_child(new_body)
	body_parts.append(new_body)

func restart_game():
	for part in body_parts:
		part.queue_free()
	body_parts.clear()
	position_history.clear()
	
	var min_pos = HEAD_RADIUS + 20
	var max_x = WORLD_WIDTH - HEAD_RADIUS - 20
	var max_y = WORLD_HEIGHT - HEAD_RADIUS - 20
	position = Vector2(
		randf_range(min_pos, max_x),
		randf_range(min_pos, max_y)
	)
	
	direction = Vector2.ZERO
	game_started = true
	game_over = false
	
	# 重置冷却机制
	turn_count = 0
	turn_cooldown = 0.0
	
	score = 0
	if score_label != null:
		score_label.text = "分数：0"
	
	get_parent().spawn_food()
