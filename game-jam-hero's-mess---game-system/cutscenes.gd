class_name Cutscenes
extends Node3D

signal finished

var main_node: Node3D
var cs_cam: Camera3D
var caption: Label
var layer: CanvasLayer
var hero: Node3D
var hero_parts: Array = []


func setup(main: Node3D, ui_layer: CanvasLayer) -> void:
	main_node = main
	layer = ui_layer
	caption = Label.new()
	caption.add_theme_font_size_override("font_size", 30)
	caption.add_theme_color_override("font_outline_color", Color.BLACK)
	caption.add_theme_constant_override("outline_size", 8)
	caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caption.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	caption.grow_vertical = Control.GROW_DIRECTION_BEGIN
	caption.offset_bottom = -50
	caption.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	layer.add_child(caption)
	cs_cam = Camera3D.new()
	main_node.add_child(cs_cam)


func say(text: String) -> void:
	caption.text = text


func wait(sec: float) -> void:
	await main_node.get_tree().create_timer(sec).timeout


func cam_to(pos: Vector3, look: Vector3, sec: float) -> void:
	var from_t := cs_cam.global_transform
	var to_t := Transform3D(Basis.looking_at(look - pos, Vector3.UP), pos)
	var tw := main_node.create_tween()
	tw.tween_method(func(w: float): cs_cam.global_transform = from_t.interpolate_with(to_t, w), 0.0, 1.0, sec).set_trans(Tween.TRANS_SINE)
	await tw.finished


func mesh_box(parent: Node3D, size: Vector3, pos: Vector3, color: Color) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var b := BoxMesh.new()
	b.size = size
	mi.mesh = b
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = 0.8
	mi.material_override = m
	mi.position = pos
	parent.add_child(mi)
	return mi


func make_hero(body := Color("3a6fd8"), hat := Color("c0392b")) -> Node3D:
	var h := Node3D.new()
	mesh_box(h, Vector3(0.28, 0.7, 0.3), Vector3(-0.17, 0.35, 0), Color("2c2c3a"))
	mesh_box(h, Vector3(0.28, 0.7, 0.3), Vector3(0.17, 0.35, 0), Color("2c2c3a"))
	mesh_box(h, Vector3(0.7, 0.8, 0.4), Vector3(0, 1.1, 0), body)
	mesh_box(h, Vector3(0.22, 0.7, 0.25), Vector3(-0.47, 1.1, 0), body)
	mesh_box(h, Vector3(0.22, 0.7, 0.25), Vector3(0.47, 1.1, 0), body)
	mesh_box(h, Vector3(0.45, 0.45, 0.45), Vector3(0, 1.75, 0), Color("f1c9a0"))
	mesh_box(h, Vector3(0.5, 0.12, 0.5), Vector3(0, 2.0, 0), hat)
	return h


func make_sport_car() -> Node3D:
	var car := Node3D.new()
	CarBuilder.build_body(car, "sport", Color("d92b2b"))
	for x in [1.3, -1.4]:
		for z in [-0.9, 0.9]:
			var w := MeshInstance3D.new()
			var c := CylinderMesh.new()
			c.top_radius = 0.32
			c.bottom_radius = 0.32
			c.height = 0.3
			c.radial_segments = 14
			w.mesh = c
			var m := StandardMaterial3D.new()
			m.albedo_color = Color("1f1f26")
			w.material_override = m
			w.position = Vector3(x, 0.32, z)
			w.rotation_degrees = Vector3(90, 0, 0)
			car.add_child(w)
	return car


var stage: Node3D
var s_car: Node3D
var s_owner: Node3D
var s_hero: Node3D


func add_hammer(who: Node3D) -> Node3D:
	var h := Node3D.new()
	h.position = Vector3(0.55, 1.2, 0.25)
	mesh_box(h, Vector3(0.06, 0.55, 0.06), Vector3(0, 0.1, 0), Color("8a5a2b"))
	mesh_box(h, Vector3(0.32, 0.16, 0.16), Vector3(0, 0.42, 0), Color("6c717c"))
	who.add_child(h)
	return h


func swing_hammer(h: Node3D) -> void:
	var tw := main_node.create_tween()
	tw.tween_property(h, "rotation_degrees:x", 100.0, 0.12)
	tw.tween_property(h, "rotation_degrees:x", 0.0, 0.2)


func play_sports_drive() -> void:
	stage = Node3D.new()
	main_node.add_child(stage)
	cs_cam.current = true
	s_car = make_sport_car()
	s_car.position = Vector3(-2.0, 0.12, 1.5)
	stage.add_child(s_car)
	s_owner = make_hero(Color("e8913a"), Color("2b2f44"))
	s_owner.position = Vector3(-2.0, 0.0, 3.4)
	s_owner.rotation_degrees.y = 180
	stage.add_child(s_owner)
	add_hammer(s_owner)
	cs_cam.global_position = Vector3(-6.0, 2.0, 7.0)
	cs_cam.look_at(Vector3(-2.0, 1.0, 2.0))
	say("Your brand new sports car. Time for a test drive!")
	await wait(2.2)

	s_owner.rotation_degrees.y = 0
	var hop := main_node.create_tween().set_parallel(true)
	hop.tween_property(s_owner, "position", Vector3(-2.3, 0.5, 1.5), 0.5)
	hop.tween_property(s_owner, "scale", Vector3.ONE * 0.05, 0.5)
	await hop.finished
	s_owner.visible = false
	say("Vroom!")
	cam_to(Vector3(8.0, 2.2, 6.0), Vector3(8.0, 0.8, 0.0), 1.6)
	var out := main_node.create_tween()
	out.tween_property(s_car, "position", Vector3(12.0, 0.12, 0.0), 2.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	await out.finished
	var spin := main_node.create_tween()
	spin.tween_property(s_car, "rotation_degrees:y", 720.0, 1.6).set_trans(Tween.TRANS_SINE)
	await spin.finished
	s_car.rotation_degrees.y = 0
	s_owner.position = Vector3(12.0, 0.0, 1.8)
	s_owner.scale = Vector3.ONE
	s_owner.visible = true
	s_owner.rotation_degrees.y = 90
	say("Smooth ride! Worth every dollar.")
	await wait(1.6)

	s_hero = make_hero()
	s_hero.position = Vector3(30.0, 0.0, 1.8)
	s_hero.rotation_degrees.y = -90
	stage.add_child(s_hero)
	await cam_to(Vector3(17.0, 2.0, 7.0), Vector3(17.0, 1.0, 1.0), 1.0)
	say("The hero charges straight at your car!")
	var run := main_node.create_tween()
	run.tween_property(s_hero, "position:x", 14.6, 1.3)
	await run.finished
	await cam_to(Vector3(13.3, 1.7, 6.2), Vector3(13.3, 1.1, 1.8), 0.7)
	say("\"I need this as a weapon!\"  Hammer ready - fight him off!")


func play_sports_win() -> void:
	var hammer := s_owner.get_child(s_owner.get_child_count() - 1) as Node3D
	say("You swing your hammer at the hero!")
	swing_hammer(hammer)
	await wait(0.5)
	var shake := main_node.create_tween().set_loops(10)
	shake.tween_property(s_hero, "position:z", 1.95, 0.05)
	shake.tween_property(s_hero, "position:z", 1.65, 0.05)
	var mark := Label3D.new()
	mark.text = "#!?!"
	mark.font_size = 120
	mark.pixel_size = 0.006
	mark.modulate = Color("ff4040")
	mark.position = Vector3(0, 2.6, 0)
	s_hero.add_child(mark)
	swing_hammer(hammer)
	say("The hero is thoroughly annoyed...")
	await wait(1.0)
	say("\"Fine! Find another weapon!\"")
	shake.kill()
	var fly := main_node.create_tween().set_parallel(true)
	fly.tween_property(s_hero, "position", Vector3(45.0, 30.0, -25.0), 2.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	fly.tween_property(s_hero, "rotation_degrees:z", 720.0, 2.2)
	cam_to(Vector3(12.0, 2.5, 8.0), Vector3(22.0, 8.0, -4.0), 1.6)
	await fly.finished
	s_hero.queue_free()
	await cam_to(Vector3(12.0, 1.8, 6.5), Vector3(12.0, 1.0, 1.0), 0.7)
	hammer.visible = false
	say("The hero is gone, and the sports car is all yours!")
	var hop := main_node.create_tween().set_parallel(true)
	hop.tween_property(s_owner, "position", Vector3(11.7, 0.5, 0.0), 0.5)
	hop.tween_property(s_owner, "scale", Vector3.ONE * 0.05, 0.5)
	await hop.finished
	s_owner.visible = false
	cam_to(Vector3(4.0, 2.2, 8.0), Vector3(0.0, 0.8, 0.0), 2.0)
	var home := main_node.create_tween()
	home.tween_property(s_car, "position:x", 0.0, 2.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	await home.finished
	var spin := main_node.create_tween()
	spin.tween_property(s_car, "rotation_degrees:y", 360.0, 1.2).set_trans(Tween.TRANS_SINE)
	await spin.finished
	await wait(1.2)
	finished.emit()


func play_sports_lose(fought: bool) -> void:
	if fought:
		say("The hero knocks the hammer out of your hands!")
		var hammer := s_owner.get_child(s_owner.get_child_count() - 1) as Node3D
		hammer.visible = false
	else:
		say("You step aside. The hero snatches the keys.")
	await wait(1.4)
	var hop := main_node.create_tween().set_parallel(true)
	hop.tween_property(s_hero, "position", Vector3(12.3, 0.5, 0.0), 0.4)
	hop.tween_property(s_hero, "scale", Vector3.ONE * 0.05, 0.4)
	await hop.finished
	s_hero.visible = false
	await wait(0.3)
	say("Your sports car is gone.")
	var rev := main_node.create_tween()
	rev.tween_property(s_car, "position:x", 60.0, 2.2).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	cam_to(Vector3(12.0, 1.8, 6.0), s_owner.position + Vector3(0, 1.0, 0), 0.8)
	await rev.finished
	s_car.queue_free()
	s_owner.rotation_degrees.y = 180
	var fall := main_node.create_tween()
	fall.tween_property(s_owner, "scale", Vector3(1.0, 0.6, 1.0), 0.6).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	await fall.finished
	say("You drop to your knees... but the garage is still open.")
	for i in 4:
		var tear := mesh_box(stage, Vector3(0.06, 0.12, 0.06), s_owner.position + Vector3(0.12, 1.0, 0.3), Color("7ecbff"))
		var tt := main_node.create_tween()
		tt.tween_property(tear, "position:y", 0.0, 0.8)
		tt.tween_callback(tear.queue_free)
		await wait(0.45)
	await wait(0.8)
	finished.emit()


func play_secret_replay() -> void:
	await play_sports_drive()
	await wait(1.2)
	await play_sports_win()


func cleanup() -> void:
	if stage:
		stage.queue_free()
	if cs_cam:
		cs_cam.queue_free()
	if caption:
		caption.queue_free()


func make_villain() -> Node3D:
	var v := Node3D.new()
	mesh_box(v, Vector3(0.4, 1.0, 0.4), Vector3(0, 0.5, 0), Color("1a1020"))
	mesh_box(v, Vector3(1.1, 1.2, 0.5), Vector3(0, 1.5, 0), Color("3b1f4d"))
	mesh_box(v, Vector3(0.3, 1.0, 0.3), Vector3(-0.7, 1.5, 0), Color("3b1f4d"))
	mesh_box(v, Vector3(0.3, 1.0, 0.3), Vector3(0.7, 1.5, 0), Color("3b1f4d"))
	mesh_box(v, Vector3(0.6, 0.6, 0.6), Vector3(0, 2.4, 0), Color("8a6fa0"))
	mesh_box(v, Vector3(1.6, 1.4, 0.1), Vector3(0, 1.5, -0.35), Color("1a1020"))
	for x in [-0.14, 0.14]:
		mesh_box(v, Vector3(0.1, 0.07, 0.04), Vector3(x, 2.45, 0.31), Color("ff2020"))
		var horn := CylinderMesh.new()
		horn.top_radius = 0.0
		horn.bottom_radius = 0.1
		horn.height = 0.45
		horn.radial_segments = 6
		var hm := MeshInstance3D.new()
		hm.mesh = horn
		hm.position = Vector3(x * 2.2, 2.85, 0)
		v.add_child(hm)
	return v


func money_bag() -> Node3D:
	var b := Node3D.new()
	var s := SphereMesh.new()
	s.radius = 0.35
	s.height = 0.7
	s.radial_segments = 12
	s.rings = 6
	var mi := MeshInstance3D.new()
	mi.mesh = s
	var m := StandardMaterial3D.new()
	m.albedo_color = Color("c9a227")
	mi.material_override = m
	b.add_child(mi)
	var label := Label3D.new()
	label.text = "$"
	label.font_size = 80
	label.pixel_size = 0.006
	label.position = Vector3(0, 0, 0.36)
	b.add_child(label)
	return b


func dust_puff(pos: Vector3, size: float) -> void:
	var mi := MeshInstance3D.new()
	var s := SphereMesh.new()
	s.radius = size
	s.height = size * 2.0
	s.radial_segments = 8
	s.rings = 4
	mi.mesh = s
	var m := StandardMaterial3D.new()
	m.albedo_color = Color(0.7, 0.68, 0.65, 0.55)
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mi.material_override = m
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mi.position = pos
	main_node.add_child(mi)
	var tw := main_node.create_tween().set_parallel(true)
	tw.tween_property(mi, "scale", Vector3.ONE * 3.0, 1.8)
	tw.tween_property(mi, "position:y", pos.y + 1.5, 1.8)
	tw.tween_property(m, "albedo_color:a", 0.0, 1.8)
	tw.chain().tween_callback(mi.queue_free)


func shatter(p: MeshInstance3D, count: int) -> Array:
	var box_size: Vector3 = p.mesh.get_aabb().size
	var color := Color("7a6a8f")
	var pm := p.material_override as StandardMaterial3D
	if pm:
		color = pm.albedo_color
	p.visible = false
	var shards: Array = []
	for i in count:
		var sz := Vector3(randf_range(0.4, 1.1), randf_range(0.25, 0.8), randf_range(0.3, 0.9))
		var off := Vector3(randf_range(-0.5, 0.5) * box_size.x, randf_range(-0.5, 0.5) * box_size.y, randf_range(-0.5, 0.5) * box_size.z)
		shards.append(mesh_box(main_node, sz, p.global_position + off, color.darkened(randf_range(0.0, 0.3))))
	return shards


func collapse_building(skip: Array) -> Array:
	var pieces: Array = []
	var topple: Array = []
	for c in main_node.get_children():
		if c == self or c == cs_cam or c in skip:
			continue
		if c is OmniLight3D:
			main_node.create_tween().tween_property(c, "light_energy", 0.0, 0.6)
		elif c is MeshInstance3D:
			var mi := c as MeshInstance3D
			if mi.mesh == null or mi.global_position.y <= 0.3:
				continue
			var sz: Vector3 = mi.mesh.get_aabb().size
			var biggest := maxf(sz.x, maxf(sz.y, sz.z))
			if biggest > 3.0:
				pieces.append_array(shatter(mi, clampi(int(biggest * 0.7), 4, 12)))
			else:
				pieces.append(mi)
		elif c.get_class() == "Node3D":
			var n := c as Node3D
			if n.global_position.y > 0.3:
				pieces.append(n)
			else:
				topple.append(n)

	for p in pieces:
		var node := p as Node3D
		var start := node.global_position
		var burst := start + Vector3(randf_range(-1.2, 1.2), randf_range(0.3, 1.2), randf_range(-1.0, 1.0))
		var land := Vector3(clampf(start.x + randf_range(-2.0, 2.0), -7.5, 7.5), randf_range(0.1, 0.3), clampf(start.z + randf_range(-1.5, 1.5), -4.5, 5.5))
		if Vector2(land.x - hero.position.x, land.z - hero.position.z).length() < 1.3:
			land.x += 2.8
		var tw := main_node.create_tween()
		tw.tween_interval(randf_range(0.0, 0.5))
		tw.tween_property(node, "global_position", burst, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.tween_property(node, "global_position", land, randf_range(0.7, 1.1)).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
		var rt := main_node.create_tween()
		rt.tween_property(node, "rotation_degrees", Vector3(randf_range(-60, 60), randf_range(-180, 180), randf_range(-60, 60)), 1.4)
	for t in topple:
		var tt := main_node.create_tween()
		tt.tween_property(t, "rotation_degrees:z", 80.0, 0.7).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	for i in 14:
		dust_puff(Vector3(randf_range(-7.0, 7.0), 0.5, randf_range(-4.0, 5.0)), randf_range(0.6, 1.0))
	return pieces


func toss_rubble(rubble: Array) -> void:
	var p := rubble.pick_random() as Node3D
	if p == null or not is_instance_valid(p):
		return
	var tw := main_node.create_tween()
	tw.tween_property(p, "global_position", p.global_position + Vector3(randf_range(-2.5, 2.5), 2.5, randf_range(-2.0, 2.0)), 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(p, "global_position:y", 0.2, 0.3)


func play_keep() -> void:
	cs_cam.current = true
	cs_cam.global_position = Vector3(0, 3.0, 11.5)
	cs_cam.look_at(Vector3(0, 1.8, 0))
	hero = make_hero()
	hero.position = Vector3(0, 0, 3.0)
	hero.rotation_degrees.y = 180
	main_node.add_child(hero)

	say("You counted your money by lamplight...")
	await wait(2.0)
	var villain := make_villain()
	villain.position = Vector3(0, 15, -1.0)
	main_node.add_child(villain)
	say("Then the sky went dark.")
	var drop := main_node.create_tween()
	drop.tween_property(villain, "position:y", 0.0, 0.9).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	await drop.finished

	say("The garage shattered and came crashing down!")
	var shake := main_node.create_tween()
	for i in 14:
		shake.tween_property(cs_cam, "h_offset", randf_range(-0.5, 0.5), 0.06)
	shake.tween_property(cs_cam, "h_offset", 0.0, 0.1)
	cam_to(Vector3(0, 3.5, 12.5), Vector3(0, 1.2, 0), 1.8)
	var rubble := collapse_building([hero, villain])
	await wait(2.6)

	say("He tore through the rubble, searching for your money...")
	await cam_to(Vector3(0, 4.0, 11.0), Vector3(0, 0.8, -0.5), 0.8)
	var spots := [Vector3(-4.0, 0, -2.5), Vector3(3.5, 0, -3.0), Vector3(3.0, 0, 1.0), Vector3(-1.5, 0, -1.0)]
	for s in spots:
		var d: Vector3 = s - villain.position
		villain.rotation_degrees.y = rad_to_deg(atan2(d.x, d.z))
		var mv := main_node.create_tween()
		mv.tween_property(villain, "position", s, 0.7)
		await mv.finished
		for k in 2:
			var dig := main_node.create_tween()
			dig.tween_property(villain, "rotation_degrees:x", 35.0, 0.18)
			dig.tween_callback(toss_rubble.bind(rubble))
			dig.tween_property(villain, "rotation_degrees:x", 0.0, 0.18)
			await dig.finished
	villain.rotation_degrees = Vector3.ZERO

	say("There! Under the beams... your money!")
	var bag := money_bag()
	bag.position = Vector3(-1.5, 0.3, 0.2)
	bag.scale = Vector3.ZERO
	main_node.add_child(bag)
	var pop := main_node.create_tween().set_parallel(true)
	pop.tween_property(bag, "position:y", 1.5, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	pop.tween_property(bag, "scale", Vector3.ONE, 0.5)
	await pop.finished
	bag.reparent(villain)
	var grab := main_node.create_tween()
	grab.tween_property(bag, "position", Vector3(0.9, 1.4, 0.3), 0.5)
	await grab.finished
	await wait(0.5)

	say("He took every last dollar and flew away into the night.")
	villain.rotation_degrees.y = 180
	var fly := main_node.create_tween().set_parallel(true)
	fly.tween_property(villain, "position", Vector3(8, 24, -16), 3.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	fly.tween_property(villain, "rotation_degrees:z", -30.0, 1.0)
	hero.rotation_degrees.y = 0
	var kneel := main_node.create_tween()
	kneel.tween_property(hero, "scale", Vector3(1.0, 0.6, 1.0), 0.8).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	await cam_to(Vector3(0.3, 1.3, 6.6), hero.position + Vector3(0, 0.8, 0), 3.4)
	villain.queue_free()

	say("You dropped to your knees, crying in agony.")
	var sob := main_node.create_tween().set_loops(8)
	sob.tween_property(hero, "position:y", 0.06, 0.2)
	sob.tween_property(hero, "position:y", 0.0, 0.2)
	for i in 8:
		for x in [-0.1, 0.1]:
			var tear := mesh_box(main_node, Vector3(0.06, 0.12, 0.06), hero.position + Vector3(x, 1.0, 0.27), Color("7ecbff"))
			var tt := main_node.create_tween()
			tt.tween_property(tear, "position:y", 0.0, 0.8)
			tt.tween_callback(tear.queue_free)
		await wait(0.45)
	await wait(0.8)
	finished.emit()


func glow_box(parent: Node3D, size: Vector3, pos: Vector3, color: Color) -> MeshInstance3D:
	var mi := mesh_box(parent, size, pos, color)
	var m := mi.material_override as StandardMaterial3D
	m.emission_enabled = true
	m.emission = color
	m.emission_energy_multiplier = 1.4
	return mi


func make_tree(parent: Node3D, pos: Vector3, s := 1.0) -> Node3D:
	var t := Node3D.new()
	t.position = pos
	t.scale = Vector3.ONE * s
	parent.add_child(t)
	mesh_box(t, Vector3(0.2, 1.0, 0.2), Vector3(0, 0.5, 0), Color("6b4a2b"))
	var crown := SphereMesh.new()
	crown.radius = 0.8
	crown.height = 1.6
	crown.radial_segments = 10
	crown.rings = 5
	var cm := MeshInstance3D.new()
	cm.mesh = crown
	var mm := StandardMaterial3D.new()
	mm.albedo_color = Color("4fb36b")
	cm.material_override = mm
	cm.position = Vector3(0, 1.4, 0)
	t.add_child(cm)
	return t


func face_toward(n: Node3D, target: Vector3) -> void:
	var d := target - n.position
	n.rotation.y = atan2(d.x, d.z)


func play_donate() -> void:
	cs_cam.current = true
	stage = Node3D.new()
	main_node.add_child(stage)
	var city := Node3D.new()
	city.position = Vector3(300, 0, 0)
	stage.add_child(city)
	mesh_box(city, Vector3(90, 0.4, 60), Vector3(0, -0.2, -10), Color("5d625c"))
	cs_cam.global_position = Vector3(300, 8.0, 20.0)
	cs_cam.look_at(Vector3(300, 3.0, -8.0))
	say("You gave everything to the city.")
	await wait(1.6)

	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	var blds: Array = []
	for row in 3:
		for i in 9:
			var w := rng.randf_range(2.0, 3.0)
			var h0 := rng.randf_range(1.2, 2.4)
			var root := Node3D.new()
			root.position = Vector3(-16.0 + i * 4.0 + rng.randf_range(-0.6, 0.6), 0, -6.0 - row * 6.5)
			city.add_child(root)
			var body := mesh_box(root, Vector3(1.0, 1.0, 1.0) * w, Vector3(0, h0 * 0.5, 0), Color("6e6a66"))
			body.scale.y = h0 / w
			var top := h0 * rng.randf_range(2.0, 3.2)
			var sky := rng.randf_range(7.0, 13.0) if row < 2 else rng.randf_range(4.0, 7.0)
			blds.append({"root": root, "body": body, "w": w, "h0": h0, "h1": top, "h2": sky, "hue": rng.randf_range(0.5, 0.78)})
	say("The money rebuilt the old, tired streets...")
	await cam_to(Vector3(300, 7.0, 17.0), Vector3(300, 2.5, -8.0), 1.8)

	for b in blds:
		var body: MeshInstance3D = b["body"]
		var w: float = b["w"]
		var tw := stage.create_tween().set_parallel(true)
		tw.tween_property(body, "scale:y", float(b["h1"]) / w, 0.9).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.tween_property(body, "position:y", float(b["h1"]) * 0.5, 0.9).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.tween_property(body.material_override, "albedo_color", Color.from_hsv(b["hue"], 0.3, 0.8), 0.9)
		await wait(0.07)
	await wait(1.0)

	say("Parks, fountains and fresh paint followed...")
	var trees: Array = []
	for i in 14:
		var tr := make_tree(city, Vector3(-17.0 + i * 2.6, 0, -2.2 + rng.randf_range(-0.5, 0.5)), 1.0)
		tr.scale = Vector3.ZERO
		trees.append(tr)
	for tr in trees:
		stage.create_tween().tween_property(tr, "scale", Vector3.ONE, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		await wait(0.1)
	var fountain := mesh_box(city, Vector3(2.4, 0.4, 2.4), Vector3(0, 0.2, 2.0), Color("c9c9d0"))
	glow_box(fountain, Vector3(1.6, 0.5, 1.6), Vector3(0, 0.2, 0), Color("6bd0ff"))
	await cam_to(Vector3(296, 9.0, 16.0), Vector3(300, 4.5, -10.0), 1.4)

	say("Until the little town became a gleaming city.")
	for b in blds:
		var body: MeshInstance3D = b["body"]
		var w: float = b["w"]
		var h: float = b["h2"]
		var tw := stage.create_tween().set_parallel(true)
		tw.tween_property(body, "scale:y", h / w, 1.0).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.tween_property(body, "position:y", h * 0.5, 1.0).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.tween_property(body.material_override, "albedo_color", Color.from_hsv(b["hue"], 0.45, 0.95), 1.0)
		var root: Node3D = b["root"]
		var k := 0
		while 0.8 + k * 1.1 < h - 0.4:
			var win := glow_box(root, Vector3(w * 1.03, 0.22, w * 1.03), Vector3(0, 0.8 + k * 1.1, 0), Color("ffe9a0"))
			win.scale = Vector3.ZERO
			stage.create_tween().tween_property(win, "scale", Vector3.ONE, 0.3).set_delay(0.5 + k * 0.05)
			k += 1
		if h > 9.0:
			glow_box(root, Vector3(0.12, 1.4, 0.12), Vector3(0, h + 0.7, 0), Color("ff5a5a"))
		await wait(0.09)
	var pan := stage.create_tween()
	pan.tween_property(cs_cam, "global_position", Vector3(304, 12.0, 14.0), 3.0).set_trans(Tween.TRANS_SINE)
	await wait(3.4)

	say("Back at the garage, word had spread...")
	main_node.call("set_doors", true)
	cs_cam.global_position = Vector3(-4.5, 2.4, 11.0)
	cs_cam.look_at(Vector3(0, 1.4, 6.5))
	await wait(1.0)
	var center := Vector3(0, 0, 1.0)
	var player := make_hero(Color("e8913a"), Color("2b2f44"))
	player.position = center
	player.rotation_degrees.y = 180
	stage.add_child(player)
	await cam_to(Vector3(0.0, 2.3, 5.0), Vector3(0, 1.3, 0.5), 2.6)
	var folks: Array = []
	var n_folks := 9
	for i in n_folks:
		var t := lerpf(-105.0, 105.0, float(i) / float(n_folks - 1))
		var spot := center + Vector3(sin(deg_to_rad(t)) * 3.4, 0.0, -cos(deg_to_rad(t)) * 2.2)
		var npc := make_hero(Color.from_hsv(float(i) / n_folks, 0.55, 0.85), Color.from_hsv(fmod(float(i) * 0.37, 1.0), 0.6, 0.9))
		npc.position = Vector3(spot.x * 1.6, 0.0, 9.0)
		stage.add_child(npc)
		face_toward(npc, spot)
		folks.append({"n": npc, "spot": spot})
	say("Neighbours crowded in to thank you.")
	for f in folks:
		var npc: Node3D = f["n"]
		var spot: Vector3 = f["spot"]
		var walk := stage.create_tween()
		walk.tween_property(npc, "position", spot, 2.0).set_trans(Tween.TRANS_SINE)
		walk.tween_callback(func(): face_toward(npc, center))
		await wait(0.18)
	await wait(2.0)
	var thanks := ["Thank you!", "You saved us!", "Best mechanic!", "Hooray!"]
	var idx := 0
	for f in folks:
		var npc: Node3D = f["n"]
		var hop := stage.create_tween().set_loops(10)
		hop.tween_property(npc, "position:y", 0.35, 0.22).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		hop.tween_property(npc, "position:y", 0.0, 0.22).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		if idx % 2 == 0:
			var lab := Label3D.new()
			lab.text = thanks[(idx / 2) % thanks.size()]
			lab.font_size = 64
			lab.pixel_size = 0.005
			lab.modulate = Color("ffe27a")
			lab.outline_size = 12
			lab.position = Vector3(0, 2.7, 0)
			lab.billboard = BaseMaterial3D.BILLBOARD_ENABLED
			npc.add_child(lab)
		idx += 1
	say("\"Thank you for everything you've done for this city!\"")
	for i in 40:
		var conf := mesh_box(stage, Vector3(0.08, 0.02, 0.08), Vector3(rng.randf_range(-4, 4), 5.0, rng.randf_range(-2, 3)), Color.from_hsv(rng.randf(), 0.7, 1.0))
		var ct := stage.create_tween()
		ct.tween_property(conf, "position:y", 0.0, rng.randf_range(1.4, 2.4))
		ct.tween_callback(conf.queue_free)
		if i % 4 == 0:
			await wait(0.1)
	await cam_to(Vector3(0.0, 2.0, 0.0), Vector3(0, 1.4, 10.0), 2.0)
	say("Business was booming like never before.")
	for i in 5:
		var car := Node3D.new()
		CarBuilder.build_body(car, CarBuilder.TYPES[i % 3], Color.from_hsv(i * 0.18, 0.6, 0.9))
		car.position = Vector3(-18, 0.1, 9.5 + (i % 2) * 2.0)
		stage.add_child(car)
		var drive := stage.create_tween()
		drive.tween_property(car, "position:x", 18.0, 5.0)
		drive.tween_callback(car.queue_free)
		await wait(0.8)
	await cam_to(Vector3(2.0, 2.6, 5.4), Vector3(0, 1.8, -1.0), 2.5)
	await wait(1.5)
	finished.emit()
