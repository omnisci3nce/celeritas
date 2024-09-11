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