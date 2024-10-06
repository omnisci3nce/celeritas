// This code will eventually be moved into its own package but for simplicity's sake its here for now

package core

import "../ral"
import "core:math/linalg"

// Shorter type aliases
Vec2 :: linalg.Vector2f32
Vec3 :: linalg.Vector3f32
Vec4 :: linalg.Vector4f32

Static3DVertex :: struct {
	position:   Vec3,
	normal:     Vec3,
	tex_coords: Vec2,
}

Vertices :: struct {
	// TODO: this should eventually be a tagged union that suits any vertex format, for now omni has
	//       decided that we will work with one vertex type - static 3d
	inner: [dynamic]Static3DVertex,
}

Geometry :: struct {
	vertices:    Vertices,
	has_indices: bool,
	indices:     [dynamic]u32,
}

Mesh :: struct {
	vertex_buffer: ral.BufferHandle,
	index_buffer:  ral.BufferHandle,
	geo:           Maybe(Geometry), // nil if the CPU-side data has been freed
}

create_mesh :: proc(geo: Geometry, free_on_upload: bool) -> Mesh {
	// create vertex buffer
	size := uint(len(geo.vertices.inner) * size_of(Static3DVertex))
	vbuf := ral.gpu_buffer_create(size, .Vertex, .DeviceLocal, nil)

	// create index buffer
	ibuf := ral.gpu_buffer_create(uint(len(geo.indices) * size_of(u32)), .Index, .DeviceLocal, nil)

	// (optional) free cpu-side vertex data

	return Mesh{vertex_buffer = vbuf, index_buffer = ibuf}
}
