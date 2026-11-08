class_name CarBuilder
extends RefCounted

const TYPES := ["sedan", "suv", "hatchback"]


static func part_defs(type: String) -> Dictionary:
	var d := {}
	var wx := 1.3
	var wz := 0.98
	var wr := 0.38
	var hood_x := 1.35
	var hood_len := 1.2
	var bump_x := -2.2
	var door_y := 0.8
	var glass_pos := Vector3(0.75, 1.2, 0)
	var glass_tilt := 35.0
	match type:
		"suv":
			wx = 1.25
			wz = 1.02
			wr = 0.47
			hood_x = 1.3
			hood_len = 1.1
			bump_x = -2.1
			door_y = 1.0
			glass_pos = Vector3(0.7, 1.55, 0)
			glass_tilt = 25.0
		"hatchback":
			wx = 1.0
			wz = 0.94
			wr = 0.34
			hood_x = 1.05
			hood_len = 0.9
			bump_x = -1.8
			door_y = 0.75
			glass_pos = Vector3(0.45, 1.15, 0)
			glass_tilt = 40.0
	d["wheel_fl"] = {"tool": "wrench", "pos": Vector3(wx, wr, wz), "radius": wr}
	d["wheel_fr"] = {"tool": "wrench", "pos": Vector3(wx, wr, -wz), "radius": wr}
	d["wheel_rl"] = {"tool": "wrench", "pos": Vector3(-wx, wr, wz), "radius": wr}
	d["wheel_rr"] = {"tool": "wrench", "pos": Vector3(-wx, wr, -wz), "radius": wr}
	d["hood"] = {"tool": "hammer", "pos": Vector3(hood_x, door_y + 0.15, 0), "size": Vector3(hood_len, 0.14, 1.5)}
	d["bumper"] = {"tool": "hammer", "pos": Vector3(bump_x, 0.5, 0), "size": Vector3(0.16, 0.3, 1.6)}
	d["door"] = {"tool": "hammer", "pos": Vector3(-0.1, door_y, 0.9), "size": Vector3(1.0, 0.5, 0.06)}
	d["windshield"] = {"tool": "glass", "pos": glass_pos, "size": Vector3(0.08, 0.5, 1.3), "tilt": glass_tilt}
	return d


static func _mesh_box(parent: Node3D, size: Vector3, pos: Vector3, color: Color, rot := Vector3.ZERO) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var b := BoxMesh.new()
	b.size = size
	mi.mesh = b
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = 0.7
	mi.material_override = m
	mi.position = pos
	mi.rotation_degrees = rot
	parent.add_child(mi)
	return mi


static func _mesh_cyl(parent: Node3D, radius: float, height: float, pos: Vector3, color: Color, rot: Vector3, segs := 14) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var c := CylinderMesh.new()
	c.top_radius = radius
	c.bottom_radius = radius
	c.height = height
	c.radial_segments = segs
	mi.mesh = c
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = 0.6
	mi.material_override = m
	mi.position = pos
	mi.rotation_degrees = rot
	parent.add_child(mi)
	return mi


static func _mesh_cap(parent: Node3D, radius: float, height: float, pos: Vector3, color: Color, rot: Vector3) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var c := CapsuleMesh.new()
	c.radius = radius
	c.height = height
	c.radial_segments = 14
	c.rings = 6
	mi.mesh = c
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = 0.5
	mi.material_override = m
	mi.position = pos
	mi.rotation_degrees = rot
	parent.add_child(mi)
	return mi


# Rounded low-poly shell: capsules laid along X give soft ends, boxes give flat panels.
static func build_body(root: Node3D, type: String, color: Color) -> Vector3:
	var dark := color.darkened(0.25)
	var trim := Color("22232b")
	var size := Vector3(4.0, 0.6, 1.7)
	match type:
		"suv":
			_mesh_box(root, Vector3(3.9, 0.75, 1.75), Vector3(-0.1, 0.75, 0), color)
			_mesh_cap(root, 0.37, 1.75, Vector3(1.85, 0.75, 0), color, Vector3(90, 0, 0))
			_mesh_cap(root, 0.37, 1.75, Vector3(-2.05, 0.75, 0), color, Vector3(90, 0, 0))
			_mesh_box(root, Vector3(2.5, 0.75, 1.6), Vector3(-0.55, 1.5, 0), dark)
			_mesh_box(root, Vector3(2.52, 0.12, 1.5), Vector3(-0.55, 1.93, 0), trim)
			_mesh_box(root, Vector3(3.9, 0.12, 1.2), Vector3(-0.1, 0.34, 0), trim)
			size = Vector3(4.2, 1.0, 1.8)
		"sport":
			_mesh_box(root, Vector3(4.0, 0.4, 1.7), Vector3(-0.1, 0.5, 0), color)
			_mesh_cap(root, 0.2, 1.7, Vector3(1.9, 0.5, 0), color, Vector3(90, 0, 0))
			_mesh_cap(root, 0.2, 1.7, Vector3(-2.1, 0.5, 0), color, Vector3(90, 0, 0))
			_mesh_box(root, Vector3(1.5, 0.4, 1.4), Vector3(-0.3, 0.85, 0), dark)
			_mesh_box(root, Vector3(0.9, 0.3, 1.4), Vector3(0.9, 0.78, 0), color, Vector3(0, 0, -15))
			_mesh_box(root, Vector3(3.8, 0.02, 0.3), Vector3(-0.1, 0.71, 0), Color.WHITE)
			_mesh_box(root, Vector3(0.1, 0.06, 1.6), Vector3(-2.0, 0.95, 0), trim)
			for z in [-0.6, 0.6]:
				_mesh_box(root, Vector3(0.06, 0.2, 0.06), Vector3(-2.0, 0.8, z), trim)
			_mesh_box(root, Vector3(3.9, 0.08, 1.2), Vector3(-0.1, 0.3, 0), trim)
			size = Vector3(4.3, 0.5, 1.7)
		"hatchback":
			_mesh_box(root, Vector3(3.0, 0.55, 1.65), Vector3(-0.1, 0.6, 0), color)
			_mesh_cap(root, 0.275, 1.65, Vector3(1.4, 0.6, 0), color, Vector3(90, 0, 0))
			_mesh_cap(root, 0.275, 1.65, Vector3(-1.6, 0.6, 0), color, Vector3(90, 0, 0))
			_mesh_box(root, Vector3(1.9, 0.6, 1.5), Vector3(-0.55, 1.15, 0), dark)
			_mesh_box(root, Vector3(0.4, 0.5, 1.5), Vector3(-1.65, 1.1, 0), dark, Vector3(0, 0, -35))
			_mesh_box(root, Vector3(3.0, 0.1, 1.1), Vector3(-0.1, 0.32, 0), trim)
			size = Vector3(3.5, 0.8, 1.7)
		_:
			_mesh_box(root, Vector3(3.9, 0.55, 1.7), Vector3(-0.1, 0.6, 0), color)
			_mesh_cap(root, 0.275, 1.7, Vector3(1.85, 0.6, 0), color, Vector3(90, 0, 0))
			_mesh_cap(root, 0.275, 1.7, Vector3(-2.05, 0.6, 0), color, Vector3(90, 0, 0))
			_mesh_box(root, Vector3(1.8, 0.55, 1.5), Vector3(-0.35, 1.12, 0), dark)
			_mesh_box(root, Vector3(1.0, 0.1, 1.5), Vector3(-1.45, 0.95, 0), color)
			_mesh_box(root, Vector3(3.9, 0.1, 1.2), Vector3(-0.1, 0.32, 0), trim)
			size = Vector3(4.2, 0.6, 1.7)
	for x in [1.6, -1.85]:
		for z in [-0.5, 0.5]:
			var lamp_color := Color("fff2b0") if x > 0.0 else Color("c0262b")
			_mesh_box(root, Vector3(0.06, 0.12, 0.28), Vector3(x + (0.25 if x > 0.0 else -0.2) * (1.0 if type != "hatchback" else 0.0), 0.7, z), lamp_color)
	return size
