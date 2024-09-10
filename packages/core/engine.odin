package engine

import "core:c"
import "core:fmt"
import "vendor:glfw"
import "../ral"

WINDOW_WIDTH :: 1000
WINDOW_HEIGHT :: 1000

Engine :: struct {
    window: glfw.WindowHandle,
}

engine_init :: proc(engine: ^Engine) {
	fmt.println("Engine init")

	if !glfw.Init() {
		fmt.println("Failed to initialise GLFW")
		return
	}

	glfw.WindowHint(glfw.RESIZABLE, 0) // TODO: Make our renderer resizable on the fly
	when ral.GPU_API == .Vulkan {
		glfw.WindowHint(glfw.CLIENT_API, glfw.NO_API)
	}
	fmt.println("Created window")

	ral.backend_init(engine.window)
	fmt.println("Initialised RAL backend")

	engine.window = glfw.CreateWindow(WINDOW_WIDTH, WINDOW_WIDTH, "Celeritas Engine Test", nil, nil)
	if engine.window == nil {
		fmt.println("Unable to create window")
		return
	}

	glfw.MakeContextCurrent(engine.window)
	glfw.SwapInterval(1)
}
