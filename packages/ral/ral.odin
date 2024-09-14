// Render Abstraction Layer - this is a thin layer that smoothes over differences between Graphics APIs.

package ral

import "core:mem"
import "vendor:glfw"
import vk "vendor:vulkan"

// The backends currently supported by Celeritas
APIBackend :: enum {
	Vulkan,
	Metal,
}

GPU_API :: APIBackend.Vulkan

// Set RAL backend based on Operating System
// when ODIN_OS == .Darwin {
// 	GPU_API :: APIBackend.Metal
// } else {
// 	GPU_API :: APIBackend.Vulkan
// }
// TODO: Figure out how to get the above to work. Other files can't pick up the GPU_API constant...
