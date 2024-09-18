//+build windows, linux
package ral

import "../../deps/vkb"
import "../utils"
import "core:fmt"
import "core:os"
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
	command_pool:      vk.CommandPool,

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

// Graphics Pipeline
Pipeline :: struct {
	handle: vk.Pipeline,
	layout: vk.PipelineLayout,
}

// TODO: ComputePipeline

GPU_Buffer :: struct {
	handle: vk.Buffer,
	memory: vk.DeviceMemory,
	size:   u64,
}

GPU_Texture :: struct {
	handle: vk.Image,
	memory: vk.DeviceMemory,
	size:   u64,
}

CmdEncoder :: struct {
	cmd_buffer:      vk.CommandBuffer,
	descriptor_pool: ^vk.DescriptorPool,
	pipeline:        ^Pipeline,
}
CmdBuffer :: struct {
	cmd_buffer: vk.CommandBuffer,
}

_backend_init :: proc(window: glfw.WindowHandle) -> (err: VkBackendError) {
	fmt.println("Vulkan backend init")
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

	fmt.println("Selecting a Physical Device...")
	ctx.physical_device = vkb.select_physical_device(&selector) or_return
	defer if err != nil do vkb.destroy_physical_device(ctx.physical_device)

	// Create VkDevice (https://registry.khronos.org/vulkan/specs/1.3-extensions/man/html/VkDevice.html)
	device_builder, device_builder_err := vkb.init_device_builder(ctx.physical_device)
	if device_builder_err != nil do return // error
	defer vkb.destroy_device_builder(&device_builder)

	fmt.println("Creating Logical Device...")
	ctx.device = vkb.build_device(&device_builder) or_return

	// Create VkSwapchainKHR (https://registry.khronos.org/vulkan/specs/1.3-extensions/man/html/VkSwapchainKHR.html)
	swapchain_builder, swapchain_builder_err := vkb.init_swapchain_builder(ctx.device)
	if swapchain_builder_err != nil do return // error
	defer vkb.destroy_swapchain_builder(&swapchain_builder)

	ctx.default_swapchain = vkb.build_swapchain(&swapchain_builder) or_return // default is 888 SRGB colorspace, Mailbox present mode.
	if err != nil do return // error

	ctx.buffers = utils.pool_create(GPU_Buffer, 256)

	// Create VkCommandPool
	pool_create_info := vk.CommandPoolCreateInfo {
		sType = .COMMAND_POOL_CREATE_INFO,
		queueFamilyIndex = 1, // FIXME
		flags = vk.CommandPoolCreateFlags{.RESET_COMMAND_BUFFER}
	}

	res := vk.CreateCommandPool(ctx.device.ptr, &pool_create_info, nil, &ctx.command_pool)

	return
}

_backend_shutdown :: proc() {
	unimplemented()
}

_gpu_buffer_create :: proc(size: uint, type: BufferType, usage: BufferUsage, data: []byte) -> BufferHandle {
	fmt.println("Create buffer")
	usage_flags: vk.BufferUsageFlags
	usage_flags += {.TRANSFER_SRC, .TRANSFER_DST, .STORAGE_BUFFER}

	buffer_info := vk.BufferCreateInfo {
		sType = .BUFFER_CREATE_INFO,
		size = vk.DeviceSize(size),
		usage = usage_flags,
		sharingMode = .EXCLUSIVE,
	}

	handle, buf := utils.pool_alloc(&ctx.buffers)

	res := vk.CreateBuffer(ctx.device.ptr, &buffer_info, nil, &buf.handle)
	if res != .SUCCESS {
		fmt.eprintln("VkCreateBuffer failed")
	}
	// TODO: error handling

	mem_reqs: vk.MemoryRequirements
	vk.GetBufferMemoryRequirements(ctx.device.ptr, buf.handle, &mem_reqs)

	memory_info := vk.MemoryAllocateInfo {
		sType = .MEMORY_ALLOCATE_INFO,
		allocationSize = mem_reqs.size,
		memoryTypeIndex = 1
		// TODO: memoryTypeIndex
	}

	res = vk.AllocateMemory(ctx.device.ptr, &memory_info, nil, &buf.memory)
	res = vk.BindBufferMemory(ctx.device.ptr, buf.handle, buf.memory, vk.DeviceSize(0))

	// If the user provided data, we can upload it now
	if data != nil {
		fmt.println("Upload data as part of buffer creation")
	}

	return BufferHandle(handle)
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

_encoder_create :: proc() -> CmdEncoder {
	command_buffer: vk.CommandBuffer

	allocate_info := vk.CommandBufferAllocateInfo {
		sType              = .COMMAND_BUFFER_ALLOCATE_INFO,
		pNext              = nil,
		commandPool        = ctx.command_pool,
		level              = .PRIMARY,
		commandBufferCount = 1,
	}

	res := vk.AllocateCommandBuffers(ctx.device.ptr, &allocate_info, &command_buffer)
	if res != .SUCCESS {
		fmt.eprintln("Failed to allocate command buffer from pool")
		os.exit(1)
	}

	return CmdEncoder {
		cmd_buffer      = command_buffer,
		descriptor_pool = nil, // FIXME
		pipeline        = nil, // FIXME
	}
}

_frame_start :: proc() {
	res := vk.ResetCommandPool(ctx.device.ptr, ctx.command_pool, {})
}

_frame_end :: proc() {
	vk.DeviceWaitIdle(ctx.device.ptr)
}
