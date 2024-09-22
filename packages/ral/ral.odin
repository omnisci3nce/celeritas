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

// --- Common (may move this later)

vertex_attrib_size :: proc(kind: VertexAttribKind) -> int {
	switch kind {
			case .F32:
			case .U32:
			case .I32:
				return 4
			case .F32x2:
			case .U32x2:
			case .I32x2:
				return 8
			case .F32x3:
			case .U32x3:
			case .I32x3:
				return 12
			case .F32x4:
			case .U32x4:
			case .I32x4:
				return 16
	}
	return 16
}