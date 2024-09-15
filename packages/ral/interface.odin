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
gpu_buffer_create :: proc(size: uint, type: BufferType, usage: BufferUsage) -> BufferHandle {
  return _gpu_buffer_create(size, type, usage)
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

// --- Backend resources

pipeline_create :: proc(desc: GraphicsPipelineDesc) -> PipelineHandle {
  return _pipeline_create(desc)
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

encode_draw_primitives :: proc(enc: ^CmdEncoder, primitive: PrimitiveTopology, count: u64) {
  unimplemented()
}

encode_draw_tris :: proc(enc: ^CmdEncoder, count: u64) {
  encode_draw_primitives(enc, .Triangle, count)
}

encode_draw_indexed_tris :: proc(enc: ^CmdEncoder, index_count: u64) {
  unimplemented()
}

renderpass_run :: proc(rpass: RenderpassInfo, recording: proc(encoder: ^CmdEncoder)) -> CmdBuffer {
  // 1. Create the command encoder

  // 2. Run the user provided function that records rendering commands

  // 3. Finalise the command encoder turning it into a `CmdBuffer` ready to be submit on a Queue

  unimplemented()
}

// --- Frame cycle

gpu_frame_start :: proc() {
  unimplemented()
}

gpu_frame_end :: proc() {
  unimplemented()
}