class_name GarageDecor
extends RefCounted


static func _m(color: Color, metal := false) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = 0.35 if metal else 0.8
	if metal:
		m.metallic = 0.6
	return m


static func _box(parent: Node3D, size: Vector3, pos: Vector3, color: Color, rot := Vector3.ZERO, metal := false) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var b := BoxMesh.new()
	b.size = size
	mi.mesh = b
	mi.material_override = _m(color, metal)
	mi.position = pos
	mi.rotation_degrees = rot
	parent.add_child(mi)
	return mi


static func _cyl(parent: Node3D, r: float, h: float, pos: Vector3, color: Color, rot := Vector3.ZERO, metal := false) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var c := CylinderMesh.new()
	c.top_radius = r
	c.bottom_radius = r
	c.height = h
	c.radial_segments = 12
	mi.mesh = c
	mi.material_override = _m(color, metal)
	mi.position = pos
	mi.rotation_degrees = rot
	parent.add_child(mi)
	return mi


static func _wrench(parent: Node3D, pos: Vector3, rot_z: float, scale := 1.0) -> void:
	var n := Node3D.new()
	n.position = pos
	n.rotation_degrees = Vector3(0, 0, rot_z)
	n.scale = Vector3.ONE * scale
	var steel := Color("aeb4bf")
	_box(n, Vector3(0.12, 1.1, 0.06), Vector3.ZERO, steel, Vector3.ZERO, true)
	_cyl(n, 0.2, 0.06, Vector3(0, 0.6, 0), steel, Vector3(90, 0, 0), true)
	_box(n, Vector3(0.14, 0.22, 0.08), Vector3(0, 0.74, 0), Color("2b2f44"))
	_cyl(n, 0.16, 0.06, Vector3(0, -0.6, 0), steel, Vector3(90, 0, 0), true)
	parent.add_child(n)


static func _hammer(parent: Node3D, pos: Vector3, rot_z: float, scale := 1.0) -> void:
	var n := Node3D.new()
	n.position = pos
	n.rotation_degrees = Vector3(0, 0, rot_z)
	n.scale = Vector3.ONE * scale
	_cyl(n, 0.04, 1.0, Vector3.ZERO, Color("8a5a2b"))
	_box(n, Vector3(0.5, 0.2, 0.2), Vector3(0, 0.5, 0), Color("6c717c"), Vector3.ZERO, true)
	parent.add_child(n)


static func _gear(parent: Node3D, pos: Vector3, radius: float, color: Color) -> void:
	var n := Node3D.new()
	n.position = pos
	_cyl(n, radius, 0.1, Vector3.ZERO, color, Vector3(90, 0, 0), true)
	for i in 8:
		var a := i * TAU / 8.0
		_box(n, Vector3(radius * 0.4, radius * 0.4, 0.1), Vector3(cos(a), sin(a), 0) * radius * 1.05, color, Vector3(0, 0, rad_to_deg(a)), true)
	_cyl(n, radius * 0.35, 0.12, Vector3.ZERO, Color("2b2f44"), Vector3(90, 0, 0))
	parent.add_child(n)


static func build_roof(root: Node3D) -> void:
	var roof_y := 5.0
	var dark := Color("3b3f55")
	_box(root, Vector3(17, 0.3, 12.3), Vector3(0, roof_y + 0.15, 0.6), Color("4a4e66"))
	for x in [-6.0, -2.0, 2.0, 6.0]:
		_box(root, Vector3(0.35, 0.45, 12.3), Vector3(x, roof_y - 0.22, 0.6), dark, Vector3.ZERO, true)
	for z in [-3.5, 0.5, 4.5]:
		_box(root, Vector3(17, 0.3, 0.3), Vector3(0, roof_y - 0.1, z), Color("2b2f44"), Vector3.ZERO, true)

	for i in 4:
		var x := -6.0 + i * 4.0
		_box(root, Vector3(2.2, 0.08, 0.35), Vector3(x, roof_y - 0.5, 0.5), Color("fff6d0"))
		var lamp := OmniLight3D.new()
		lamp.position = Vector3(x, roof_y - 0.8, 0.5)
		lamp.omni_range = 7.0
		lamp.light_energy = 0.9
		lamp.light_color = Color("fff0c8")
		root.add_child(lamp)

	var rail_y := roof_y - 0.55
	for i in 6:
		var x := -7.2 + i * 2.9
		var z := -2.5 + (i % 3) * 3.2
		match i % 3:
			0:
				_wrench(root, Vector3(x, rail_y - 0.5, z), 8.0 * (1 if i % 2 == 0 else -1), 1.2)
			1:
				_hammer(root, Vector3(x, rail_y - 0.5, z), -10.0, 1.2)
			2:
				_gear(root, Vector3(x, rail_y - 0.4, z), 0.45, Color("c9a227"))
		for dx in [-0.15, 0.15]:
			_cyl(root, 0.012, 0.5, Vector3(x + dx, rail_y + 0.1, z), Color("1a1a1a"))



static func build_machine(root: Node3D, level: int) -> void:
	var body_color: Color = [Color("7a7f8c"), Color("2e86c1"), Color("3aa86b"), Color("e8b93a")][level]
	_box(root, Vector3(1.4, 0.3, 1.0), Vector3(0, 0.15, 0), Color("2b2f44"), Vector3.ZERO, true)
	_box(root, Vector3(0.9, 1.0 + 0.3 * level, 0.8), Vector3(0, 0.8 + 0.15 * level, 0), body_color, Vector3.ZERO, true)
	_cyl(root, 0.12, 1.2, Vector3(0.6, 1.2 + 0.3 * level, 0), Color("aeb4bf"), Vector3(0, 0, 70), true)
	_gear(root, Vector3(0, 1.1 + 0.3 * level, 0.42), 0.28, Color("c9a227"))
	for i in level:
		_cyl(root, 0.08, 0.5, Vector3(-0.35 + i * 0.35, 1.9 + 0.3 * level, 0), Color("aeb4bf"), Vector3.ZERO, true)
		_box(root, Vector3(0.12, 0.12, 0.12), Vector3(-0.35 + i * 0.35, 2.2 + 0.3 * level, 0), Color("ffd24a"))


static func build_walls_decor(root: Node3D) -> void:
	var board := _box(root, Vector3(5.0, 2.2, 0.1), Vector3(-4.5, 2.3, -4.95), Color("7b6a52"))
	for i in 5:
		var x := -2.2 + i * 1.0
		var wx := x - 2.2
		if i % 2 == 0:
			_wrench(root, Vector3(-6.2 + i * 0.9, 2.3, -4.85), 0.0, 1.0)
		else:
			_hammer(root, Vector3(-6.2 + i * 0.9, 2.3, -4.85), 0.0, 1.0)
		wx = wx
	_gear(root, Vector3(-2.6, 2.8, -4.85), 0.4, Color("9a9fb0"))
	board.name = "ToolBoard"
	_box(root, Vector3(2.6, 1.0, 0.9), Vector3(4.5, 0.5, -4.5), Color("c0392b"), Vector3.ZERO, true)
	_box(root, Vector3(2.6, 0.08, 0.95), Vector3(4.5, 1.04, -4.5), Color("3a3f4d"))
	_box(root, Vector3(1.4, 1.5, 0.8), Vector3(-7.4, 0.75, -4.4), Color("2e86c1"), Vector3.ZERO, true)
	for i in 4:
		_cyl(root, 0.35, 0.9, Vector3(7.3, 0.45, -4.4 + i * 0.7), Color("2b2f44") if i % 2 == 0 else Color("c0392b"), Vector3.ZERO)
	for x in [-4.0, -2.0, 0.0, 2.0, 4.0]:
		_box(root, Vector3(0.06, 2.0, 0.3), Vector3(x, 2.5, 6.1), Color("5a5f78"), Vector3.ZERO, true)


static func _glow(parent: Node3D, size: Vector3, pos: Vector3, color: Color, energy := 1.6, rot := Vector3.ZERO) -> MeshInstance3D:
	var mi := _box(parent, size, pos, color, rot)
	var m := mi.material_override as StandardMaterial3D
	m.emission_enabled = true
	m.emission = color
	m.emission_energy_multiplier = energy
	return mi


static func _text(parent: Node3D, text: String, px: int, pos: Vector3, color: Color, pixel_size := 0.005, rot_y := 0.0) -> Label3D:
	var l := Label3D.new()
	l.text = text
	l.font_size = px
	l.pixel_size = pixel_size
	l.modulate = color
	l.position = pos
	l.rotation_degrees.y = rot_y
	parent.add_child(l)
	return l


static func build_sign(root: Node3D, level: int) -> void:
	var w := 5.0 + level * 0.5
	var h := 0.8 + level * 0.15
	var base: Color = [Color("e8b93a"), Color("e8b93a"), Color("1d2033"), Color("2a1630")][level]
	var txt: Color = [Color("2b2f44"), Color("2b2f44"), Color("ffe08a"), Color("ffd24a")][level]
	_box(root, Vector3(w, h, 0.12), Vector3.ZERO, base, Vector3.ZERO, level >= 2)
	_text(root, "HERO'S MESS GARAGE", 96, Vector3(0, 0.03 * level, 0.07), txt, 0.005 + 0.0003 * level)
	if level >= 1:
		var frame := Color("6b4a2b") if level == 1 else Color("c9a227")
		var metal := level >= 2
		for y in [-h * 0.5 - 0.05, h * 0.5 + 0.05]:
			_box(root, Vector3(w + 0.2, 0.1, 0.18), Vector3(0, y, 0), frame, Vector3.ZERO, metal)
		for x in [-w * 0.5 - 0.05, w * 0.5 + 0.05]:
			_box(root, Vector3(0.1, h + 0.2, 0.18), Vector3(x, 0, 0), frame, Vector3.ZERO, metal)
		for x in [-w * 0.35, w * 0.35]:
			_box(root, Vector3(0.06, 0.06, 0.5), Vector3(x, h * 0.5 + 0.3, 0.25), Color("2b2f44"))
			_cyl(root, 0.12, 0.2, Vector3(x, h * 0.5 + 0.35, 0.5), Color("3b3f55"), Vector3(90, 0, 0), true)
			_glow(root, Vector3(0.16, 0.16, 0.04), Vector3(x, h * 0.5 + 0.35, 0.62), Color("fff2b0"), 2.0)
	if level >= 2:
		var neon := Color("3de0ff")
		for y in [-h * 0.5 + 0.08, h * 0.5 - 0.08]:
			_glow(root, Vector3(w - 0.3, 0.04, 0.04), Vector3(0, y, 0.08), neon, 2.5)
		_gear(root, Vector3(-w * 0.5 - 0.6, 0, 0), 0.32, Color("c9a227"))
		_gear(root, Vector3(w * 0.5 + 0.6, 0, 0), 0.32, Color("c9a227"))
		for i in 11:
			var x := -w * 0.5 + i * w / 10.0
			var sag := sin(float(i) / 10.0 * PI) * 0.18
			_glow(root, Vector3(0.07, 0.07, 0.07), Vector3(x, h * 0.5 + 0.5 - sag, 0.15), [Color("ff6b6b"), Color("ffd24a"), Color("6bff9a"), Color("6bb8ff")][i % 4], 2.2)
	if level >= 3:
		for i in 3:
			_box(root, Vector3(1.4 - i * 0.4, 0.12, 0.14), Vector3(0, h * 0.5 + 0.12 + i * 0.12, 0.02), Color("e8b93a"), Vector3.ZERO, true)
		for x in [-0.45, 0.0, 0.45]:
			_glow(root, Vector3(0.14, 0.14, 0.14), Vector3(x, h * 0.5 + 0.55 + (0.1 if x == 0.0 else 0.0), 0.05), Color("ff4a6b"), 2.5, Vector3(45, 0, 45))
		for x in [-w * 0.5 - 0.95, w * 0.5 + 0.95]:
			_box(root, Vector3(0.2, 0.5, 0.2), Vector3(x, -0.1, 0.1), Color("c9a227"), Vector3.ZERO, true)
			_glow(root, Vector3(0.28, 0.28, 0.28), Vector3(x, 0.3, 0.15), Color("ff9a2a"), 3.0, Vector3(45, 45, 0))
			var torch := OmniLight3D.new()
			torch.position = Vector3(x, 0.3, 0.7)
			torch.light_color = Color("ff9a2a")
			torch.omni_range = 3.5
			root.add_child(torch)
		_text(root, "- FIX IT FAST -", 48, Vector3(0, -h * 0.5 - 0.35, 0.1), Color("ffd24a"), 0.006)
		var spot := OmniLight3D.new()
		spot.position = Vector3(0, 0, 1.2)
		spot.light_color = Color("ffe9a8")
		spot.omni_range = 4.0
		spot.light_energy = 1.2
		root.add_child(spot)


static func floor_texture() -> ImageTexture:
	var img := Image.create(128, 128, true, Image.FORMAT_RGB8)
	var rng := RandomNumberGenerator.new()
	rng.seed = 11
	for y in 128:
		for x in 128:
			var v := 0.82 + rng.randf() * 0.1
			if x % 64 < 2 or y % 64 < 2:
				v = 0.55
			img.set_pixel(x, y, Color(v, v, v))
	img.generate_mipmaps()
	return ImageTexture.create_from_image(img)


static func build_side_wall(root: Node3D, x: float) -> Node3D:
	var wall := Color("7a6a8f")
	var yellow := Color("e8b93a")
	_box(root, Vector3(0.3, 5.0, 2.95), Vector3(x, 2.5, -3.675), wall)
	_box(root, Vector3(0.3, 5.0, 3.1), Vector3(x, 2.5, 4.75), wall)
	_box(root, Vector3(0.3, 1.6, 5.4), Vector3(x, 4.2, 0.5), wall)
	for z in [-2.25, 3.25]:
		_box(root, Vector3(0.4, 3.4, 0.15), Vector3(x, 1.7, z), yellow)
	_box(root, Vector3(0.4, 0.15, 5.7), Vector3(x, 3.42, 0.5), yellow)
	for i in 6:
		_box(root, Vector3(0.8, 0.02, 0.9), Vector3(x * 0.94, 0.02, -1.75 + i * 0.9), yellow if i % 2 == 0 else Color("22232b"))
	var door := Node3D.new()
	door.position = Vector3(x, 3.4, 0.5)
	root.add_child(door)
	_box(door, Vector3(0.12, 3.3, 5.4), Vector3(0, -1.65, 0), Color("9aa3b8"), Vector3.ZERO, true)
	for i in 7:
		_box(door, Vector3(0.16, 0.05, 5.4), Vector3(0, -0.45 - i * 0.46, 0), Color("6c7488"))
	for j in 4:
		_box(door, Vector3(0.17, 0.22, 0.9), Vector3(0, -0.3, -1.9 + j * 1.27), Color("cfe8ff"))
	return door


static func _plant(root: Node3D, pos: Vector3) -> void:
	_cyl(root, 0.28, 0.5, pos + Vector3(0, 0.25, 0), Color("b5651d"))
	_cyl(root, 0.05, 0.6, pos + Vector3(0, 0.8, 0), Color("4a7a3a"))
	for i in 5:
		var a := i * TAU / 5.0
		_box(root, Vector3(0.12, 0.5, 0.3), pos + Vector3(cos(a) * 0.22, 1.2, sin(a) * 0.22), Color("3f9a52"), Vector3(sin(a) * 30.0, rad_to_deg(a), cos(a) * 30.0))


static func _poster(root: Node3D, x: float, text: String, color: Color) -> void:
	_box(root, Vector3(1.3, 1.7, 0.04), Vector3(x, 2.4, 6.11), color)
	_text(root, text, 64, Vector3(x, 2.4, 6.08), Color("22232b"), 0.004, 180.0)


static func build_lounge(root: Node3D) -> void:
	_box(root, Vector3(3.6, 0.03, 2.2), Vector3(-5.5, 0.02, 4.7), Color("8a4b3c"))
	_box(root, Vector3(3.2, 0.03, 1.8), Vector3(-5.5, 0.035, 4.7), Color("a8604a"))
	var sofa := Node3D.new()
	sofa.position = Vector3(-5.5, 0, 5.3)
	sofa.rotation_degrees.y = 180.0
	root.add_child(sofa)
	var fabric := Color("2f7f8f")
	_box(sofa, Vector3(2.0, 0.28, 0.9), Vector3(0, 0.18, 0), fabric.darkened(0.2))
	for x in [-0.45, 0.45]:
		_box(sofa, Vector3(0.9, 0.18, 0.75), Vector3(x, 0.41, 0.05), fabric)
	_box(sofa, Vector3(2.0, 0.75, 0.2), Vector3(0, 0.7, -0.35), fabric.darkened(0.1))
	for x in [-1.0, 1.0]:
		_box(sofa, Vector3(0.2, 0.55, 0.9), Vector3(x, 0.42, 0), fabric.darkened(0.15))
	for x in [-0.9, 0.9]:
		_box(sofa, Vector3(0.12, 0.08, 0.12), Vector3(x, 0.02, 0.35), Color("2b2f44"))
	_box(sofa, Vector3(0.45, 0.35, 0.12), Vector3(-0.8, 0.7, -0.2), Color("e8b93a"), Vector3(0, 0, 12))
	_box(root, Vector3(1.2, 0.08, 0.6), Vector3(-5.5, 0.42, 3.9), Color("6b4a2b"))
	for x in [-0.5, 0.5]:
		for z in [-0.2, 0.2]:
			_cyl(root, 0.04, 0.4, Vector3(-5.5 + x, 0.2, 3.9 + z), Color("2b2f44"))
	_cyl(root, 0.07, 0.12, Vector3(-5.2, 0.52, 3.9), Color("ffffff"))
	_box(root, Vector3(0.35, 0.03, 0.25), Vector3(-5.8, 0.47, 3.9), Color("d94b4b"))
	_plant(root, Vector3(-7.5, 0, 5.6))
	_box(root, Vector3(0.8, 1.9, 0.9), Vector3(-7.4, 0.95, 3.9), Color("c0392b"), Vector3.ZERO, true)
	_glow(root, Vector3(0.02, 1.2, 0.7), Vector3(-6.99, 1.1, 3.9), Color("6bd0ff"), 1.4)


static func build_more_decor(root: Node3D) -> void:
	_box(root, Vector3(2.6, 0.1, 0.9), Vector3(0.0, 0.95, -4.5), Color("8a6a43"))
	for x in [-1.2, 1.2]:
		_box(root, Vector3(0.1, 0.9, 0.8), Vector3(x, 0.45, -4.5), Color("3a3f4d"), Vector3.ZERO, true)
	_box(root, Vector3(2.4, 0.08, 0.7), Vector3(0.0, 0.4, -4.5), Color("3a3f4d"))
	_box(root, Vector3(0.3, 0.25, 0.3), Vector3(-0.9, 1.12, -4.5), Color("55586b"), Vector3.ZERO, true)
	_hammer(root, Vector3(0.2, 1.02, -4.4), 90.0, 0.35)
	_wrench(root, Vector3(0.7, 1.02, -4.5), 90.0, 0.35)
	for y in [1.3, 2.0]:
		_box(root, Vector3(0.4, 0.08, 1.6), Vector3(-8.0, y, -3.1), Color("8a6a43"))
		for i in 4:
			_cyl(root, 0.1, 0.22, Vector3(-8.0, y + 0.15, -3.7 + i * 0.4), [Color("d94b4b"), Color("3d8be0"), Color("e0c13d"), Color("4fb36b")][i])
	for i in 3:
		_cyl(root, 0.45, 0.3, Vector3(7.3 + i * 0.04, 0.15 + i * 0.3, 4.8), Color("1f1f26"))
	for i in 2:
		_cyl(root, 0.45, 0.3, Vector3(6.4, 0.15 + i * 0.3, 5.3), Color("1f1f26"))
	_poster(root, -6.0, "WANTED\nTHE HERO", Color("e8d9a8"))
	_poster(root, -3.0, "FIX IT\nFAST", Color("f2a65a"))
	_poster(root, 1.0, "TIRES\n50% OFF", Color("9fd8ff"))
	_poster(root, 3.0, "COFFEE\n$1", Color("e8b0b0"))
	_cyl(root, 0.5, 0.05, Vector3(-1.0, 3.6, 6.12), Color("22232b"), Vector3(90, 0, 0))
	_cyl(root, 0.45, 0.06, Vector3(-1.0, 3.6, 6.1), Color("f4f4f4"), Vector3(90, 0, 0))
	_box(root, Vector3(0.04, 0.3, 0.03), Vector3(-1.0, 3.72, 6.07), Color("22232b"))
	_box(root, Vector3(0.25, 0.04, 0.03), Vector3(-0.88, 3.6, 6.07), Color("22232b"))
	_glow(root, Vector3(0.05, 0.5, 1.4), Vector3(-7.82, 4.2, 0.5), Color("ff3a4a"), 1.8)
	_text(root, "OPEN", 72, Vector3(-7.78, 4.2, 0.5), Color.WHITE, 0.006, 90.0)
	_plant(root, Vector3(7.5, 0, 5.6))
