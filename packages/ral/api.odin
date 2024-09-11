package ral

import "vendor:glfw"

// Initialise the RAL backend
backend_init :: proc(window: glfw.WindowHandle) {
  _backend_init(window)
}

backend_shutdown:: proc() {
  _backend_shutdown()
}

// --- Buffers

// Create a GPU buffer and return a handle to it
gpu_buffer_create :: proc(size: u64, type: BufferType, flags: BufferFlags) -> BufferHandle {
  return _gpu_buffer_create(size, type, flags)
}

// Release a GPU buffer and remove it from the resource pool
gpu_buffer_destroy :: proc(handle: BufferHandle) {
  _gpu_buffer_destroy(handle)
}

// Upload data to a GPU buffer
gpu_buffer_upload :: proc(handle: BufferHandle, data: []u8) {
  _gpu_buffer_upload(handle, data)
}

// --- Textures

gpu_texture_create :: proc(desc: TextureDesc, create_view: bool, data: []u8) -> TextureHandle {
  return _gpu_texture_create(desc, create_view, data)
}

gpu_texture_alloc :: proc() -> (^GPU_Texture, TextureHandle) {
  return _gpu_texture_alloc()
}

gpu_texture_destroy :: proc(handle: TextureHandle) {
  _gpu_texture_destroy(handle)
}

// --- Render commands

CmdEncoder :: struct {}
CmdBuffer :: struct {}

bind_pipeline :: proc(pipeline: PipelineHandle) {
  unimplemented()
}

encode_set_vertex_buf :: proc(enc: ^CmdEncoder, buffer: BufferHandle) {
  unimplemented()
}

encode_set_index_buf :: proc(enc: ^CmdEncoder, buffer: BufferHandle) {
  unimplemented()
}

encode_draw_tris :: proc(enc: ^CmdEncoder, count: u64) {
  unimplemented()
}

encode_draw_indexed_tris :: proc(enc: ^CmdEncoder, index_count: u64) {
  unimplemented()
}

renderpass_run :: proc(rpass: ^Renderpass, recording: proc(encoder: ^CmdEncoder)) -> CmdBuffer {
  unimplemented()
}

renderpass_submit :: proc(cmd_buf: CmdBuffer) {
  unimplemented()
}

// --- Frame cycle

gpu_frame_start :: proc() {
  unimplemented()
}

gpu_frame_end :: proc() {
  unimplemented()
}