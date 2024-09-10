// Render Abstraction Layer - this is a thin layer that smoothes over differences between Graphics APIs.

package ral

import "core:mem"
import "vendor:glfw"
import vk "vendor:vulkan"

// The backends supported by Celeritas
APIBackend :: enum {
    Vulkan,
}

// TEMP: hardcoded for now as we don't actually do *anything* yet
GPU_API :: APIBackend.Vulkan

BufferType :: enum {
	Vertex,
	Index,
	Uniform,
}

BufferFlag :: enum {
	CPU,
	GPU,
	Storage,
}

BufferFlags :: bit_set[BufferFlag]

// A unique handle to a `GPU_Buffer` allocated on a pool
BufferHandle :: distinct u64

// Initialise the RAL backend
backend_init :: proc(window: glfw.WindowHandle) {
    _backend_init(window)
}

// Create a GPU-backed buffer
gpu_buffer_create :: proc(size: u64, type: BufferType, flags: BufferFlags) -> GPU_Buffer {
	return _gpu_buffer_create(size, type, flags)
}

when GPU_API == .Vulkan {
	GPU_Buffer :: struct {
		handle: vk.Handle,
	}

	_backend_init :: proc (window: glfw.WindowHandle) {
	    // TODO: VkApplicationInfo
	    // TODO: VkInstanceCreateInfo
	    // TODO: extensions
		// TODO: create logical device
		// TODO: create physical device
		// TODO: create swapchain
	}

	_gpu_buffer_create :: proc(size: u64, type: BufferType, flags: BufferFlags) -> GPU_Buffer {
		return GPU_Buffer{/* TODO: actually call vulkan and return the handle */ }
	}
}
