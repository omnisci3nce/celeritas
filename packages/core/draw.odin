// Immediate-mode drawing API

package core

// Colour type
RGBA :: [4]f64

// -- 2D

draw_rectangle :: proc(x: int, y: int, width: int, height:int, color: RGBA) {
  unimplemented()
}

// -- 3D

draw_cuboid :: proc(pos: Vec3, extents: Vec3, color: RGBA) {
  unimplemented()
}

draw_sphere :: proc(pos: Vec3, radius: f64, color: RGBA)