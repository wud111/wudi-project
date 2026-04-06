extends Node

# 全局游戏数据管理器
# 注意：作为 Autoload 使用时，不需要 class_name
# 可以通过 get_node("/root/GameDataManager") 访问

# 蛇的数据
var snake_head_position: Vector2 = Vector2.ZERO
var snake_direction: Vector2 = Vector2.ZERO
var snake_body_positions: Array = []
var snake_body_textures: Array = []
var position_history: Array = []

# 游戏状态
var score: int = 0
var food_count: int = 0
var game_started: bool = false

# 保存第一关的蛇数据
func save_snake_data(head_node):
	snake_head_position = head_node.position
	snake_direction = head_node.direction
	score = head_node.score
	food_count = head_node.food_count
	game_started = true
	
	# 保存身体数据
	snake_body_positions.clear()
	snake_body_textures.clear()
	for body in head_node.body_parts:
		snake_body_positions.append(body.position)
		snake_body_textures.append(body.texture)
	
	# 保存位置历史
	position_history = head_node.position_history.duplicate()
	
	print("蛇数据已保存：")
	print("  位置：", snake_head_position)
	print("  方向：", snake_direction)
	print("  分数：", score)
	print("  身体数量：", snake_body_positions.size())

# 加载蛇数据到第二关
func load_snake_data(head_node, parent_node):
	if not game_started:
		print("错误：没有可加载的蛇数据")
		return false
	
	print("正在加载蛇数据到第二关...")
	
	head_node.position = snake_head_position
	head_node.direction = snake_direction
	head_node.score = score
	head_node.food_count = food_count
	# head_node.game_started = game_started  # KunzhaHead2.gd没有这个属性
	
	# 清空现有的身体
	for body in head_node.body_parts:
		body.queue_free()
	head_node.body_parts.clear()
	
	# 重新创建身体
	for i in range(snake_body_positions.size()):
		var body_texture = snake_body_textures[i]
		var body_position = snake_body_positions[i]
		
		var new_body = Sprite2D.new()
		new_body.texture = body_texture
		new_body.scale = Vector2(0.05, 0.05)
		new_body.position = body_position
		parent_node.add_child(new_body)
		head_node.body_parts.append(new_body)
	
	# 恢复位置历史
	head_node.position_history = position_history.duplicate()
	
	# 更新UI - 通过节点路径获取，因为KunzhaHead2.gd没有score_label属性
	var score_label = parent_node.get_node_or_null("CanvasLayer/Label")
	if score_label:
		score_label.text = "分数：" + str(score)
	
	print("蛇数据加载完成：")
	print("  位置：", head_node.position)
	print("  方向：", head_node.direction)
	print("  分数：", head_node.score)
	print("  身体数量：", head_node.body_parts.size())
	
	return true
