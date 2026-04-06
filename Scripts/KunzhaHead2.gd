extends Sprite2D

@export var speed = 400.0
@export var turn_rate = 0.3

# 用于数据加载的属性
var body_parts: Array = []
var position_history: Array = []

var direction = Vector2.ZERO
var desired_dir = Vector2.RIGHT
var score = 0
var food_count = 0
var game_over = false

func _ready():
	print("第二关蛇头初始化")
	# 确保不旋转
	rotation = 0
	rotation_degrees = 0
	
	# 更新分数显示
	var score_label = get_node_or_null("../CanvasLayer/Label")
	if score_label:
		score_label.text = "分数：" + str(score)
	else:
		# 尝试其他路径
		score_label = get_node_or_null("CanvasLayer/Label")
		if score_label:
			score_label.text = "分数：" + str(score)
	
	# 调试：检查Area2D节点
	print("=== 调试信息 ===")
	
	# 方法1：直接获取
	var area = get_node_or_null("Area2D")
	if area:
		print("✅ 方法1：找到Area2D节点")
		# 安全地获取属性
		if area.has_method("get_collision_layer"):
			print("  碰撞层:", area.collision_layer)
			print("  碰撞掩码:", area.collision_mask)
		else:
			print("  ⚠️ Area2D节点没有碰撞属性")
	else:
		print("❌ 方法1：找不到Area2D节点")
		
		# 方法2：尝试其他方式
		print("尝试其他查找方式...")
		var children = get_children()
		print("子节点数量:", children.size())
		for child in children:
			print("  - ", child.name, " (", child.get_class(), ")")
			if child is Area2D:
				print("    ✅ 找到Area2D子节点")
				area = child
				break

func _process(delta):
	if game_over:
		return

	position += direction * speed * delta
	
	# 确保不旋转
	rotation = 0
	rotation_degrees = 0
	
	# 保存位置历史并更新身体
	position_history.insert(0, position)
	update_body()
	
	# 边界检测
	check_boundary_collision()
	
	# 身体碰撞检测
	check_body_collision()

# 输入处理 - 改为直接控制，像第一关那样
func _input(event):
	if game_over:
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

# 身体更新函数
func update_body():
	var body_gap = 30  # 与第一关保持一致
	for i in range(body_parts.size()):
		var idx = (i + 1) * body_gap
		if idx < position_history.size():
			body_parts[i].position = position_history[idx]

# 边界检测
func check_boundary_collision():
	const WORLD_WIDTH = 2560
	const WORLD_HEIGHT = 1440
	const HEAD_RADIUS = 77.78
	
	var left_edge = position.x - HEAD_RADIUS
	var right_edge = position.x + HEAD_RADIUS
	var top_edge = position.y - HEAD_RADIUS
	var bottom_edge = position.y + HEAD_RADIUS

	if left_edge <= 0 or right_edge >= WORLD_WIDTH or top_edge <= 0 or bottom_edge >= WORLD_HEIGHT:
		trigger_game_over()

# 身体碰撞检测
func check_body_collision():
	const BODY_RADIUS = 20
	const SAFE_BODY_COUNT = 3
	
	if body_parts.size() <= SAFE_BODY_COUNT:
		return

	for i in range(SAFE_BODY_COUNT, body_parts.size()):
		var body = body_parts[i]
		if position.distance_to(body.position) < BODY_RADIUS * 1.8:
			trigger_game_over()
			return

# 游戏结束处理
func trigger_game_over():
	print("=== 触发游戏结束 ===")
	game_over = true
	direction = Vector2.ZERO
	print("游戏状态：结束")
	print("分数：", score)
	print("福瑞：", food_count)
	
	# 显示游戏结束面板
	var game_over_panel = get_node_or_null("../CanvasLayer/GameOverPanel")
	if game_over_panel:
		print("✅ 找到游戏结束面板")
		game_over_panel.visible = true
	else:
		print("❌ 错误：找不到游戏结束面板")
		# 尝试其他路径
		game_over_panel = get_node_or_null("../../CanvasLayer/GameOverPanel")
		if game_over_panel:
			print("✅ 通过其他路径找到游戏结束面板")
			game_over_panel.visible = true
	
	# 更新分数显示
	var score_final_label = get_node_or_null("../CanvasLayer/GameOverPanel/ScoreLabelFinal")
	if not score_final_label:
		score_final_label = get_node_or_null("../../CanvasLayer/GameOverPanel/ScoreLabelFinal")
	
	if score_final_label:
		print("✅ 找到最终分数标签")
		score_final_label.text = "最终得分：" + str(score)
	else:
		print("❌ 错误：找不到最终分数标签")
	
	# 更新福瑞显示
	var food_count_label = get_node_or_null("../CanvasLayer/GameOverPanel/FoodCountLabel")
	if not food_count_label:
		food_count_label = get_node_or_null("../../CanvasLayer/GameOverPanel/FoodCountLabel")
	
	if food_count_label:
		print("✅ 找到福瑞数量标签")
		food_count_label.text = "收集的福瑞：" + str(food_count)
	else:
		print("❌ 错误：找不到福瑞数量标签")
	
	print("=== 游戏结束处理完成 ===")

func _on_area_2d_body_entered(body):
	print("=== 蛇头碰撞检测开始 ===")
	
	# 安全地获取body信息
	if body:
		print("碰撞对象存在")
		print("对象名称:", body.name if body.has_method("get_name") else "无法获取名称")
		print("对象类型:", body.get_class() if body.has_method("get_class") else "未知类型")
		
		# 安全获取父节点
		var parent = body.get_parent() if body.has_method("get_parent") else null
		if parent:
			print("对象父节点:", parent.name if parent.has_method("get_name") else "无法获取父节点名称")
		else:
			print("对象父节点: 无")
	else:
		print("❌ 错误：碰撞对象为null")
		return
	
	# 检查所有可能的碰撞对象
	var body_name = body.name if body.has_method("get_name") else ""
	
	if body_name == "Boss":
		print("🐍 碰到年兽本体！游戏结束！")
		trigger_game_over()
	elif body_name == "Laser":
		print("🐍 碰到激光攻击！游戏结束！")
		trigger_game_over()
	elif body_name == "Wave":
		print("🐍 碰到冲击波攻击！游戏结束！")
		trigger_game_over()
	elif body_name == "Slam":
		print("🐍 碰到砸地攻击！游戏结束！")
		trigger_game_over()
	else:
		print("⚠️ 未知碰撞对象:", body_name, "，忽略")
	
	print("=== 蛇头碰撞检测结束 ===")
