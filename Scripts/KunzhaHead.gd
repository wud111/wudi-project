extends Sprite2D

# 游戏参数
@export var speed = 500
@export var body_gap = 25

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

var direction = Vector2.ZERO
var body_parts = []
var position_history = []

var game_started = false
var game_over = false
var score = 0
var food_count = 0

var turn_count = 0
var turn_cooldown = 0.0
const COOLDOWN_TIME = 0.2

func _ready():
	game_started = false
	game_over = false
	if start_cover:
		start_cover.visible = true
	if game_over_panel:
		game_over_panel.visible = false

func _process(delta):
	# 主界面：按空格开始
	if !game_started and !game_over:
		if Input.is_action_just_pressed("ui_accept"):
			start_game()
		return

	# 游戏结束：空格重开 | ESC回主页
	if game_over:
		if Input.is_action_just_pressed("ui_accept"):
			restart_direct()
		if Input.is_action_just_pressed("ui_cancel"):
			restart_to_home()
		return

	# 正常游戏
	if turn_cooldown > 0:
		turn_cooldown -= delta

	position_history.insert(0, position)
	position += direction * speed * delta

	check_boundary_collision()
	check_body_collision()
	update_body()

# 开始游戏
func start_game():
	game_started = true
	if start_cover:
		start_cover.visible = false
	get_parent().spawn_food()

# 方向控制（修复好了！）
func _input(event):
	if !game_started or game_over:
		return
	
	if event.is_action_pressed("ui_up"):
		if direction != Vector2.DOWN:
			direction = Vector2.UP
	elif event.is_action_pressed("ui_down"):
		if direction != Vector2.UP:
			direction = Vector2.DOWN
	elif event.is_action_pressed("ui_left"):
		if direction != Vector2.RIGHT:
			direction = Vector2.LEFT
	elif event.is_action_pressed("ui_right"):
		if direction != Vector2.LEFT:
			direction = Vector2.RIGHT

func update_body():
	for i in range(body_parts.size()):
		var idx = (i+1) * body_gap
		if idx < position_history.size():
			body_parts[i].position = position_history[idx]

func check_boundary_collision():
	var left_edge = position.x - HEAD_RADIUS + 11
	var right_edge = position.x + HEAD_RADIUS - 11
	var top_edge = position.y - HEAD_RADIUS + 30
	var bottom_edge = position.y + HEAD_RADIUS

	if left_edge <= 0 or right_edge >= WORLD_WIDTH or top_edge <= 0 or bottom_edge >= WORLD_HEIGHT:
		game_over = true
		if game_over_panel:
			game_over_panel.visible = true
		if score_final_label:
			score_final_label.text = "最终得分：" + str(score)
		if food_count_label:
			food_count_label.text = "收集的福瑞：" + str(food_count)

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
				food_count_label.text = "收集的福瑞：" + str(food_count)
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

# 失败后按空格：直接重新开始游戏（不显示封面）
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
	
	if score_label:
		score_label.text = "分数：0"
	if game_over_panel:
		game_over_panel.visible = false
	if start_cover:
		start_cover.visible = false
	
	get_parent().spawn_food()

# 失败后按ESC：返回主界面（显示封面）
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
	
	if score_label:
		score_label.text = "分数：0"
	if game_over_panel:
		game_over_panel.visible = false
	if start_cover:
		start_cover.visible = true
