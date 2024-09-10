package ral

import "core:mem"
import vk "vendor:vulkan"

// Render Abstraction Layer - this is a thin layer that smoothes over differences between Graphics APIs.

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
backend_init :: proc() {}

// Create a GPU-backed buffer
gpu_buffer_create :: proc(size: u64, type: BufferType, flags: BufferFlags) -> GPU_Buffer {
	return _gpu_buffer_create(size, type, flags)
}

when GPU_API == .Vulkan {
	GPU_Buffer :: struct {
		handle: vk.Handle,
	}

	_gpu_buffer_create :: proc(size: u64, type: BufferType, flags: BufferFlags) -> GPU_Buffer {
		return GPU_Buffer{/* TODO: actually call vulkan and return the handle */ }
	}
}

// NOTE(omni): this is just to make it compile with 'odin build packages/ral' until I figure out how build system stuff
//						 works
main :: proc () -> int {
	return 0
}
