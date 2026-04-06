extends Sprite2D

# 游戏参数
@export var speed: float = 500.0
@export var body_gap: int = 30

# 边界
const WORLD_WIDTH = 2560
const WORLD_HEIGHT = 1440
const HEAD_RADIUS = 77.78
const BODY_RADIUS = 20
const SAFE_BODY_COUNT = 3

# UI 绑定
@export var score_label: Label
@export var game_over_panel: Panel
@export var score_final_label: Label
@export var food_count_label: Label
@export var start_cover: TextureRect
@export var timer_label: Label

# 倒计时
@export var total_time: float = 10.0
var current_time: float = 0.0

var direction: Vector2 = Vector2.ZERO
var body_parts: Array = []
var position_history: Array = []

var game_started: bool = false
var game_over: bool = false
var score: int = 0
var food_count: int = 0

var turn_count: int = 0
var turn_cooldown: float = 0.0
const COOLDOWN_TIME: float = 0.2

func _ready():
	game_started = false
	game_over = false
	if start_cover:
		start_cover.visible = true
	if game_over_panel:
		game_over_panel.visible = false
	current_time = total_time
	update_timer_label()

func _process(delta):
	if !game_started and !game_over:
		if Input.is_action_just_pressed("ui_accept"):
			start_game()
		return

	if game_over:
		if Input.is_action_just_pressed("ui_accept"):
			restart_direct()
		if Input.is_action_just_pressed("ui_cancel"):
			restart_to_home()
		return

	current_time -= delta
	if current_time <= 0:
		current_time = 0
		time_up()
		return
	update_timer_label()

	if turn_cooldown > 0:
		turn_cooldown -= delta

	position_history.insert(0, position)
	position += direction * speed * delta

	check_boundary_collision()
	check_body_collision()
	update_body()

func start_game():
	game_started = true
	if start_cover:
		start_cover.visible = false
	current_time = total_time
	update_timer_label()
	get_parent().spawn_food()

func update_timer_label():
	if timer_label:
		timer_label.text = "时间：" + str(ceil(current_time)) + " 秒"

# ====================== 时间到，保存蛇全部数据 ======================
func time_up():
	# 保存蛇数据到全局管理器
	var game_data = get_node("/root/GameDataManager")
	game_data.save_snake_data(self)
	
	# 跳转到第二关
	get_tree().change_scene_to_file("res://Scenes/nian.tscn")

func _input(event):
	if !game_started or game_over:
		return
	
	# ============= 这里加一行！=============
	if turn_cooldown > 0: return
	# =======================================
	
	if event.is_action_pressed("ui_up"):
		if direction != Vector2.DOWN:
			direction = Vector2.UP
			turn_cooldown = COOLDOWN_TIME  # 别忘了这个！
	elif event.is_action_pressed("ui_down"):
		if direction != Vector2.UP:
			direction = Vector2.DOWN
			turn_cooldown = COOLDOWN_TIME
	elif event.is_action_pressed("ui_left"):
		if direction != Vector2.RIGHT:
			direction = Vector2.LEFT
			turn_cooldown = COOLDOWN_TIME
	elif event.is_action_pressed("ui_right"):
		if direction != Vector2.LEFT:
			direction = Vector2.RIGHT
			turn_cooldown = COOLDOWN_TIME
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

	if left_edge <= 0 or right_edge >= WORLD_WIDTH or top_edge <= 0 or bottom_edge >= WORLD_HEIGHT:
		game_over = true
		if game_over_panel:
			game_over_panel.visible = true
		if score_final_label:
			score_final_label.text = "最终得分：" + str(score)
		if food_count_label:
			food_count_label.text = "食物总数：" + str(food_count)

func check_body_collision():
	if body_parts.size() <= SAFE_BODY_COUNT:
		return

	for i in range(SAFE_BODY_COUNT, body_parts.size()):
		var body = body_parts[i]
		if position.distance_to(body.position) < BODY_RADIUS * 1.8:
			game_over = true
			if game_over_panel:
				game_over_panel.visible = true
			if score_final_label:
				score_final_label.text = "最终得分：" + str(score)
			if food_count_label:
				food_count_label.text = "食物总数：" + str(food_count)
			return

func _on_Area2D_area_entered(area):
	if !game_started or game_over:
		return
	
	var food_parent = area.get_parent()
	if food_parent.name.find("Furui") != -1 && food_parent.visible:
		get_parent().on_food_eaten()
		score += 10
		food_count += 1
		get_parent().spawn_food()
		if score_label:
			score_label.text = "分数：" + str(score)

func on_food_eaten():
	pass

func add_body(food_texture):
	var new_body = Sprite2D.new()
	new_body.texture = food_texture
	new_body.scale = Vector2(0.05, 0.05)
	get_parent().add_child(new_body)
	body_parts.append(new_body)

func restart_direct():
	for part in body_parts:
		part.queue_free()
	body_parts.clear()
	position_history.clear()
	
	var min_pos = HEAD_RADIUS + 20
	var max_x = WORLD_WIDTH - HEAD_RADIUS - 20
	var max_y = WORLD_HEIGHT - HEAD_RADIUS - 20
	position = Vector2(randf_range(min_pos, max_x), randf_range(min_pos, max_y))
	
	direction = Vector2.ZERO
	game_started = true
	game_over = false
	
	turn_count = 0
	turn_cooldown = 0.0
	
	score = 0
	food_count = 0
	current_time = total_time
	
	if score_label:
		score_label.text = "分数：0"
	if game_over_panel:
		game_over_panel.visible = false
	if start_cover:
		start_cover.visible = false
	
	update_timer_label()
	get_parent().spawn_food()

func restart_to_home():
	for part in body_parts:
		part.queue_free()
	body_parts.clear()
	position_history.clear()
	
	var min_pos = HEAD_RADIUS + 20
	var max_x = WORLD_WIDTH - HEAD_RADIUS - 20
	var max_y = WORLD_HEIGHT - HEAD_RADIUS - 20
	position = Vector2(randf_range(min_pos, max_x), randf_range(min_pos, max_y))
	
	direction = Vector2.ZERO
	game_started = false
	game_over = false
	
	turn_count = 0
	turn_cooldown = 0.0
	
	score = 0
	food_count = 0
	current_time = total_time
	
	if score_label:
		score_label.text = "分数：0"
	if game_over_panel:
		game_over_panel.visible = false
	if start_cover:
		start_cover.visible = true
	
	update_timer_label()
