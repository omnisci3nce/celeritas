// This code will eventually be moved into its own package but for simplicity's sake its here for now

package core

import "core:math/linalg"
import "../ral"

// NOTE(omni): Do we want to use f32 or f64 by default? I'm not sure we should really care at this point
//             but at least with these type aliases we can easily change them later.
Vec2 :: linalg.Vector2f64
Vec3 :: linalg.Vector3f64
Vec4 :: linalg.Vector4f64
Quat :: linalg.Quaternionf64

Static3DVertex :: struct {
	position: Vec3,
	normal: Vec3,
	tex_coords: Vec2
}

Vertices :: struct {
    // TODO: this should eventually be a tagged union that suits any vertex format, for now omni has
    //       decided that we will work with one vertex type - static 3d
    inner: [dynamic]Static3DVertex,
}

Geometry :: struct {
    vertices: Vertices,
    has_indices: bool,
    indices: [dynamic]u32
}

Mesh :: struct {
    vertex_buffer: ral.GPU_Buffer,
    index_buffer: ral.GPU_Buffer,
    geo: Maybe(Geometry) // nil if the CPU-side data has been freed
}

Camera :: struct {
    position: Vec3,
    rotation: Quat,
    fov: f64
}