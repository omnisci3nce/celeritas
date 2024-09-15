//+build windows, linux
package ral

import "../../deps/vkb"
import "../utils"
import "vendor:glfw"
import vk "vendor:vulkan"

MAX_FRAMES_IN_FLIGHT :: 2
MINIMUM_API_VERSION :: vk.API_VERSION_1_3

@(private)
VulkanCtx :: struct {
	instance:          ^vkb.Instance,
	surface:           vk.SurfaceKHR,
	physical_device:   ^vkb.Physical_Device,
	// Logical Device
	device:            ^vkb.Device,
	default_swapchain: ^vkb.Swapchain,

	/* Pools */
	pipelines:         utils.Pool(Pipeline),
	buffers:           utils.Pool(GPU_Buffer),
	textures:          utils.Pool(GPU_Texture),
}

ctx: VulkanCtx

GeneralError :: enum {
	None,
	GLFWError,
	Vulkan_Error,
}

VkBackendError :: union #shared_nil {
	// TODO: GeneralError, resource error (?)
	GeneralError,
	vkb.Error,
}

Renderpass :: struct {}

// Graphics Pipeline
Pipeline :: struct {}

// TODO: ComputePipeline

GPU_Buffer :: struct {
	handle: vk.Handle,
	memory: vk.DeviceMemory,
	size:   u64,
}

GPU_Texture :: struct {
	handle: vk.Image,
	memory: vk.DeviceMemory,
	size:   u64,
}

_backend_init :: proc(window: glfw.WindowHandle) -> (err: VkBackendError) {
	instance_builder, instance_builder_err := vkb.init_instance_builder()
	if instance_builder_err != nil do return
	defer vkb.destroy_instance_builder(&instance_builder)

	// Enable `VK_LAYER_KHRONOS_validation` layer
	vkb.instance_request_validation_layers(&instance_builder)
	vkb.instance_use_default_debug_messenger(&instance_builder)

	// TODO: other extensions

	// Create VkInstance (https://registry.khronos.org/vulkan/specs/1.3-extensions/man/html/VkInstance.html)
	ctx.instance = vkb.build_instance(&instance_builder) or_return
	defer if err != nil do vkb.destroy_instance(ctx.instance)

	glfw_err := glfw.CreateWindowSurface(ctx.instance.ptr, window, nil, &ctx.surface)
	if glfw_err != .SUCCESS {
		return .GLFWError
	}

	// Create VkPhysicalDevice (https://registry.khronos.org/vulkan/specs/1.3-extensions/man/html/VkPhysicalDevice.html)
	selector := vkb.init_physical_device_selector(ctx.instance) or_return
	defer vkb.destroy_physical_device_selector(&selector)

	vkb.selector_set_minimum_version(&selector, MINIMUM_API_VERSION)
	vkb.selector_set_surface(&selector, ctx.surface)

	ctx.physical_device = vkb.select_physical_device(&selector) or_return
	defer if err != nil do vkb.destroy_physical_device(ctx.physical_device)

	// Create VkDevice (https://registry.khronos.org/vulkan/specs/1.3-extensions/man/html/VkDevice.html)
	device_builder, device_builder_err := vkb.init_device_builder(ctx.physical_device)
	if device_builder_err != nil do return // error
	defer vkb.destroy_device_builder(&device_builder)

	// Create VkSwapchainKHR (https://registry.khronos.org/vulkan/specs/1.3-extensions/man/html/VkSwapchainKHR.html)
	swapchain_builder, swapchain_builder_err := vkb.init_swapchain_builder(ctx.device)
	if swapchain_builder_err != nil do return // error
	defer vkb.destroy_swapchain_builder(&swapchain_builder)

	ctx.default_swapchain = vkb.build_swapchain(&swapchain_builder) or_return // default is 888 SRGB colorspace, Mailbox present mode.
	if err != nil do return // error

	ctx.buffers = utils.pool_create(GPU_Buffer, 256)

	return
}

_backend_shutdown :: proc() {
	unimplemented()
}

_gpu_buffer_create :: proc(size: uint, type: BufferType, usage: BufferUsage) -> BufferHandle {
	// return GPU_Buffer{/* TODO: actually call vulkan and return the handle */ }
	return 1
}

_gpu_buffer_destroy :: proc(handle: BufferHandle) {
	unimplemented()
}

_gpu_buffer_upload :: proc(handle: BufferHandle, data: []u8) {
	unimplemented()
}

_gpu_texture_create :: proc(desc: TextureDesc, create_view: bool, data: []u8) -> TextureHandle {
	unimplemented()
}

_gpu_texture_alloc :: proc() -> (^GPU_Texture, TextureHandle) {
	unimplemented()
}

_gpu_texture_destroy :: proc(handle: TextureHandle) {
	unimplemented()
}

_pipeline_create :: proc(desc: GraphicsPipelineDesc) -> PipelineHandle {
	unimplemented()
}
