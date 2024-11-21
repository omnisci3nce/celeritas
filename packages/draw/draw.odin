/* Immediate mode drawing api */

package draw

import "core:math"
import "core:math/linalg"
import "../core"
import "../ral"

Vec2 :: linalg.Vector2f32

DrawSystemState :: struct {
    pipeline: ral.PipelineHandle,
    vertices: ral.BufferHandle,
    // TODO: some struct to handle shader binding data
}

// Per vertex data that gets appended with each draw_ function call
DrawCallVertex :: struct {
    // position: Vec2
    // color: color
}

// Set up a [DrawSystemState] and store it on the core
draw_system_init :: proc (engine: ^core.Engine) {
    // TODO: create shader that can handle the below draw functions
    // TODO: create a graphics pipeline using the above vert/frag shaders
    // TODO: create a GPU buffer to hold per frame vertices
}

// Clean up the draw system internal state
draw_system_shutdown :: proc (s: ^DrawSystemState) {/* Ignore cleanup to begin with */}

// Should be called once per frame **during** rendering phase
draw_system_tick :: proc(s: ^DrawSystemState) {
    // TODO: at the beginning we probably want to clear the vertex buffer
    // TODO: do each basic draw call in turn. we might need something different for the draw_texture
    //       series of functions as they will need to switch texture sampler
    // TODO: submit command buffer on queue
}

color :: struct {
	red, green, blue, alpha: u8,
}

draw_rectangle :: proc(x: f32, y: f32, width: f32, height: f32, color: color) {
	unimplemented()
}

draw_rectangle_ex :: proc(center: Vec2, width: f32, height: f32, rotation: f32, color: color) {
	unimplemented()
}

draw_circle :: proc (center: Vec2, radius: f32, color: color) {
    unimplemented()
}

load_texture_from_file :: proc(filepath: string) -> ral.TextureHandle {
    unimplemented()
}

draw_texture :: proc (texture: ral.TextureHandle, x: f32, y: f32) {
    unimplemented()
}

draw_texture_ex :: proc (texture: ral.TextureHandle, center: Vec2, rotation: f32, scale: f32) {
    unimplemented()
}
