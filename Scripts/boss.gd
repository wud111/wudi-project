extends Area2D

@export var laser_speed = 360.0
@export var wave_max_scale = 10.0
@export var attack_interval = 4.5

var is_attacking = false

func _ready():
	$AttackTimer.wait_time = attack_interval
	$AttackTimer.timeout.connect(_on_attack)
	
	# 添加碰撞信号连接
	body_entered.connect(_on_body_entered)
	
	# 为所有攻击节点也添加碰撞信号连接
	for attack in $Attacks.get_children():
		attack.body_entered.connect(_on_attack_hit.bind(attack.name))

	for a in $Attacks.get_children():
		a.visible = false
		a.monitoring = false

# 攻击碰撞检测函数
func _on_attack_hit(body, attack_name):
	print("=== ", attack_name, "攻击碰撞检测开始 ===")
	
	if not body:
		print("❌ 错误：碰撞对象为null")
		return
	
	# 安全获取信息
	var body_name = body.name if body.has_method("get_name") else "未知"
	print(attack_name, "攻击碰撞检测到:", body_name)
	print("对象类型:", body.get_class() if body.has_method("get_class") else "未知")
	
	# 检查是否是蛇头的Area2D
	if body_name == "Area2D":
		# 检查父节点是否是蛇头
		var parent = body.get_parent() if body.has_method("get_parent") else null
		if parent:
			var parent_name = parent.name if parent.has_method("get_name") else "未知"
			print("父节点:", parent_name)
			
			if parent_name == "KunzhaHead":
				print("✅ ", attack_name, "攻击碰到蛇头！游戏结束")
				# 调用蛇头的游戏结束函数
				if parent.has_method("trigger_game_over"):
					parent.trigger_game_over()
				elif parent.has_method("set_game_over"):
					# 备用方案
					parent.game_over = true
					parent.direction = Vector2.ZERO
				else:
					print("⚠️ 蛇头没有游戏结束方法")
			else:
				print("⚠️ 父节点不是蛇头:", parent_name)
		else:
			print("⚠️ 没有父节点")
	else:
		print("⚠️ 不是Area2D对象:", body_name)
	
	print("=== ", attack_name, "攻击碰撞检测结束 ===")

# 碰撞检测函数
func _on_body_entered(body):
	print("=== 年兽碰撞检测开始 ===")
	
	if not body:
		print("❌ 错误：碰撞对象为null")
		return
	
	# 安全获取信息
	var body_name = body.name if body.has_method("get_name") else "未知"
	print("年兽碰撞检测到:", body_name)
	print("对象类型:", body.get_class() if body.has_method("get_class") else "未知")
	
	# 检查是否是蛇头的Area2D
	if body_name == "Area2D":
		# 检查父节点是否是蛇头
		var parent = body.get_parent() if body.has_method("get_parent") else null
		if parent:
			var parent_name = parent.name if parent.has_method("get_name") else "未知"
			print("父节点:", parent_name)
			
			if parent_name == "KunzhaHead":
				print("✅ 年兽碰到蛇头！游戏结束")
				# 调用蛇头的游戏结束函数
				if parent.has_method("trigger_game_over"):
					parent.trigger_game_over()
				elif parent.has_method("set_game_over"):
					# 备用方案
					parent.game_over = true
					parent.direction = Vector2.ZERO
				else:
					print("⚠️ 蛇头没有游戏结束方法")
			else:
				print("⚠️ 父节点不是蛇头:", parent_name)
		else:
			print("⚠️ 没有父节点")
	else:
		print("⚠️ 不是Area2D对象:", body_name)
	
	print("=== 年兽碰撞检测结束 ===")

func _on_attack():
	if is_attacking:
		return
	is_attacking = true

	var r = randi() % 3
	match r:
		0: play_laser()
		1: play_wave()
		2: play_slam()

func play_laser():
	$Anim.play("laser")
	var laser = $Attacks/Laser
	laser.visible = true
	laser.monitoring = true
	laser.position = Vector2(-1500, 0)

	while laser.position.x < 1500:
		laser.position.x += laser_speed * get_process_delta_time()
		await get_tree().physics_frame

	laser.visible = false
	laser.monitoring = false
	is_attacking = false

func play_wave():
	$Anim.play("wave")
	var wave = $Attacks/Wave
	wave.visible = true
	wave.monitoring = true
	wave.scale = Vector2(0.2, 0.2)

	while wave.scale.x < wave_max_scale:
		wave.scale += Vector2(0.3, 0.3)
		await get_tree().physics_frame

	wave.visible = false
	wave.monitoring = false
	is_attacking = false

func play_slam():
	$Anim.play("slam")
	var slam = $Attacks/Slam
	slam.visible = true
	slam.monitoring = true

	await get_tree().create_timer(0.8)

	slam.visible = false
	slam.monitoring = false
	is_attacking = false
