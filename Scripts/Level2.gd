extends Node2D

func _ready():
	# 从全局数据管理器加载蛇数据
	var game_data = get_node("/root/GameDataManager")
	var head = $KunzhaHead
	if head and game_data.game_started:
		game_data.load_snake_data(head, self)
	else:
		# 如果没有数据，初始化新的蛇
		print("没有找到第一关的蛇数据，初始化新的蛇")
		head.position = Vector2(296.00003, 172.33336)
		head.direction = Vector2.ZERO
		head.score = 0
		head.food_count = 0
