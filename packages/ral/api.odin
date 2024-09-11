package ral

import "vendor:glfw"

// Initialise the RAL backend
backend_init :: proc(window: glfw.WindowHandle) {
  _backend_init(window)
}

backend_shutdown:: proc() {
  _backend_shutdown()
}

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