package ral

import NS "core:sys/darwin/Foundation"
import MTL "vendor:darwin/Metal"
import CA "vendor:darwin/QuartzCore"
import "vendor:glfw"

MetalCtx :: struct {
	ns_window: ^NS.Window,
	device:    ^MTL.Device,
	cmd_queue: ^MTL.CommandQueue,
	swapchain: ^CA.MetalLayer,
}

// Global Metal backend context
ctx: MetalCtx

when GPU_API == .Metal {
	GPU_Buffer :: struct {}

	GPU_Texture :: struct {}

	_backend_init :: proc(window: glfw.WindowHandle) {
		// Create device
		ctx.device = MTL.CreateSystemDefaultDevice()
		// Create command queue
		ctx.cmd_queue = MTL.Device_newCommandQueue(ctx.device)
		ctx.swapchain = CA.MetalLayer.layer()
		ctx.swapchain->setDevice(ctx.device)
		ctx.swapchain->setPixelFormat(.BGRA8Unorm_sRGB)
		ctx.swapchain->setFramebufferOnly(true)

		ctx.ns_window = glfw.GetCocoaWindow(window)
		ctx->ns_window->contentView()->setLayer(ctx.swapchain)
		ctx->ns_window->contentView()->setWantsLayer(true)

	}

	_backend_shutdown :: proc() {
		unimplemented()
	}

	_gpu_buffer_create :: proc(size: u64, type: BufferType, flags: BufferFlags) -> BufferHandle {
		// return GPU_Buffer{/* TODO: actually call vulkan and return the handle */ }
		return 1
	}

	_gpu_buffer_destroy :: proc(handle: BufferHandle) {
		unimplemented()
	}

	_gpu_buffer_upload :: proc(handle: BufferHandle, data: []u8) {
		unimplemented()
	}

	_gpu_texture_create :: proc(
		desc: TextureDesc,
		create_view: bool,
		data: []u8,
	) -> TextureHandle {
		unimplemented()
	}

	_gpu_texture_alloc :: proc() -> (^GPU_Texture, TextureHandle) {
		unimplemented()
	}

	_gpu_texture_destroy :: proc(handle: TextureHandle) {
		unimplemented()
	}
}
