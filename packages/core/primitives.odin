package core

// Create the [Geometry] for a cuboid
cube_geo :: proc(extents: Vec3) -> Geometry {
	verts: [dynamic]Static3DVertex
	indices: [dynamic]u32

	corners := [8]Vec3 {
		{-0.5, -0.5, -0.5}, // back bot left
		{0.5, -0.5, -0.5}, // back bot right
		{-0.5, 0.5, -0.5}, // back top left
		{0.5, 0.5, -0.5}, // back top right
		{-0.5, -0.5, 0.5}, // front bot left
		{0.5, -0.5, 0.5}, // front bot right
		{-0.5, 0.5, 0.5}, // front top left
		{0.5, 0.5, 0.5}, // front top right
	}

	// scale corners
	for i in 0 ..= 7 {
		corners[i].x *= extents.x
		corners[i].y *= extents.y
		corners[i].z *= extents.z
	}

	faces := [6][4]int {
		{0, 2, 3, 1}, // back
		{4, 5, 7, 6}, // front
		{0, 1, 5, 4}, // bottom
		{2, 6, 7, 3}, // top
		{0, 4, 6, 2}, // left
		{1, 3, 7, 5}, // right
	}

	normals := [6]Vec3{{0, 0, -1}, {0, 0, 1}, {0, -1, 0}, {0, 1, 0}, {-1, 0, 0}, {1, 0, 0}}

	vertex_index := 0
	for face := 0; face < 6; face += 1 {
		for i := 0; i < 6; i += 1 {
			corner := faces[face][i % 4]
			append(
				&verts,
				Static3DVertex {
					position = corners[corner],
					normal = normals[face],
					tex_coords = Vec2{0, 0},
				},
			)
			append(&indices, u32(vertex_index))
			vertex_index += 1
		}
	}

	return Geometry{vertices = Vertices{inner = verts}, has_indices = true, indices = indices}
}

// Create the [Geometry] for a sphere
sphere_geo :: proc(radius: f64, north_south_lines: u32, east_west_lines: u32) -> Geometry {
	unimplemented()
}
