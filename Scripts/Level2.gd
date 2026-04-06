extends Node2D

func _ready():
	print("第二关初始化...")
	
	# 安全获取节点
	var head = get_node_or_null("KunzhaHead")
	if not head:
		print("错误：找不到蛇头 KunzhaHead")
		return

	# 尝试从全局数据管理器加载蛇数据
	var game_data = get_node_or_null("/root/GameDataManager")
	if game_data and game_data.game_started:
		print("正在加载第一关的蛇数据...")
		var success = game_data.load_snake_data(head, self)
		if success:
			print("蛇数据加载成功")
			return
	
	# 如果没有数据或加载失败，使用默认位置
	print("使用默认蛇位置")
	head.position = Vector2(296.0, 172.0)
	head.direction = Vector2.ZERO
	head.score = 0
	head.food_count = 0
