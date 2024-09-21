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
gpu_buffer_create :: proc(size: uint, type: BufferType, usage: BufferUsage, data: []byte) -> BufferHandle {
  return _gpu_buffer_create(size, type, usage, data)
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

encoder_create :: proc() -> CmdEncoder {
  return _encoder_create()
}

encoder_begin :: proc(enc: ^CmdEncoder) {
  unimplemented()
}

encoder_finish :: proc(enc: ^CmdEncoder) -> CmdBuffer {
  unimplemented()
}

bind_pipeline :: proc(enc: ^CmdEncoder, pipeline: PipelineHandle) {
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
  encoder := encoder_create()

  // 2. Begin "renderpass"
  renderpass_begin(&encoder, rpass)

  // 3. Run the user provided function that records rendering commands
  recording(&encoder)

  // 4. Finalise the command encoder turning it into a `CmdBuffer` ready to be submit on a Queue
  renderpass_finish(&encoder)

  // NOTE: we don't need to worry about resetting the Command Buffer because at the beginning of every frame we will
  //       reset the whole Command Pool
  unimplemented()
}

renderpass_begin :: proc(enc: ^CmdEncoder, rpass: RenderpassInfo) {
  _renderpass_begin(enc, rpass)
}

renderpass_finish :: proc(enc: ^CmdEncoder) {
  _renderpass_finish(enc)
}

// --- Frame cycle

frame_start :: proc() {
  _frame_start()
}

frame_end :: proc() {
  _frame_end()
}