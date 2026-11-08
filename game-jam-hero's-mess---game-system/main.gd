extends Node3D

enum S { INTRO, ARRIVING, WAIT_TALK, OFFER, REPAIR, LEAVING, SHOP, ENDING, DONE }

const GOLD := Color("e8b93a")
const TOW_OFFSET := 5.4
const SPORTS_CAR_PRICE := 1500
const SAVE_PATH := "user://endings.cfg"
const ENDINGS := {
	"donate": {"title": "Ending: A Good Name", "text": "Your donation helped the city grow, and your garage grew with it. Doing good was good for business."},
	"keep": {"title": "Ending: Hero's Mess, Again", "text": "The villain wrecked the garage and took every dollar. All that is left is the mess."},
	"secret": {"title": "Secret Ending: Keys to the Kingdom", "text": "You beat the hero at his own game. The hammer did the talking, and the sports car is yours to keep."},
}
const ENDING_ORDER := ["donate", "keep", "secret"]
const ENDING_HINTS := {"donate": "Donate your money at the end", "keep": "Keep your money at the end", "secret": "Defend your sports car from the hero"}

const FIGHT_HERO_HP := 100.0
const FIGHT_PLAYER_HP := 100.0
const FIGHT_STRIKE := 9.0
const FIGHT_HERO_HIT := 14.0

const TOTAL_CUSTOMERS := 7
const TIMEOUT_PENALTY := 40
const MOVE_SPEED := 4.0
const MOUSE_SENS := 0.0025
const TOOLS := ["wrench", "hammer", "paint", "glass"]
const TOOL_LABELS := {"wrench": "Wrench", "hammer": "Hammer", "paint": "Paint", "glass": "Glass"}
const TOOL_COLORS := {"wrench": Color("9aa0aa"), "hammer": Color("8a5a2b"), "paint": Color("d94b4b"), "glass": Color("8fd3ff")}
const CAR_COLORS := [Color("e0533d"), Color("3d8be0"), Color("e0c13d"), Color("4fb36b"), Color("a05ad6"), Color("e0e0e0")]
const CUSTOMER_NAMES := ["Mina", "Old Bob", "Dex", "Lara", "Tomo", "Priya", "Sven", "Nia"]
const PART_DEFS := {
	"wheel_fl": {"tool": "wrench", "pos": Vector3(1.1, 0.35, 0.95)},
	"wheel_fr": {"tool": "wrench", "pos": Vector3(1.1, 0.35, -0.95)},
	"wheel_rl": {"tool": "wrench", "pos": Vector3(-1.1, 0.35, 0.95)},
	"wheel_rr": {"tool": "wrench", "pos": Vector3(-1.1, 0.35, -0.95)},
	"hood": {"tool": "hammer", "pos": Vector3(1.25, 0.95, 0)},
	"bumper": {"tool": "hammer", "pos": Vector3(-1.9, 0.5, 0)},
	"door": {"tool": "hammer", "pos": Vector3(-0.2, 0.75, 0.88)},
	"windshield": {"tool": "glass", "pos": Vector3(0.7, 1.2, 0)},
}
const PART_NAMES := {
	"wheel_fl": "Front-left wheel", "wheel_fr": "Front-right wheel",
	"wheel_rl": "Rear-left wheel", "wheel_rr": "Rear-right wheel",
	"hood": "Hood", "bumper": "Rear bumper", "door": "Door", "windshield": "Windshield",
}
const PART_COMPLAINTS := {
	"wheel_fl": "the front-left tyre is flat",
	"wheel_fr": "the front-right wheel is wobbling",
	"wheel_rl": "the rear-left wheel came loose",
	"wheel_rr": "the rear-right tyre is shredded",
	"hood": "the hood is badly dented",
	"bumper": "the rear bumper is hanging off",
	"door": "the door is dented in",
	"windshield": "the windshield is cracked",
}
const TUTORIAL_ORDER := ["wheel_fl", "hood", "door", "windshield"]
const TUTORIAL_TEXT := {
	"wheel_fl": "Step 1/4: Flat tyre. WHEELS need the WRENCH (press 1). Walk up to the front-left wheel, look at it and click.",
	"hood": "Step 2/4: Dented hood. Dents on the HOOD, DOOR and BUMPER need the HAMMER (press 2). Look at the hood and click.",
	"door": "Step 3/4: Dented door. The DOOR needs the HAMMER too (press 2). Walk round to the door and click.",
	"windshield": "Step 4/4: Cracked glass. The WINDSHIELD needs GLASS (press 4). Look at the windshield and click.",
}
const TOOL_TIERS := {
	"wrench": {"names": ["Wrench", "Hand Drill", "Impact Driver"], "cost": [90, 180]},
	"hammer": {"names": ["Hammer", "Sledgehammer", "Power Mallet"], "cost": [90, 180]},
	"paint": {"names": ["Paint Brush", "Roller", "Spray Gun"], "cost": [70, 150]},
	"glass": {"names": ["Glass Pane", "Glass Press", "Laser Fuser"], "cost": [80, 160]},
}
const PAINT_SHADES := [
	{"name": "Scarlet", "color": Color("d62d2d"), "family": "red"},
	{"name": "Crimson", "color": Color("8f1b2b"), "family": "red"},
	{"name": "Sky Blue", "color": Color("4aa3e8"), "family": "blue"},
	{"name": "Navy", "color": Color("1f3a7a"), "family": "blue"},
	{"name": "Lime", "color": Color("7ad23a"), "family": "green"},
	{"name": "Forest", "color": Color("2b6e3d"), "family": "green"},
	{"name": "Sunny Yellow", "color": Color("f2d338"), "family": "yellow"},
	{"name": "Amber", "color": Color("e69a22"), "family": "yellow"},
	{"name": "Lilac", "color": Color("b48ae8"), "family": "purple"},
	{"name": "Plum", "color": Color("6a2a8f"), "family": "purple"},
	{"name": "Pearl White", "color": Color("ecebe6"), "family": "white"},
	{"name": "Jet Black", "color": Color("1c1c22"), "family": "black"},
]
const FAMILY_NAMES := {"red": "red", "blue": "blue", "green": "green", "yellow": "yellow", "purple": "purple", "white": "white", "black": "black"}
const REPAINT_PAY := 90
const REPAINT_MATCH_BONUS := 60
const SKIN_TONES := [Color("e3b98f"), Color("c68642"), Color("8d5524"), Color("f1d4b8"), Color("a86b3c")]
const NPC_STYLES := ["cap", "beanie", "tophat", "hair", "bald", "headband"]
const UPGRADES := {
	"power": {"name": "Repair Machine (faster repairs)", "max": 3, "cost": [80, 160, 260]},
	"time": {"name": "Extra Time (+25% repair time)", "max": 3, "cost": [60, 120, 180]},
	"steady": {"name": "Steady Hands (smaller mistake fines)", "max": 2, "cost": [70, 140]},
	"sign": {"name": "Garage Sign (+20% pay)", "max": 3, "cost": [100, 200, 300]},
}

var state := S.INTRO
var money := 0
var visits := 0
var tutorial := false
var customer_look := {}
var car_color := Color.WHITE
var upgrades := {"power": 0, "time": 0, "steady": 0, "sign": 0}
var tool_tier := {"wrench": 0, "hammer": 0, "paint": 0, "glass": 0}
var paint_job := {}
var paint_picked := -1
var door_state_open := false
var seat_node: Node3D
var rush_visits: Array = []
var selected_tool := "wrench"
var last_summary := ""
var sports_offered := false
var unlocked := {}
var fight_on := false
var fight_ui: Control
var p_hp := 0.0
var h_hp := 0.0
var h_mode := "idle"
var h_timer := 0.0
var p_block := false
var strike_cd := 0.0
var p_bar: ProgressBar
var h_bar: ProgressBar
var fight_msg: Label
var block_btn: Button
var strike_btn: Button

var player: CharacterBody3D
var cam: Camera3D
var held_tool: Node3D
var pitch := 0.0
var control_on := false
var current_car: Node3D
var car_type := "sedan"
var machine: Node3D
var ui_layer: CanvasLayer
var cutscene: Cutscenes
var customer: Node3D
var parts := {}
var job := {}
var time_left := 0.0
var timer_on := false
var clock := 0.0

var money_label: Label
var timer_label: Label
var visit_label: Label
var hint_label: Label
var toast_label: Label
var prompt_label: Label
var crosshair: Label
var tool_bar: HBoxContainer
var top_panel: PanelContainer
var tool_slots := {}
var tow_beacon: OmniLight3D
var door_left: Node3D
var door_right: Node3D
var sign_node: Node3D
var dialog_tween: Tween
var dialog: PanelContainer
var dialog_box: VBoxContainer


func _ready() -> void:
	randomize()
	rush_visits = [randi_range(2, 4), randi_range(5, 7)]
	load_endings()
	build_world()
	build_ui()
	open_main_menu()


func load_endings() -> void:
	var cfg := ConfigFile.new()
	var ok := cfg.load(SAVE_PATH) == OK
	for k in ENDING_ORDER:
		unlocked[k] = ok and bool(cfg.get_value("endings", k, false))


func unlock_ending(key: String) -> void:
	unlocked[key] = true
	var cfg := ConfigFile.new()
	for k in ENDING_ORDER:
		cfg.set_value("endings", k, bool(unlocked.get(k, false)))
	cfg.save(SAVE_PATH)


func open_main_menu() -> void:
	top_panel.visible = false
	var buttons: Array = [{"text": "Start game", "cb": open_intro}]
	if unlocked.values().has(true):
		buttons.append({"text": "Start game (skip tutorial)", "cb": skip_tutorial})
	buttons.append({"text": "Endings", "cb": open_endings_menu})
	buttons.append({"text": "New game (reset all endings)", "cb": confirm_new_game})
	buttons.append({"text": "Quit", "cb": func(): get_tree().quit()})
	show_dialog("Hero's Mess",
		"Fix wrecked cars, earn money, and see how many endings you can find.\n\nEndings found: %d / %d" % [unlocked.values().count(true), ENDING_ORDER.size()],
		buttons)


func confirm_new_game() -> void:
	show_dialog("New game",
		"This resets every ending back to unknown, so you can unlock them all again. The skip-tutorial option will also be locked again.\n\nContinue?",
		[{"text": "Yes, reset everything", "cb": reset_progress},
		{"text": "Cancel", "cb": open_main_menu}])


func reset_progress() -> void:
	for k in ENDING_ORDER:
		unlocked[k] = false
	var cfg := ConfigFile.new()
	for k in ENDING_ORDER:
		cfg.set_value("endings", k, false)
	cfg.save(SAVE_PATH)
	open_intro()


func skip_tutorial() -> void:
	hide_dialog()
	top_panel.visible = true
	set_tools_visible(false)
	next_customer()


func open_intro() -> void:
	show_dialog("Hero's Mess",
		"The hero fought the villain... using YOUR car as a weapon. Now it's a wreck, and you can't afford a new one.\n\nTime to fix it yourself.\n\nWASD: walk    Mouse: look    1-4 or scroll: pick tool\nClick or E: use tool / talk    Esc: free the mouse",
		[{"text": "Start repairing", "cb": start_tutorial}])


func open_endings_menu() -> void:
	var buttons: Array = []
	for k in ENDING_ORDER:
		if unlocked.get(k, false):
			buttons.append({"text": "Watch: %s" % ENDINGS[k]["title"], "cb": func(): replay_ending(k)})
		else:
			buttons.append({"text": "??? - %s" % ENDING_HINTS[k], "cb": func(): pass, "disabled": true})
	buttons.append({"text": "Back", "cb": open_main_menu})
	show_dialog("Endings", "Endings you have reached can be watched again here.", buttons)


func replay_ending(key: String) -> void:
	state = S.DONE
	begin_cutscene()
	match key:
		"donate":
			await cutscene.play_donate()
		"keep":
			await cutscene.play_keep()
		"secret":
			await cutscene.play_secret_replay()
	show_dialog(ENDINGS[key]["title"], ENDINGS[key]["text"], [{"text": "Back to menu", "cb": restart}])


func _process(delta: float) -> void:
	clock += delta
	if fight_on:
		fight_tick(delta)
		return
	for n in parts:
		var p = parts[n]
		if p["broken"]:
			p["mat"].emission_energy_multiplier = 0.6 + 0.5 * sin(clock * 5.0)
	if timer_on and state == S.REPAIR and not dialog.visible:
		time_left -= delta
		timer_label.text = "Time: %d" % maxi(0, ceili(time_left))
		timer_label.modulate = Color(1, 0.4, 0.4) if time_left < 10.0 else Color.WHITE
		if time_left <= 0.0:
			fail_job()
	update_prompt()


func _physics_process(_delta: float) -> void:
	var dir := Vector3.ZERO
	if control_on and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
			dir.z -= 1
		if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
			dir.z += 1
		if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
			dir.x -= 1
		if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
			dir.x += 1
	var move := (player.global_transform.basis * dir).normalized() * MOVE_SPEED
	player.velocity = Vector3(move.x, -3.0, move.z)
	player.move_and_slide()


func _unhandled_input(event: InputEvent) -> void:
	if fight_on:
		if event is InputEventKey and not event.echo:
			if event.keycode == KEY_SPACE and event.pressed:
				fight_strike()
			elif event.keycode == KEY_SHIFT:
				p_block = event.pressed
		return
	if not control_on:
		return
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		return
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseButton and event.pressed:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		return
	if event is InputEventMouseMotion:
		player.rotate_y(-event.relative.x * MOUSE_SENS)
		pitch = clampf(pitch - event.relative.y * MOUSE_SENS, -1.4, 1.4)
		cam.rotation.x = pitch
	elif event is InputEventKey and event.pressed and not event.echo:
		var idx: int = event.keycode - KEY_1
		if idx >= 0 and idx < TOOLS.size():
			select_tool(TOOLS[idx])
		elif event.keycode == KEY_E:
			interact()
	elif event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			interact()
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			select_tool(TOOLS[(TOOLS.find(selected_tool) + TOOLS.size() - 1) % TOOLS.size()])
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			select_tool(TOOLS[(TOOLS.find(selected_tool) + 1) % TOOLS.size()])


func set_control(on: bool) -> void:
	control_on = on
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if on else Input.MOUSE_MODE_VISIBLE
	crosshair.visible = on
	if not on:
		prompt_label.text = ""


# ---------- world ----------

func mat(color: Color) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = 0.9
	return m


func add_mesh(parent: Node3D, mesh: Mesh, pos: Vector3, color: Color) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.material_override = mat(color)
	mi.position = pos
	parent.add_child(mi)
	return mi


func box(size: Vector3) -> BoxMesh:
	var b := BoxMesh.new()
	b.size = size
	return b


func add_solid(size: Vector3, pos: Vector3, color: Color, shown := true) -> void:
	if shown:
		add_mesh(self, box(size), pos, color)
	var body := StaticBody3D.new()
	body.position = pos
	var cs := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	cs.shape = shape
	body.add_child(cs)
	add_child(body)


func build_world() -> void:
	get_viewport().msaa_3d = Viewport.MSAA_4X
	var sky_mat := ProceduralSkyMaterial.new()
	sky_mat.sky_top_color = Color("1b2147")
	sky_mat.sky_horizon_color = Color("e08a6a")
	sky_mat.ground_horizon_color = Color("5a4a5e")
	sky_mat.ground_bottom_color = Color("2b2f44")
	sky_mat.sun_angle_max = 25.0
	var sky := Sky.new()
	sky.sky_material = sky_mat
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_energy = 0.9
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.tonemap_exposure = 1.05
	env.glow_enabled = true
	env.glow_intensity = 0.6
	env.glow_bloom = 0.08
	env.glow_hdr_threshold = 1.1
	env.adjustment_enabled = true
	env.adjustment_contrast = 1.08
	env.adjustment_saturation = 1.12
	var we := WorldEnvironment.new()
	we.environment = env
	add_child(we)

	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-50, -30, 0)
	sun.light_color = Color("fff0dc")
	sun.shadow_enabled = true
	sun.shadow_blur = 1.5
	sun.directional_shadow_mode = DirectionalLight3D.SHADOW_PARALLEL_2_SPLITS
	sun.directional_shadow_max_distance = 40.0
	add_child(sun)

	add_solid(Vector3(40, 0.2, 14), Vector3(0, -0.1, 0), Color("55586b"))
	var floor_m := add_mesh(self, box(Vector3(16, 0.02, 11)), Vector3(0, 0.01, 0.5), Color("8b8ea2"))
	var fm := floor_m.material_override as StandardMaterial3D
	fm.albedo_texture = GarageDecor.floor_texture()
	fm.uv1_triplanar = true
	fm.uv1_scale = Vector3(0.18, 0.18, 0.18)
	fm.roughness = 0.55
	fm.metallic_specular = 0.7
	add_solid(Vector3(16, 5, 0.3), Vector3(0, 2.5, -5.15), Color("7a6a8f"))
	add_solid(Vector3(16, 5, 0.3), Vector3(0, 2.5, 6.3), Color("7a6a8f"))
	add_solid(Vector3(1, 5, 14), Vector3(-8.5, 2.5, 0), Color.WHITE, false)
	add_solid(Vector3(1, 5, 14), Vector3(8.5, 2.5, 0), Color.WHITE, false)
	door_left = GarageDecor.build_side_wall(self, -8.0)
	door_right = GarageDecor.build_side_wall(self, 8.0)
	add_mesh(self, box(Vector3(5.0, 0.12, 2.8)), Vector3(0, 0.06, 0), Color("e8b93a"))
	add_mesh(self, box(Vector3(1.2, 1.4, 0.8)), Vector3(-5, 0.7, -4.6), Color("c0392b"))
	add_mesh(self, box(Vector3(1.0, 0.6, 0.8)), Vector3(-3.7, 0.3, -4.6), Color("2e86c1"))
	add_mesh(self, box(Vector3(2.4, 0.15, 0.6)), Vector3(4.5, 1.6, -4.7), Color("8a5a2b"))

	GarageDecor.build_roof(self)
	GarageDecor.build_walls_decor(self)
	GarageDecor.build_more_decor(self)
	GarageDecor.build_lounge(self)
	rebuild_machine()
	rebuild_sign()

	player = CharacterBody3D.new()
	var pcs := CollisionShape3D.new()
	var cap := CapsuleShape3D.new()
	cap.radius = 0.4
	cap.height = 1.8
	pcs.shape = cap
	pcs.position = Vector3(0, 0.9, 0)
	player.add_child(pcs)
	player.position = Vector3(0, 0, 4.5)
	add_child(player)

	cam = Camera3D.new()
	cam.position = Vector3(0, 1.6, 0)
	cam.current = true
	player.add_child(cam)

	held_tool = Node3D.new()
	held_tool.position = Vector3(0.3, -0.28, -0.55)
	held_tool.visible = false
	for tn in TOOLS:
		held_tool.add_child(build_tool_model(tn, 0))
	cam.add_child(held_tool)


func build_person(body: Color, skin: Color, s: float, villain: bool, hat := Color(0, 0, 0, 0)) -> Node3D:
	var p := Node3D.new()
	add_mesh(p, box(Vector3(0.28, 0.7, 0.3)), Vector3(-0.17, 0.35, 0), Color("2c2c3a"))
	add_mesh(p, box(Vector3(0.28, 0.7, 0.3)), Vector3(0.17, 0.35, 0), Color("2c2c3a"))
	add_mesh(p, box(Vector3(0.7, 0.8, 0.4)), Vector3(0, 1.1, 0), body)
	add_mesh(p, box(Vector3(0.22, 0.7, 0.25)), Vector3(-0.47, 1.1, 0), body)
	add_mesh(p, box(Vector3(0.22, 0.7, 0.25)), Vector3(0.47, 1.1, 0), body)
	add_mesh(p, box(Vector3(0.45, 0.45, 0.45)), Vector3(0, 1.75, 0), skin)
	for x in [-0.1, 0.1]:
		add_mesh(p, box(Vector3(0.07, 0.07, 0.04)), Vector3(x, 1.8, 0.23), Color("ff2020") if villain else Color("1a1a1a"))
	if villain:
		add_mesh(p, box(Vector3(0.9, 1.1, 0.1)), Vector3(0, 1.0, -0.28), Color("1a1020"))
		for x in [-0.12, 0.12]:
			var horn := CylinderMesh.new()
			horn.top_radius = 0.0
			horn.bottom_radius = 0.09
			horn.height = 0.35
			horn.radial_segments = 5
			add_mesh(p, horn, Vector3(x * 1.8, 2.1, 0), Color("d8d0c0"))
	elif hat.a > 0.0:
		add_mesh(p, box(Vector3(0.5, 0.12, 0.5)), Vector3(0, 2.0, 0), hat)
		add_mesh(p, box(Vector3(0.75, 0.14, 0.42)), Vector3(0, 1.55, 0), hat)
	p.scale = Vector3.ONE * s
	return p


func build_npc(look: Dictionary) -> Node3D:
	var body: Color = look["body"]
	var p := build_person(body, look["skin"], look["scale"], false)
	var hat: Color = look["hat"]
	var hair: Color = look["hair"]
	match look["style"]:
		"cap":
			add_mesh(p, box(Vector3(0.5, 0.14, 0.5)), Vector3(0, 2.0, 0), hat)
			add_mesh(p, box(Vector3(0.4, 0.05, 0.3)), Vector3(0, 1.97, 0.35), hat)
		"beanie":
			add_mesh(p, box(Vector3(0.5, 0.2, 0.5)), Vector3(0, 2.02, 0), hat)
			add_mesh(p, box(Vector3(0.12, 0.12, 0.12)), Vector3(0, 2.18, 0), hat.lightened(0.3))
		"tophat":
			add_mesh(p, box(Vector3(0.75, 0.06, 0.75)), Vector3(0, 1.99, 0), hat)
			add_mesh(p, box(Vector3(0.42, 0.45, 0.42)), Vector3(0, 2.2, 0), hat)
			add_mesh(p, box(Vector3(0.44, 0.08, 0.44)), Vector3(0, 2.07, 0), Color("d94b4b"))
		"hair":
			add_mesh(p, box(Vector3(0.5, 0.16, 0.5)), Vector3(0, 2.0, 0), hair)
			add_mesh(p, box(Vector3(0.5, 0.5, 0.12)), Vector3(0, 1.8, -0.24), hair)
			add_mesh(p, box(Vector3(0.1, 0.4, 0.4)), Vector3(-0.27, 1.82, 0), hair)
			add_mesh(p, box(Vector3(0.1, 0.4, 0.4)), Vector3(0.27, 1.82, 0), hair)
		"headband":
			add_mesh(p, box(Vector3(0.5, 0.1, 0.5)), Vector3(0, 1.93, 0), hat)
			add_mesh(p, box(Vector3(0.48, 0.1, 0.48)), Vector3(0, 2.04, 0), hair)
		"bald":
			add_mesh(p, box(Vector3(0.1, 0.14, 0.4)), Vector3(-0.27, 1.8, 0), hair)
			add_mesh(p, box(Vector3(0.1, 0.14, 0.4)), Vector3(0.27, 1.8, 0), hair)
	if look["glasses"]:
		add_mesh(p, box(Vector3(0.36, 0.08, 0.04)), Vector3(0, 1.82, 0.25), Color("22232b"))
	match look["extra"]:
		"scarf":
			add_mesh(p, box(Vector3(0.5, 0.16, 0.46)), Vector3(0, 1.5, 0), hat)
		"backpack":
			add_mesh(p, box(Vector3(0.5, 0.6, 0.22)), Vector3(0, 1.15, -0.3), hat.darkened(0.2))
		"tie":
			add_mesh(p, box(Vector3(0.1, 0.5, 0.04)), Vector3(0, 1.15, 0.22), Color("d94b4b"))
		"apron":
			add_mesh(p, box(Vector3(0.55, 0.7, 0.05)), Vector3(0, 0.95, 0.22), Color("f4f4f4"))
	return p


func random_npc_look() -> Dictionary:
	var hat: Color = CAR_COLORS[randi() % CAR_COLORS.size()]
	var pref: Dictionary = PAINT_SHADES[randi() % PAINT_SHADES.size()]
	return {
		"body": CAR_COLORS[randi() % CAR_COLORS.size()].darkened(0.2),
		"skin": SKIN_TONES[randi() % SKIN_TONES.size()],
		"hat": hat,
		"hair": [Color("2b1d14"), Color("6b3a1f"), Color("c9a24a"), Color("a33b2b"), Color("3a3a42"), Color("e8e8ec")][randi() % 6],
		"style": NPC_STYLES[randi() % NPC_STYLES.size()],
		"glasses": randf() < 0.35,
		"extra": ["none", "scarf", "backpack", "tie", "apron"][randi() % 5],
		"scale": randf_range(0.88, 1.12),
		"pref": pref,
	}


func cyl_mesh(r: float, h: float, segs := 12) -> CylinderMesh:
	var c := CylinderMesh.new()
	c.top_radius = r
	c.bottom_radius = r
	c.height = h
	c.radial_segments = segs
	return c


func build_tool_model(tool_name: String, tier := 0) -> Node3D:
	if tier == 0:
		return build_tool_base(tool_name)
	var n := Node3D.new()
	n.name = tool_name
	var steel := Color("aeb4bf")
	var dark := Color("2b2f44")
	match tool_name:
		"wrench":
			var body_col := Color("e8b93a") if tier == 1 else Color("2e86c1")
			add_mesh(n, box(Vector3(0.07, 0.1, 0.2)), Vector3(0, 0, 0.08), body_col)
			add_mesh(n, box(Vector3(0.06, 0.16, 0.07)), Vector3(0, -0.11, 0.12), dark)
			var barrel := add_mesh(n, cyl_mesh(0.035 if tier == 1 else 0.05, 0.16), Vector3(0, 0.01, -0.1), steel)
			barrel.rotation_degrees = Vector3(90, 0, 0)
			var tip := add_mesh(n, cyl_mesh(0.012 if tier == 1 else 0.03, 0.12), Vector3(0, 0.01, -0.24), Color("6c717c"))
			tip.rotation_degrees = Vector3(90, 0, 0)
			if tier == 2:
				add_mesh(n, box(Vector3(0.09, 0.03, 0.12)), Vector3(0, 0.07, 0.0), Color("ff8a1a"))
		"hammer":
			var handle_len := 0.55 if tier == 1 else 0.4
			add_mesh(n, box(Vector3(0.05, 0.05, handle_len)), Vector3(0, 0, 0.1), Color("5a3a1b") if tier == 1 else dark)
			if tier == 1:
				add_mesh(n, box(Vector3(0.14, 0.13, 0.13)), Vector3(0, 0, -0.2), Color("6c717c"))
			else:
				add_mesh(n, box(Vector3(0.18, 0.16, 0.16)), Vector3(0, 0, -0.2), Color("c9a227"))
				add_mesh(n, box(Vector3(0.2, 0.04, 0.18)), Vector3(0, 0, -0.2), Color("ff8a1a"))
				add_mesh(n, box(Vector3(0.06, 0.2, 0.06)), Vector3(0, -0.12, 0.0), steel)
		"paint":
			if tier == 1:
				add_mesh(n, box(Vector3(0.03, 0.03, 0.28)), Vector3(0, 0.04, 0.12), steel)
				var roller := add_mesh(n, cyl_mesh(0.045, 0.2), Vector3(0, 0.04, -0.08), TOOL_COLORS["paint"])
				roller.rotation_degrees = Vector3(0, 0, 90)
			else:
				add_mesh(n, box(Vector3(0.07, 0.17, 0.1)), Vector3(0, -0.02, 0.12), Color("e8b93a"))
				var nozzle := add_mesh(n, cyl_mesh(0.03, 0.2), Vector3(0, 0.04, -0.06), steel)
				nozzle.rotation_degrees = Vector3(90, 0, 0)
				add_mesh(n, cyl_mesh(0.05, 0.1), Vector3(0, 0.12, 0.04), TOOL_COLORS["paint"])
		"glass":
			var pad := add_mesh(n, box(Vector3(0.3, 0.06, 0.2)), Vector3(0, 0, -0.1), Color("3a3f4d"))
			add_mesh(pad, box(Vector3(0.26, 0.02, 0.16)), Vector3(0, -0.035, 0), TOOL_COLORS["glass"])
			add_mesh(n, box(Vector3(0.04, 0.04, 0.3)), Vector3(0, 0.04, 0.12), steel)
			if tier == 2:
				add_mesh(n, box(Vector3(0.28, 0.01, 0.02)), Vector3(0, -0.07, -0.1), Color("6bffea"))
				add_mesh(n, box(Vector3(0.08, 0.1, 0.08)), Vector3(0, 0.06, -0.1), Color("22d6c0"))
	return n


func build_tool_base(tool_name: String) -> Node3D:
	var n := Node3D.new()
	n.name = tool_name
	var steel := Color("aeb4bf")
	match tool_name:
		"wrench":
			add_mesh(n, box(Vector3(0.05, 0.025, 0.36)), Vector3(0, 0, 0.04), steel)
			add_mesh(n, cyl_mesh(0.045, 0.025), Vector3(0, 0, 0.23), steel)
			add_mesh(n, box(Vector3(0.15, 0.025, 0.05)), Vector3(0, 0, -0.16), steel)
			add_mesh(n, box(Vector3(0.04, 0.025, 0.1)), Vector3(-0.055, 0, -0.21), steel)
			add_mesh(n, box(Vector3(0.04, 0.025, 0.1)), Vector3(0.055, 0, -0.21), steel)
		"hammer":
			add_mesh(n, box(Vector3(0.04, 0.04, 0.42)), Vector3(0, 0, 0.05), Color("8a5a2b"))
			add_mesh(n, box(Vector3(0.2, 0.075, 0.075)), Vector3(0, 0, -0.17), Color("6c717c"))
			add_mesh(n, box(Vector3(0.05, 0.1, 0.1)), Vector3(0.11, 0, -0.17), Color("8b909c"))
		"paint":
			add_mesh(n, box(Vector3(0.035, 0.035, 0.3)), Vector3(0, 0, 0.1), Color("c9a06a"))
			add_mesh(n, box(Vector3(0.06, 0.05, 0.08)), Vector3(0, 0, -0.08), steel)
			add_mesh(n, box(Vector3(0.075, 0.03, 0.1)), Vector3(0, 0, -0.17), TOOL_COLORS["paint"])
		"glass":
			var pane := MeshInstance3D.new()
			pane.mesh = box(Vector3(0.26, 0.32, 0.012))
			var gm := mat(TOOL_COLORS["glass"])
			gm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			gm.albedo_color.a = 0.55
			pane.material_override = gm
			pane.position = Vector3(0, 0.02, -0.12)
			n.add_child(pane)
			var grip := add_mesh(n, cyl_mesh(0.025, 0.12), Vector3(0, 0.02, -0.04), steel)
			grip.rotation_degrees = Vector3(90, 0, 0)
			var cup := add_mesh(n, cyl_mesh(0.05, 0.015), Vector3(0, 0.02, -0.108), Color("2b2f44"))
			cup.rotation_degrees = Vector3(90, 0, 0)
	return n


func build_tow_truck() -> Node3D:
	var t := Node3D.new()
	add_mesh(t, box(Vector3(3.6, 0.3, 1.7)), Vector3(0, 0.55, 0), Color("2f3340"))
	add_mesh(t, box(Vector3(1.3, 1.0, 1.7)), Vector3(1.05, 1.2, 0), GOLD)
	add_mesh(t, box(Vector3(0.06, 0.5, 1.5)), Vector3(1.72, 1.35, 0), Color("9fd8ff"))
	for z in [-0.86, 0.86]:
		add_mesh(t, box(Vector3(0.7, 0.4, 0.04)), Vector3(1.0, 1.4, z), Color("9fd8ff"))
	add_mesh(t, box(Vector3(2.1, 0.12, 1.75)), Vector3(-0.85, 0.78, 0), Color("55586b"))
	add_mesh(t, box(Vector3(0.18, 1.2, 0.18)), Vector3(-0.3, 1.45, 0), Color("c0392b"))
	add_mesh(t, box(Vector3(2.8, 0.14, 0.14)), Vector3(-1.7, 2.05, 0), Color("c0392b"))
	add_mesh(t, cyl_mesh(0.015, 0.9, 6), Vector3(-3.0, 1.6, 0), Color("1a1a1a"))
	add_mesh(t, box(Vector3(0.1, 0.1, 0.1)), Vector3(-3.0, 1.1, 0), Color("aeb4bf"))
	for z in [-0.4, 0.4]:
		add_mesh(t, box(Vector3(1.6, 0.07, 0.07)), Vector3(-2.5, 0.65, z), Color("aeb4bf"))
	for x in [1.1, -1.2]:
		for z in [-0.9, 0.9]:
			var w := add_mesh(t, cyl_mesh(0.42, 0.3, 14), Vector3(x, 0.42, z), Color("1f1f26"))
			w.rotation_degrees = Vector3(90, 0, 0)
	add_mesh(t, box(Vector3(0.25, 0.12, 0.25)), Vector3(1.0, 1.76, 0), Color("ff8a1a"))
	tow_beacon = OmniLight3D.new()
	tow_beacon.position = Vector3(1.0, 2.1, 0)
	tow_beacon.light_color = Color("ff8a1a")
	tow_beacon.omni_range = 5.0
	t.add_child(tow_beacon)
	return t


func make_part(root: Node3D, pname: String, def: Dictionary, car_color: Color) -> void:
	var mi := MeshInstance3D.new()
	var good := car_color
	var rot := Vector3.ZERO
	if pname.begins_with("wheel"):
		var c := CylinderMesh.new()
		c.top_radius = def["radius"]
		c.bottom_radius = def["radius"]
		c.height = 0.36
		c.radial_segments = 16
		mi.mesh = c
		good = Color("1f1f26")
		rot = Vector3(90, 0, 0)
	else:
		mi.mesh = box(def["size"])
		if pname == "bumper":
			good = Color("b0b4bd")
		elif pname == "windshield":
			good = Color("9fd8ff")
			rot = Vector3(0, 0, def["tilt"])
	var m := StandardMaterial3D.new()
	m.albedo_color = good
	m.roughness = 0.7
	m.emission_enabled = false
	m.emission = Color("ff7a1a")
	mi.material_override = m
	mi.position = def["pos"]
	mi.rotation_degrees = rot
	root.add_child(mi)

	var body := StaticBody3D.new()
	body.set_meta("part", pname)
	var cs := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = (mi.mesh.get_aabb().size * 1.15).max(Vector3(0.22, 0.22, 0.22))
	cs.shape = shape
	body.add_child(cs)
	mi.add_child(body)

	parts[pname] = {
		"mi": mi, "mat": m, "tool": def["tool"], "good": good,
		"base_pos": mi.position, "base_rot": rot, "broken": false, "hits": 0,
	}


func spawn_car(broken_names: Array, hits: int, type := "") -> void:
	# coroutine: returns once the tow truck has dropped the car off
	parts.clear()
	if type == "":
		type = CarBuilder.TYPES[randi() % CarBuilder.TYPES.size()]
	car_type = type
	var root := Node3D.new()
	var color: Color = CAR_COLORS[randi() % CAR_COLORS.size()]
	car_color = color
	var size := CarBuilder.build_body(root, type, color)
	var car_body := StaticBody3D.new()
	var ccs := CollisionShape3D.new()
	var cshape := BoxShape3D.new()
	cshape.size = size
	ccs.shape = cshape
	ccs.position = Vector3(-0.1, size.y * 0.5 + 0.3, 0)
	car_body.add_child(ccs)
	root.add_child(car_body)
	var defs := CarBuilder.part_defs(type)
	for pname in defs:
		make_part(root, pname, defs[pname], color)
	for pname in broken_names:
		var p = parts[pname]
		p["broken"] = true
		p["hits"] = hits
		p["mat"].albedo_color = Color("3a2a2a")
		p["mat"].emission_enabled = true
		p["mi"].position = p["base_pos"] + Vector3(0, -0.05, 0)
		p["mi"].rotation_degrees = p["base_rot"] + Vector3(0, 0, 12)
	root.position = Vector3(-20, 0.12, 0)
	add_child(root)
	current_car = root
	var truck := build_tow_truck()
	truck.position = Vector3(-20 + TOW_OFFSET, 0.12, 0)
	add_child(truck)
	await set_doors(true)
	var t := create_tween().set_parallel(true)
	t.tween_property(root, "position:x", 0.0, 2.8).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	t.tween_property(truck, "position:x", TOW_OFFSET, 2.8).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	await t.finished
	var t2 := create_tween()
	t2.tween_interval(0.3)
	t2.tween_property(truck, "position:x", 26.0, 2.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	await t2.finished
	truck.queue_free()


func spawn_customer() -> void:
	customer_look = random_npc_look()
	customer = build_npc(customer_look)
	customer.position = Vector3(-16, 0, 2.4)
	customer.rotation_degrees.y = 90
	var sb := StaticBody3D.new()
	sb.set_meta("npc", true)
	var cs := CollisionShape3D.new()
	var shape := CapsuleShape3D.new()
	shape.radius = 0.5
	shape.height = 2.1
	cs.shape = shape
	cs.position = Vector3(0, 1.05, 0)
	sb.add_child(cs)
	customer.add_child(sb)
	add_child(customer)
	var t := create_tween()
	t.tween_property(customer, "position:x", -3.2, 2.2)
	t.tween_property(customer, "rotation_degrees:y", 0.0, 0.3)
	t.tween_callback(customer_arrived)


func customer_arrived() -> void:
	if state != S.ARRIVING:
		return
	set_doors(false)
	state = S.WAIT_TALK
	hint_label.text = "A customer arrived. Walk up to them and press E to talk."


func leave_car() -> void:
	var c := current_car
	var n := customer
	current_car = null
	customer = null
	parts.clear()
	state = S.LEAVING
	if c == null:
		return
	if n:
		var walk := create_tween()
		walk.tween_property(n, "position", Vector3(c.position.x - 0.1, 0.0, 1.6), 1.6)
		walk.tween_property(n, "rotation_degrees:y", 180.0, 0.25)
		await walk.finished
		var enter := create_tween().set_parallel(true)
		enter.tween_property(n, "position", Vector3(c.position.x - 0.1, 0.5, 0.3), 0.45)
		enter.tween_property(n, "scale", Vector3.ONE * 0.05, 0.45)
		await enter.finished
		n.queue_free()
		await set_doors(true)
		var dip := create_tween()
		dip.tween_property(c, "position:y", 0.06, 0.08)
		dip.tween_property(c, "position:y", 0.12, 0.12)
		dip.tween_property(c, "rotation_degrees:z", 1.5, 0.05)
		dip.tween_property(c, "rotation_degrees:z", -1.5, 0.1)
		dip.tween_property(c, "rotation_degrees:z", 0.0, 0.05)
		await dip.finished
	var drive := create_tween()
	drive.tween_property(c, "position:x", 16.0, 1.8).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	await drive.finished
	c.queue_free()
	await set_doors(false)


# ---------- UI ----------

func make_label(size: int, align := HORIZONTAL_ALIGNMENT_LEFT) -> Label:
	var l := Label.new()
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_outline_color", Color.BLACK)
	l.add_theme_constant_override("outline_size", 6)
	l.horizontal_alignment = align
	return l


func panel_style(bg: Color, border: Color, border_w: int, radius: int) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.border_color = border
	sb.set_border_width_all(border_w)
	sb.set_corner_radius_all(radius)
	sb.content_margin_left = 12
	sb.content_margin_right = 12
	sb.content_margin_top = 6
	sb.content_margin_bottom = 6
	sb.shadow_color = Color(0, 0, 0, 0.5)
	sb.shadow_size = 8
	return sb


func style_button(btn: Button) -> void:
	var base := Color("2b2f44")
	for st in ["normal", "hover", "pressed", "disabled"]:
		var c := base
		var border := GOLD
		match st:
			"hover":
				c = Color("3d4366")
			"pressed":
				c = GOLD.darkened(0.3)
			"disabled":
				c = Color("1c1e2b")
				border = Color("444a5e")
		var sb := panel_style(c, border, 2, 10)
		sb.content_margin_top = 10
		sb.content_margin_bottom = 10
		sb.shadow_size = 0
		btn.add_theme_stylebox_override(st, sb)
	btn.add_theme_color_override("font_color", Color.WHITE)
	btn.add_theme_color_override("font_hover_color", GOLD)
	btn.add_theme_color_override("font_disabled_color", Color("6c7186"))


func build_ui() -> void:
	var ui := CanvasLayer.new()
	ui_layer = ui
	add_child(ui)

	top_panel = PanelContainer.new()
	top_panel.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top_panel.offset_left = 16
	top_panel.offset_right = -16
	top_panel.offset_top = 10
	top_panel.add_theme_stylebox_override("panel", panel_style(Color(0.08, 0.09, 0.15, 0.8), GOLD, 2, 12))
	ui.add_child(top_panel)
	var top := HBoxContainer.new()
	top_panel.add_child(top)
	money_label = make_label(28)
	money_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	timer_label = make_label(28, HORIZONTAL_ALIGNMENT_CENTER)
	timer_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	visit_label = make_label(28, HORIZONTAL_ALIGNMENT_RIGHT)
	visit_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(money_label)
	top.add_child(timer_label)
	top.add_child(visit_label)

	hint_label = make_label(22, HORIZONTAL_ALIGNMENT_CENTER)
	hint_label.set_anchors_preset(Control.PRESET_TOP_WIDE)
	hint_label.offset_left = 160
	hint_label.offset_right = -160
	hint_label.offset_top = 80
	hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	ui.add_child(hint_label)

	toast_label = make_label(30, HORIZONTAL_ALIGNMENT_CENTER)
	toast_label.set_anchors_preset(Control.PRESET_TOP_WIDE)
	toast_label.offset_top = 170
	ui.add_child(toast_label)

	crosshair = make_label(32, HORIZONTAL_ALIGNMENT_CENTER)
	crosshair.text = "+"
	crosshair.set_anchors_preset(Control.PRESET_CENTER)
	crosshair.grow_horizontal = Control.GROW_DIRECTION_BOTH
	crosshair.grow_vertical = Control.GROW_DIRECTION_BOTH
	crosshair.visible = false
	ui.add_child(crosshair)

	prompt_label = make_label(24, HORIZONTAL_ALIGNMENT_CENTER)
	prompt_label.set_anchors_preset(Control.PRESET_CENTER)
	prompt_label.grow_horizontal = Control.GROW_DIRECTION_BOTH
	prompt_label.offset_top = 40
	ui.add_child(prompt_label)

	tool_bar = HBoxContainer.new()
	tool_bar.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	tool_bar.grow_horizontal = Control.GROW_DIRECTION_BOTH
	tool_bar.grow_vertical = Control.GROW_DIRECTION_BEGIN
	tool_bar.offset_bottom = -20
	tool_bar.add_theme_constant_override("separation", 10)
	tool_bar.visible = false
	ui.add_child(tool_bar)
	for i in TOOLS.size():
		var slot := PanelContainer.new()
		slot.custom_minimum_size = Vector2(150, 70)
		var sv := VBoxContainer.new()
		sv.alignment = BoxContainer.ALIGNMENT_CENTER
		slot.add_child(sv)
		var swatch := ColorRect.new()
		swatch.color = TOOL_COLORS[TOOLS[i]]
		swatch.custom_minimum_size = Vector2(0, 8)
		sv.add_child(swatch)
		var sl := Label.new()
		sl.text = "%d  %s" % [i + 1, TOOL_LABELS[TOOLS[i]]]
		slot.set_meta("label", sl)
		sl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		sl.add_theme_font_size_override("font_size", 20)
		sv.add_child(sl)
		tool_bar.add_child(slot)
		tool_slots[TOOLS[i]] = slot

	dialog = PanelContainer.new()
	dialog.set_anchors_preset(Control.PRESET_CENTER)
	dialog.grow_horizontal = Control.GROW_DIRECTION_BOTH
	dialog.grow_vertical = Control.GROW_DIRECTION_BOTH
	dialog.custom_minimum_size = Vector2(620, 0)
	dialog.add_theme_stylebox_override("panel", panel_style(Color(0.1, 0.11, 0.18, 0.95), GOLD, 3, 16))
	var margin := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 26)
	dialog.add_child(margin)
	dialog_box = VBoxContainer.new()
	dialog_box.add_theme_constant_override("separation", 12)
	margin.add_child(dialog_box)
	ui.add_child(dialog)
	dialog.visible = false
	refresh_tools()
	update_hud()


func show_dialog(title: String, body: String, buttons: Array) -> void:
	for c in dialog_box.get_children():
		dialog_box.remove_child(c)
		c.queue_free()
	var t := Label.new()
	t.text = title.to_upper()
	t.add_theme_font_size_override("font_size", 32)
	t.add_theme_color_override("font_color", GOLD)
	t.add_theme_color_override("font_outline_color", Color("2b2f44"))
	t.add_theme_constant_override("outline_size", 6)
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	dialog_box.add_child(t)
	var line := ColorRect.new()
	line.color = GOLD
	line.custom_minimum_size = Vector2(0, 3)
	dialog_box.add_child(line)
	var b := Label.new()
	b.text = body
	b.add_theme_font_size_override("font_size", 20)
	b.add_theme_color_override("font_color", Color("e6e8f2"))
	b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	dialog_box.add_child(b)
	for spec in buttons:
		var btn := Button.new()
		btn.text = spec["text"]
		btn.add_theme_font_size_override("font_size", 20)
		btn.disabled = spec.get("disabled", false)
		btn.pressed.connect(spec["cb"])
		style_button(btn)
		dialog_box.add_child(btn)
	dialog.visible = true
	set_control(false)
	dialog.pivot_offset = dialog.size / 2.0
	dialog.modulate.a = 0.0
	dialog.scale = Vector2(0.92, 0.92)
	if dialog_tween:
		dialog_tween.kill()
	dialog_tween = create_tween().set_parallel(true)
	dialog_tween.tween_property(dialog, "modulate:a", 1.0, 0.18)
	dialog_tween.tween_property(dialog, "scale", Vector2.ONE, 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func hide_dialog() -> void:
	dialog.visible = false
	set_control(true)


func toast(msg: String, color := Color.WHITE) -> void:
	toast_label.text = msg
	toast_label.modulate = color
	var t := create_tween()
	t.tween_interval(1.4)
	t.tween_property(toast_label, "modulate:a", 0.0, 0.5)


func update_hud() -> void:
	money_label.text = "Money: $%d" % money
	if tutorial:
		visit_label.text = "Tutorial"
	else:
		visit_label.text = "Customer %d/%d" % [visits, TOTAL_CUSTOMERS]
	if not timer_on:
		timer_label.text = ""


func rebuild_held_tool(tn: String) -> void:
	var old := held_tool.get_node_or_null(tn)
	if old:
		held_tool.remove_child(old)
		old.queue_free()
	var m := build_tool_model(tn, int(tool_tier[tn]))
	held_tool.add_child(m)
	m.visible = tn == selected_tool


func tool_name_of(tn: String) -> String:
	return TOOL_TIERS[tn]["names"][tool_tier[tn]]


func refresh_tools() -> void:
	for tn in TOOLS:
		var sel: bool = tn == selected_tool
		var slot: PanelContainer = tool_slots[tn]
		(slot.get_meta("label") as Label).text = "%d  %s" % [TOOLS.find(tn) + 1, tool_name_of(tn)]
		var border: Color = GOLD if sel else Color("444a5e")
		var bg := Color(0.2, 0.2, 0.3, 0.95) if sel else Color(0.08, 0.09, 0.15, 0.75)
		slot.add_theme_stylebox_override("panel", panel_style(bg, border, 4 if sel else 2, 10))
		slot.modulate = Color.WHITE if sel else Color(1, 1, 1, 0.7)
		held_tool.get_node(tn).visible = sel


func set_tools_visible(v: bool) -> void:
	tool_bar.visible = v
	held_tool.visible = v


# ---------- gameplay ----------

func aim() -> Object:
	var from := cam.global_position
	var to := from + (-cam.global_transform.basis.z) * 3.2
	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [player.get_rid()]
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		return null
	return hit["collider"]


func update_prompt() -> void:
	if not control_on:
		return
	var text := ""
	var c: Object = aim()
	if c:
		if c.has_meta("npc") and state == S.WAIT_TALK:
			text = "[E] Talk to the customer"
		elif c.has_meta("npc") and state == S.REPAIR and not tutorial:
			text = "[E] Ask the customer about the repairs"
		elif c.has_meta("part") and state == S.REPAIR and parts.has(c.get_meta("part")):
			var pname: String = c.get_meta("part")
			text = PART_NAMES[pname]
			if tutorial:
				text += "  (needs the %s)" % tool_name_of(parts[pname]["tool"])
	prompt_label.text = text


func interact() -> void:
	var c: Object = aim()
	if c == null:
		return
	if c.has_meta("npc") and state == S.WAIT_TALK:
		open_offer()
	elif c.has_meta("npc") and state == S.REPAIR and not tutorial:
		open_checklist()
	elif c.has_meta("part") and state == S.REPAIR and parts.has(c.get_meta("part")):
		swing()
		click_part(c.get_meta("part"))


func swing() -> void:
	var t := create_tween()
	t.tween_property(held_tool, "rotation_degrees:x", -45.0, 0.07)
	t.tween_property(held_tool, "rotation_degrees:x", 0.0, 0.1)


func select_tool(tool_name: String) -> void:
	selected_tool = tool_name
	refresh_tools()


func mistake_penalty() -> int:
	return [20, 12, 6][upgrades["steady"]]


func mistake(msg: String) -> void:
	if tutorial:
		toast(msg + " (no fine in the tutorial)", Color("ffd27a"))
	else:
		var fine := mistake_penalty()
		money = maxi(0, money - fine)
		toast("%s  -$%d" % [msg, fine], Color("ff6060"))
		update_hud()
	if current_car:
		var t := create_tween()
		t.tween_property(current_car, "rotation_degrees:y", 3.0, 0.05)
		t.tween_property(current_car, "rotation_degrees:y", -3.0, 0.1)
		t.tween_property(current_car, "rotation_degrees:y", 0.0, 0.05)


func click_part(pname: String) -> void:
	var p = parts[pname]
	if not p["broken"]:
		mistake("That part is fine!")
		return
	if p["tool"] != selected_tool:
		mistake("Wrong tool! That needs the %s." % tool_name_of(p["tool"]))
		return
	p["hits"] -= 1 + int(tool_tier[selected_tool])
	var mi: MeshInstance3D = p["mi"]
	var t := create_tween()
	t.tween_property(mi, "scale", Vector3.ONE * 1.2, 0.06)
	t.tween_property(mi, "scale", Vector3.ONE, 0.08)
	if p["hits"] > 0:
		toast("Keep going... (%d more)" % p["hits"])
		return
	p["broken"] = false
	p["mat"].albedo_color = p["good"]
	p["mat"].emission_enabled = false
	mi.position = p["base_pos"]
	mi.rotation_degrees = p["base_rot"]
	toast("Fixed!", Color("7dff9a"))
	for n in parts:
		if parts[n]["broken"]:
			if tutorial:
				update_tutorial_hint()
			return
	finish_job()


func update_tutorial_hint() -> void:
	for n in TUTORIAL_ORDER:
		if parts.has(n) and parts[n]["broken"]:
			hint_label.text = TUTORIAL_TEXT[n]
			return


func start_tutorial() -> void:
	tutorial = true
	state = S.REPAIR
	top_panel.visible = true
	hide_dialog()
	set_tools_visible(true)
	spawn_car(TUTORIAL_ORDER, 2)
	update_tutorial_hint()
	update_hud()


func next_customer() -> void:
	hide_dialog()
	hint_label.text = ""
	visits += 1
	var n := mini(visits + 1, PART_DEFS.size())
	var names: Array = PART_DEFS.keys()
	names.shuffle()
	var rush := visits in rush_visits
	var time_total: float = (25.0 + 14.0 * n) * (1.0 + 0.25 * float(upgrades["time"]))
	var pay: float = (40 + 35 * n) * (1.0 + 0.2 * float(upgrades["sign"]))
	if rush:
		time_total *= 0.55
		pay *= 1.8
	job = {
		"names": names.slice(0, n), "time": time_total, "pay": int(pay), "rush": rush,
		"who": CUSTOMER_NAMES[(visits - 1) % CUSTOMER_NAMES.size()],
		"repaint": randf() < 0.5,
	}
	var hits := maxi(1, 2 + visits / 3 - int(upgrades["power"]))
	job["hits"] = hits
	state = S.ARRIVING
	update_hud()
	hint_label.text = "A tow truck is bringing in the next car..."
	await spawn_car(job["names"], hits)
	if state != S.ARRIVING:
		return
	hint_label.text = "A customer is pulling in..."
	spawn_customer()


func open_offer() -> void:
	state = S.OFFER
	var lines := ""
	for pname in job["names"]:
		var complaint: String = PART_COMPLAINTS[pname]
		lines += "- %s%s\n" % [complaint.substr(0, 1).to_upper(), complaint.substr(1)]
	var opener := "Hi, my car is in a bad way. Can you fix it?"
	if job["rush"]:
		opener = "I'm in a HUGE hurry, I need it ASAP! I'll pay extra if you're quick!"
	var body := "\"%s\"\n\nProblems (%d):\n%s\nPays $%d. You'd have %d seconds." % [
		opener, job["names"].size(), lines, job["pay"], int(job["time"])]
	if job["rush"]:
		body += "\n\nRush job: the timer is much tighter than usual."
	if job["repaint"]:
		body += "\n\nI'd also love a fresh coat of paint afterwards. I'm a fan of %s." % FAMILY_NAMES[customer_look["pref"]["family"]]
	show_dialog(job["who"], body,
		[{"text": "Accept the job", "cb": accept_job}, {"text": "Refuse", "cb": refuse_job}])


func open_checklist() -> void:
	var lines := ""
	for pname in parts:
		if parts[pname]["broken"]:
			var complaint: String = PART_COMPLAINTS[pname]
			lines += "- %s%s (use the %s)\n" % [complaint.substr(0, 1).to_upper(), complaint.substr(1), tool_name_of(parts[pname]["tool"])]
	if lines == "":
		lines = "Everything looks fine!\n"
	show_dialog(job["who"], "\"Here's what's still wrong with my car:\"\n\n%s\nThe timer is paused while we talk." % lines,
		[{"text": "Got it", "cb": hide_dialog}])


func accept_job() -> void:
	hide_dialog()
	state = S.REPAIR
	set_tools_visible(true)
	time_left = job["time"]
	timer_on = true
	hint_label.text = "Mistakes cost money. A wrong tool, or clicking a part that isn't broken, is a mistake."
	update_hud()
	if customer:
		var walk := create_tween()
		walk.tween_property(customer, "rotation_degrees:y", 180.0, 0.2)
		walk.tween_property(customer, "position", Vector3(-5.5, 0.0, 3.6), 1.6)
		walk.tween_property(customer, "position", Vector3(-5.5, -0.25, 4.9), 0.8)


func refuse_job() -> void:
	hide_dialog()
	await leave_car()
	open_shop("You turned the customer away. No pay, no fine.")


func finish_job() -> void:
	timer_on = false
	set_tools_visible(false)
	hint_label.text = ""
	if tutorial:
		tutorial = false
		update_hud()
		await leave_car()
		state = S.SHOP
		show_dialog("Your car is fixed!",
			"It runs again. Word gets around fast: other people's cars need fixing too. More cars means more money, and more money means better upgrades.\n\nEach new car will have more problems than the last.",
			[{"text": "Open the garage", "cb": next_customer}])
		return
	money += job["pay"]
	update_hud()
	if job["repaint"]:
		open_paint_choice()
		return
	await leave_car()
	open_shop("%s thanks you and pays $%d." % [job["who"], job["pay"]])


func open_paint_choice() -> void:
	var pref: Dictionary = customer_look["pref"]
	var buttons: Array = []
	for shade in PAINT_SHADES:
		buttons.append({"text": shade["name"], "cb": func(): apply_repaint(shade)})
	buttons.append({"text": "Skip the repaint", "cb": func(): apply_repaint({})})
	show_dialog("Repaint",
		"\"The car runs great! Pick a colour for the repaint. I like %s shades.\"\n\nRepaint pays $%d, plus $%d if it matches their taste." % [FAMILY_NAMES[pref["family"]], REPAINT_PAY, REPAINT_MATCH_BONUS],
		buttons)


func apply_repaint(shade: Dictionary) -> void:
	hide_dialog()
	var summary := "%s thanks you and pays $%d." % [job["who"], job["pay"]]
	if not shade.is_empty() and current_car:
		var new_col: Color = shade["color"]
		var old_dark := car_color.darkened(0.25)
		for ch in current_car.get_children():
			if ch is MeshInstance3D and ch.material_override is StandardMaterial3D:
				var mat: StandardMaterial3D = ch.material_override
				if mat.albedo_color.is_equal_approx(car_color):
					mat.albedo_color = new_col
				elif mat.albedo_color.is_equal_approx(old_dark):
					mat.albedo_color = new_col.darkened(0.25)
		for pn in parts:
			if parts[pn]["good"].is_equal_approx(car_color):
				parts[pn]["mat"].albedo_color = new_col
		var pay := REPAINT_PAY
		var matched: bool = shade["family"] == customer_look["pref"]["family"]
		if matched:
			pay += REPAINT_MATCH_BONUS
		money += pay
		summary += "\nThe %s paint job earns $%d%s" % [shade["name"], pay, " (a perfect match!)" if matched else " (not quite their taste)."]
		update_hud()
	await leave_car()
	open_shop(summary)


func fail_job() -> void:
	timer_on = false
	set_tools_visible(false)
	hint_label.text = ""
	money = maxi(0, money - TIMEOUT_PENALTY)
	update_hud()
	await leave_car()
	open_shop("Time ran out and %s left angry. Fine: -$%d." % [job["who"], TIMEOUT_PENALTY])


func upgrade_cost(key: String) -> int:
	return int(UPGRADES[key]["cost"][upgrades[key]])


func open_shop(summary: String) -> void:
	last_summary = summary
	state = S.SHOP
	set_tools_visible(false)
	update_hud()
	if money >= SPORTS_CAR_PRICE and not sports_offered:
		sports_offered = true
		show_dialog("A shiny new ride",
			"%s\n\nA dealer rolls up in a gleaming red sports car. \"You've got $%d. This beauty is $%d. Take it for a spin?\"" % [summary, money, SPORTS_CAR_PRICE],
			[{"text": "Buy the sports car - $%d" % SPORTS_CAR_PRICE, "cb": buy_sports_car},
			{"text": "Decline", "cb": func(): open_shop(last_summary)}])
		return
	var buttons: Array = []
	for key in UPGRADES:
		var u = UPGRADES[key]
		var lvl: int = upgrades[key]
		if lvl >= u["max"]:
			buttons.append({"text": "%s - MAXED" % u["name"], "cb": func(): pass, "disabled": true})
		else:
			var cost := upgrade_cost(key)
			buttons.append({
				"text": "%s - $%d" % [u["name"], cost],
				"cb": func(): buy(key),
				"disabled": money < cost,
			})
	for tn in TOOLS:
		var tier: int = tool_tier[tn]
		if tier >= 2:
			buttons.append({"text": "%s - MAXED" % tool_name_of(tn), "cb": func(): pass, "disabled": true})
		else:
			var tcost: int = TOOL_TIERS[tn]["cost"][tier]
			buttons.append({
				"text": "Upgrade %s to %s - $%d" % [tool_name_of(tn), TOOL_TIERS[tn]["names"][tier + 1], tcost],
				"cb": func(): buy_tool(tn),
				"disabled": money < tcost,
			})
	if visits >= TOTAL_CUSTOMERS:
		buttons.append({"text": "Close the garage for the night", "cb": show_ending})
	else:
		buttons.append({"text": "Next customer", "cb": next_customer})
	show_dialog("Upgrade shop", "%s\n\nYou have $%d." % [summary, money], buttons)


func rebuild_sign() -> void:
	if sign_node:
		sign_node.queue_free()
	sign_node = Node3D.new()
	sign_node.position = Vector3(0, 3.8, -4.85)
	add_child(sign_node)
	GarageDecor.build_sign(sign_node, int(upgrades["sign"]))


func set_door(door: Node3D, open: bool, sec := 0.9) -> Tween:
	var t := create_tween()
	t.tween_property(door, "scale:y", 0.04 if open else 1.0, sec).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	return t


func set_doors(open: bool) -> void:
	var a := set_door(door_left, open)
	var b := set_door(door_right, open)
	await a.finished
	await b.finished


func rebuild_machine() -> void:
	if machine:
		machine.queue_free()
	machine = Node3D.new()
	machine.position = Vector3(-6.8, 0, 2.0)
	add_child(machine)
	GarageDecor.build_machine(machine, int(upgrades["power"]))


func buy(key: String) -> void:
	var cost := upgrade_cost(key)
	if money < cost:
		return
	money -= cost
	upgrades[key] += 1
	if key == "power":
		rebuild_machine()
	elif key == "sign":
		rebuild_sign()
	open_shop(last_summary)


func buy_tool(tn: String) -> void:
	var tier: int = tool_tier[tn]
	if tier >= 2:
		return
	var cost: int = TOOL_TIERS[tn]["cost"][tier]
	if money < cost:
		return
	money -= cost
	tool_tier[tn] = tier + 1
	rebuild_held_tool(tn)
	refresh_tools()
	open_shop(last_summary)


func buy_sports_car() -> void:
	state = S.DONE
	money -= SPORTS_CAR_PRICE
	update_hud()
	begin_cutscene()
	await cutscene.play_sports_drive()
	start_fight()


func sports_lost(fought: bool) -> void:
	hide_dialog()
	set_control(false)
	await cutscene.play_sports_lose(fought)
	end_cutscene_return()


func end_cutscene_return() -> void:
	cutscene.cleanup()
	cutscene.queue_free()
	cutscene = null
	cam.current = true
	top_panel.visible = true
	hint_label.visible = true
	toast_label.visible = true
	prompt_label.visible = true
	crosshair.visible = true
	state = S.SHOP
	update_hud()
	open_shop("The hero took your sports car. You are back to work.")


func sports_won() -> void:
	hide_fight_ui()
	unlock_ending("secret")
	await cutscene.play_sports_win()
	show_dialog(ENDINGS["secret"]["title"], ENDINGS["secret"]["text"],
		[{"text": "Back to menu", "cb": restart}])


# ---------- hero fight ----------

func start_fight() -> void:
	hide_dialog()
	set_control(false)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	p_hp = FIGHT_PLAYER_HP
	h_hp = FIGHT_HERO_HP
	h_mode = "idle"
	h_timer = 1.2
	p_block = false
	strike_cd = 0.0
	build_fight_ui()
	fight_on = true


func build_fight_ui() -> void:
	fight_ui = PanelContainer.new()
	fight_ui.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	fight_ui.grow_horizontal = Control.GROW_DIRECTION_BOTH
	fight_ui.grow_vertical = Control.GROW_DIRECTION_BEGIN
	fight_ui.offset_bottom = -20
	fight_ui.custom_minimum_size = Vector2(640, 0)
	fight_ui.add_theme_stylebox_override("panel", panel_style(Color(0.1, 0.11, 0.18, 0.92), GOLD, 3, 14))
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 8)
	fight_ui.add_child(v)
	var bars := HBoxContainer.new()
	bars.add_theme_constant_override("separation", 20)
	v.add_child(bars)
	p_bar = fight_bar("You", Color("4fb36b"), bars)
	h_bar = fight_bar("Hero", Color("d94b4b"), bars)
	fight_msg = Label.new()
	fight_msg.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	fight_msg.add_theme_font_size_override("font_size", 22)
	fight_msg.text = "Strike when the hero is open. Block when he winds up!"
	v.add_child(fight_msg)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	v.add_child(row)
	strike_btn = Button.new()
	strike_btn.text = "Strike (Space)"
	strike_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	strike_btn.add_theme_font_size_override("font_size", 22)
	style_button(strike_btn)
	strike_btn.pressed.connect(fight_strike)
	row.add_child(strike_btn)
	block_btn = Button.new()
	block_btn.text = "Block (Shift)"
	block_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	block_btn.add_theme_font_size_override("font_size", 22)
	style_button(block_btn)
	block_btn.button_down.connect(func(): p_block = true)
	block_btn.button_up.connect(func(): p_block = false)
	row.add_child(block_btn)
	var give_up := Button.new()
	give_up.text = "Give up"
	give_up.add_theme_font_size_override("font_size", 22)
	style_button(give_up)
	give_up.pressed.connect(func():
		hide_fight_ui()
		sports_lost(false))
	row.add_child(give_up)
	ui_layer.add_child(fight_ui)


func fight_bar(title: String, col: Color, parent: Control) -> ProgressBar:
	var box := VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var l := Label.new()
	l.text = title
	l.add_theme_font_size_override("font_size", 20)
	box.add_child(l)
	var b := ProgressBar.new()
	b.max_value = 100.0
	b.value = 100.0
	b.show_percentage = false
	b.custom_minimum_size = Vector2(0, 22)
	var fill := StyleBoxFlat.new()
	fill.bg_color = col
	fill.set_corner_radius_all(6)
	b.add_theme_stylebox_override("fill", fill)
	box.add_child(b)
	parent.add_child(box)
	return b


func hide_fight_ui() -> void:
	fight_on = false
	if fight_ui:
		fight_ui.queue_free()
		fight_ui = null


func fight_strike() -> void:
	if not fight_on or strike_cd > 0.0:
		return
	strike_cd = 0.45
	cutscene.swing_hammer(cutscene.s_owner.get_child(cutscene.s_owner.get_child_count() - 1))
	if h_mode == "windup":
		fight_msg.text = "Too early! He shrugs it off."
		return
	var dmg := FIGHT_STRIKE
	if h_mode == "recover":
		dmg *= 1.8
		fight_msg.text = "Counter! Big hit!"
	else:
		fight_msg.text = "Hit!"
	h_hp = maxf(0.0, h_hp - dmg)
	h_bar.value = h_hp
	var tw := create_tween()
	tw.tween_property(cutscene.s_hero, "position:z", 2.4, 0.05)
	tw.tween_property(cutscene.s_hero, "position:z", 1.8, 0.1)
	if h_hp <= 0.0:
		sports_won()


func fight_tick(delta: float) -> void:
	strike_cd = maxf(0.0, strike_cd - delta)
	h_timer -= delta
	if h_timer > 0.0:
		return
	match h_mode:
		"idle":
			h_mode = "windup"
			h_timer = 0.8
			fight_msg.text = "The hero winds up!  BLOCK!"
			cutscene.s_hero.rotation_degrees.x = -25.0
		"windup":
			cutscene.s_hero.rotation_degrees.x = 20.0
			if p_block:
				fight_msg.text = "Blocked! He's off balance - strike!"
				h_mode = "recover"
				h_timer = 1.0
			else:
				p_hp = maxf(0.0, p_hp - FIGHT_HERO_HIT)
				p_bar.value = p_hp
				fight_msg.text = "Ouch! The hero hits you."
				h_mode = "recover"
				h_timer = 0.6
				if p_hp <= 0.0:
					fight_on = false
					hide_fight_ui()
					sports_lost(true)
		"recover":
			cutscene.s_hero.rotation_degrees.x = 0.0
			h_mode = "idle"
			h_timer = randf_range(0.8, 1.6)


func show_ending() -> void:
	state = S.ENDING
	show_dialog("The last customer has gone",
		"You are holding $%d. The villain is still out there, and word of a rich garage travels.\n\nWhat do you do with the money?" % money,
		[{"text": "Donate it all to the city", "cb": ending_donate},
		{"text": "Keep it", "cb": ending_keep}])


func ending_donate() -> void:
	state = S.DONE
	money = 0
	update_hud()
	begin_cutscene()
	unlock_ending("donate")
	await cutscene.play_donate()
	show_dialog(ENDINGS["donate"]["title"], ENDINGS["donate"]["text"],
		[{"text": "Back to menu", "cb": restart}])


func ending_keep() -> void:
	state = S.DONE
	begin_cutscene()
	unlock_ending("keep")
	await cutscene.play_keep()
	show_dialog(ENDINGS["keep"]["title"], ENDINGS["keep"]["text"],
		[{"text": "Back to menu", "cb": restart}])


func begin_cutscene() -> void:
	hide_dialog()
	set_control(false)
	for n in [top_panel, hint_label, toast_label, prompt_label, crosshair, tool_bar]:
		n.visible = false
	cam.current = false
	cutscene = Cutscenes.new()
	add_child(cutscene)
	cutscene.setup(self, ui_layer)


func restart() -> void:
	get_tree().reload_current_scene()
