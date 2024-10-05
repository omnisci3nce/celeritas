//+build windows, linux
package ral

import "../../deps/vkb"
import "../utils"
import "core:fmt"
import "core:mem"
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
	device:            ^vkb.Device, // Logical Device
	default_swapchain: ^vkb.Swapchain,
	command_pool:      vk.CommandPool,
	/* Queues */
	graphics_queue:    vk.Queue,
	present_queue:     vk.Queue,
	/* Pools */
	pipelines:         utils.Pool(Pipeline),
	buffers:           utils.Pool(GPU_Buffer),
	textures:          utils.Pool(GPU_Texture),
	/* Sync objects */

	// TEMP
	renderpass:        vk.RenderPass,
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

	// Do I actually need this? I got it from someone else
	get_proc_address :: proc(p: rawptr, name: cstring) {
		(cast(^rawptr)p)^ = glfw.GetInstanceProcAddress((^vk.Instance)(&ctx.instance.ptr)^, name)
	}

	instance_builder, instance_builder_err := vkb.init_instance_builder()
	if instance_builder_err != nil do return
	defer vkb.destroy_instance_builder(&instance_builder)

	vkb.instance_set_minimum_version(&instance_builder, vk.API_VERSION_1_3)
	// Enable `VK_LAYER_KHRONOS_validation` layer
	vkb.instance_request_validation_layers(&instance_builder)
	vkb.instance_use_default_debug_messenger(&instance_builder)

	vkb.instance_enable_extension(&instance_builder, "VK_KHR_get_physical_device_properties2")

	// Create VkInstance (https://registry.khronos.org/vulkan/specs/1.3-extensions/man/html/VkInstance.html)
	ctx.instance = vkb.build_instance(&instance_builder) or_return
	defer if err != nil do vkb.destroy_instance(ctx.instance)

	vk.load_proc_addresses(get_proc_address)

	glfw_err := glfw.CreateWindowSurface(ctx.instance.ptr, window, nil, &ctx.surface)
	if glfw_err != .SUCCESS {
		return .GLFWError
	}

	// Create VkPhysicalDevice (https://registry.khronos.org/vulkan/specs/1.3-extensions/man/html/VkPhysicalDevice.html)
	selector := vkb.init_physical_device_selector(ctx.instance) or_return
	defer vkb.destroy_physical_device_selector(&selector)

	dynamic_rendering_features := vk.PhysicalDeviceDynamicRenderingFeaturesKHR {
		sType            = .PHYSICAL_DEVICE_DYNAMIC_RENDERING_FEATURES,
		dynamicRendering = true,
	}

	vkb.selector_set_minimum_version(&selector, MINIMUM_API_VERSION)
	vkb.selector_set_surface(&selector, ctx.surface)
	// vkb.selector_add_required_extension(&selector, "VK_KHR_dynamic_rendering")
	vkb.selector_add_required_extension_features(&selector, dynamic_rendering_features)

	fmt.println("Selecting a Physical Device...")
	ctx.physical_device = vkb.select_physical_device(&selector) or_return
	defer if err != nil do vkb.destroy_physical_device(ctx.physical_device)

	// Create VkDevice (https://registry.khronos.org/vulkan/specs/1.3-extensions/man/html/VkDevice.html)
	device_builder, device_builder_err := vkb.init_device_builder(ctx.physical_device)
	if device_builder_err != nil do return // error
	defer vkb.destroy_device_builder(&device_builder)

	fmt.println("Creating Logical Device...")
	ctx.device = vkb.build_device(&device_builder) or_return

	// TODO: Move this to a separate swapchain_create function!
	// Create VkSwapchainKHR (https://registry.khronos.org/vulkan/specs/1.3-extensions/man/html/VkSwapchainKHR.html)
	swapchain_builder, swapchain_builder_err := vkb.init_swapchain_builder(ctx.device)
	if swapchain_builder_err != nil do return // error
	defer vkb.destroy_swapchain_builder(&swapchain_builder)

	vkb.swapchain_builder_use_default_format_selection(&swapchain_builder) // default is 8888 SRG Nonlinear
	vkb.swapchain_builder_set_present_mode(&swapchain_builder, .FIFO) // limit FPS to speed of monitor

	ctx.default_swapchain = vkb.build_swapchain(&swapchain_builder) or_return
	if err != nil do return // error

	ctx.graphics_queue, err = vkb.device_get_queue(ctx.device, .Graphics)
	ctx.present_queue, err = vkb.device_get_queue(ctx.device, .Present)

	ctx.pipelines = utils.pool_create(Pipeline, 128)
	ctx.buffers = utils.pool_create(GPU_Buffer, 1024)
	ctx.textures = utils.pool_create(GPU_Texture, 1024)

	// Create VkCommandPool
	pool_create_info := vk.CommandPoolCreateInfo {
		sType            = .COMMAND_POOL_CREATE_INFO,
		queueFamilyIndex = 1, // FIXME
		flags            = vk.CommandPoolCreateFlags{.RESET_COMMAND_BUFFER},
	}

	res := vk.CreateCommandPool(ctx.device.ptr, &pool_create_info, nil, &ctx.command_pool)

	return
}

_backend_shutdown :: proc() {
	unimplemented()
}

find_memory_index :: proc(type_filter: u32, desired_flags: vk.MemoryPropertyFlags) -> int {
	memory_properties: vk.PhysicalDeviceMemoryProperties
	vk.GetPhysicalDeviceMemoryProperties(ctx.physical_device.ptr, &memory_properties)

	for i in 0 ..= memory_properties.memoryTypeCount {
		anded := memory_properties.memoryTypes[i].propertyFlags & desired_flags
		equivalent := anded == desired_flags
		if ((type_filter & (1 << i) != 0) && equivalent) {
			return int(i)
		}
	}

	fmt.eprintln("Unable to find suitable memory type")
	return -1
}

_gpu_buffer_create :: proc(size: uint, type: BufferType, usage: BufferUsage, data: rawptr) -> BufferHandle {
	fmt.println("Create buffer")
	usage_flags: vk.BufferUsageFlags
	usage_flags += {.TRANSFER_SRC, .TRANSFER_DST, .STORAGE_BUFFER}

	buffer_info := vk.BufferCreateInfo {
		sType       = .BUFFER_CREATE_INFO,
		size        = vk.DeviceSize(size),
		usage       = usage_flags,
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
		sType           = .MEMORY_ALLOCATE_INFO,
		allocationSize  = mem_reqs.size,
		memoryTypeIndex = u32(
			find_memory_index(mem_reqs.memoryTypeBits, {.DEVICE_LOCAL, .HOST_VISIBLE, .HOST_COHERENT}), // just grab all the flags we might need. the perf difference for our needs will be inconsequential
		),
		// TODO: memoryTypeIndex
	}

	res = vk.AllocateMemory(ctx.device.ptr, &memory_info, nil, &buf.memory)
	res = vk.BindBufferMemory(ctx.device.ptr, buf.handle, buf.memory, vk.DeviceSize(0))

	// If the user provided data, we can upload it now
	if data != nil {
		fmt.println("Upload data as part of buffer creation")

		data_ptr: rawptr

		vk.MapMemory(ctx.device.ptr, buf.memory, vk.DeviceSize(0), vk.DeviceSize(size), vk.MemoryMapFlags{}, &data_ptr)
		fmt.printfln("Uploading %d bytes", size)
		mem.copy(data_ptr, data, int(size))
		// vk.UnmapMemory(ctx.device.ptr, buf.memory)
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

// Convert a RAL vertex attribute into a vulkan type
vk_format_from_vertex_attr :: proc(kind: VertexAttribKind) -> vk.Format {
	switch kind {
	case .F32:
		return .R32_SFLOAT
	case .U32:
		return .R32_UINT
	case .I32:
		return .R32_SINT
	case .F32x2:
		return .R32G32_SFLOAT
	case .U32x2:
		return .R32G32_UINT
	case .I32x2:
		return .R32G32_SINT
	case .F32x3:
		return .R32G32B32_SFLOAT
	case .U32x3:
		return .R32G32B32_UINT
	case .I32x3:
		return .R32G32B32_SINT
	case .F32x4:
		return .R32G32B32A32_SFLOAT
	case .U32x4:
		return .R32G32B32A32_UINT
	case .I32x4:
		return .R32G32B32A32_SINT
	case:
		return .R32G32B32A32_SFLOAT
	}
}

// Takes SPIR-V and creates a Vulkan ShaderModule for it
create_shader_module :: proc(spv: []u8) -> vk.ShaderModule {
	fmt.printfln("Shader module size %d bytes", len(spv))
	create_info := vk.ShaderModuleCreateInfo {
		sType    = .SHADER_MODULE_CREATE_INFO,
		codeSize = len(spv),
		pCode    = cast(^u32)raw_data(spv),
	}

	shader_mod: vk.ShaderModule
	vk.CreateShaderModule(ctx.device.ptr, &create_info, nil, &shader_mod)
	// TODO: error handling
	return shader_mod
}

create_render_pass :: proc() {
	color_attachment: vk.AttachmentDescription
	color_attachment.format = .R8G8B8A8_SRGB
	color_attachment.samples = {._1}
	color_attachment.loadOp = .CLEAR
	color_attachment.storeOp = .STORE
	color_attachment.stencilLoadOp = .DONT_CARE
	color_attachment.stencilStoreOp = .DONT_CARE
	color_attachment.initialLayout = .UNDEFINED
	color_attachment.finalLayout = .PRESENT_SRC_KHR

	color_attachment_ref: vk.AttachmentReference
	color_attachment_ref.attachment = 0
	color_attachment_ref.layout = .COLOR_ATTACHMENT_OPTIMAL

	subpass: vk.SubpassDescription
	subpass.pipelineBindPoint = .GRAPHICS
	subpass.colorAttachmentCount = 1
	subpass.pColorAttachments = &color_attachment_ref

	dependency: vk.SubpassDependency
	dependency.srcSubpass = vk.SUBPASS_EXTERNAL
	dependency.dstSubpass = 0
	dependency.srcStageMask = {.COLOR_ATTACHMENT_OUTPUT}
	dependency.srcAccessMask = {}
	dependency.dstStageMask = {.COLOR_ATTACHMENT_OUTPUT}
	dependency.dstAccessMask = {.COLOR_ATTACHMENT_WRITE}

	render_pass_info: vk.RenderPassCreateInfo
	render_pass_info.sType = .RENDER_PASS_CREATE_INFO
	render_pass_info.attachmentCount = 1
	render_pass_info.pAttachments = &color_attachment
	render_pass_info.subpassCount = 1
	render_pass_info.pSubpasses = &subpass
	render_pass_info.dependencyCount = 1
	render_pass_info.pDependencies = &dependency

	if res := vk.CreateRenderPass(ctx.device.ptr, &render_pass_info, nil, &ctx.renderpass); res != .SUCCESS {
		fmt.eprintf("Error: Failed to create render pass!\n")
		os.exit(1)
	}
}

_pipeline_create :: proc(desc: GraphicsPipelineDesc) -> PipelineHandle {
	fmt.printfln("Create pipeline %s", desc.label)

	// Vertex attributes
	vertex_attributes := make([]vk.VertexInputAttributeDescription, len(desc.vertex_desc.attributes))
	// FIXME: defer delete(vertex_attributes)

	offset := 0
	for attr, attr_idx in desc.vertex_desc.attributes {
		vertex_attributes[attr_idx].binding = 0
		vertex_attributes[attr_idx].location = u32(attr_idx)
		vertex_attributes[attr_idx].format = vk_format_from_vertex_attr(attr.kind)
		vertex_attributes[attr_idx].offset = u32(offset)

		// Move offset forwards
		offset += vertex_attrib_size(attr.kind)
	}

	// Vertex input
	vertex_binding_desc := []vk.VertexInputBindingDescription{{binding = 0, inputRate = .VERTEX}}

	vertex_input_info := vk.PipelineVertexInputStateCreateInfo {
		sType                           = .PIPELINE_VERTEX_INPUT_STATE_CREATE_INFO,
		vertexBindingDescriptionCount   = 1,
		pVertexBindingDescriptions      = raw_data(vertex_binding_desc),
		vertexAttributeDescriptionCount = u32(len(vertex_attributes)),
		pVertexAttributeDescriptions    = raw_data(vertex_attributes),
	}

	input_assembly := vk.PipelineInputAssemblyStateCreateInfo {
		sType                  = .PIPELINE_INPUT_ASSEMBLY_STATE_CREATE_INFO,
		topology               = .TRIANGLE_LIST, // TODO: get this from our PrimitiveTopology enum
		primitiveRestartEnable = false,
	}

	// Dynamic State

	dynamic_states: [4]vk.DynamicState = {
		vk.DynamicState.VIEWPORT,
		vk.DynamicState.SCISSOR,
		vk.DynamicState.BLEND_CONSTANTS,
		vk.DynamicState.STENCIL_REFERENCE,
	}

	dynamic_state_info := vk.PipelineDynamicStateCreateInfo {
		sType             = .PIPELINE_DYNAMIC_STATE_CREATE_INFO,
		dynamicStateCount = 4,
		pDynamicStates    = raw_data(&dynamic_states),
	}

	// Viewport
	viewport_state := vk.PipelineViewportStateCreateInfo {
		sType         = .PIPELINE_VIEWPORT_STATE_CREATE_INFO,
		viewportCount = 1,
		scissorCount  = 1,
		// NOTE: We don't need to specify a viewport size here as we will be enabling them as dynamic state
	}

	multisample_info := vk.PipelineMultisampleStateCreateInfo {
		sType                = .PIPELINE_MULTISAMPLE_STATE_CREATE_INFO,
		minSampleShading     = 1.0,
		rasterizationSamples = {._1},
	}

	color_blends: [1]vk.PipelineColorBlendAttachmentState
	color_blends[0] = vk.PipelineColorBlendAttachmentState {
		srcColorBlendFactor = .SRC_ALPHA,
		dstColorBlendFactor = .ONE_MINUS_DST_ALPHA,
		colorBlendOp        = .ADD,
		srcAlphaBlendFactor = .SRC_ALPHA,
		dstAlphaBlendFactor = .ONE_MINUS_SRC_ALPHA,
		alphaBlendOp        = .ADD,
		colorWriteMask      = {.R, .G, .B, .A},
	}
	blend_info := vk.PipelineColorBlendStateCreateInfo {
		sType           = .PIPELINE_COLOR_BLEND_STATE_CREATE_INFO,
		logicOpEnable   = false,
		logicOp         = .COPY,
		attachmentCount = 1,
		pAttachments    = raw_data(&color_blends),
	}

	// Rasteriser
	rasterizer_info := vk.PipelineRasterizationStateCreateInfo {
		sType                   = .PIPELINE_RASTERIZATION_STATE_CREATE_INFO,
		depthClampEnable        = false,
		depthBiasEnable         = false,
		rasterizerDiscardEnable = false,
		polygonMode             = .FILL,
		lineWidth               = 1.0,
		cullMode                = {.BACK},
		frontFace               = .COUNTER_CLOCKWISE,
	}

	// Load SPIR-V bytecode shaders
	vertex_src, vert_success := os.read_entire_file(desc.vs.path)
	fragment_src, frag_success := os.read_entire_file(desc.fs.path)
	if !vert_success {
		fmt.eprintfln("Error reading vertex shader @ %s", desc.vs.path)
		os.exit(1)
	}
	if !frag_success {
		fmt.eprintfln("Error reading fragment shader @ %s", desc.fs.path)
		os.exit(1)
	}

	// Compile shader modules
	vertex_module := create_shader_module(vertex_src)
	fragment_module := create_shader_module(fragment_src)
	// FIXME: "Unreachable defer statement due to diverging procedure call at end of the current scope"
	// defer vk.DestroyShaderModule(ctx.device.ptr, vertex_module, nil)
	// defer vk.DestroyShaderModule(ctx.device.ptr, fragment_module, nil)

	shader_stages: [2]vk.PipelineShaderStageCreateInfo
	shader_stages[0] = vk.PipelineShaderStageCreateInfo {
		sType  = .PIPELINE_SHADER_STAGE_CREATE_INFO,
		stage  = {.VERTEX},
		module = vertex_module,
		pName  = "main",
	}
	shader_stages[1] = vk.PipelineShaderStageCreateInfo {
		sType  = .PIPELINE_SHADER_STAGE_CREATE_INFO,
		stage  = {.FRAGMENT},
		module = fragment_module,
		pName  = "main",
	}


	handle, pipeline := utils.pool_alloc(&ctx.pipelines)
	fmt.println("Allocated pipeline from pool")

	pipeline_layout_info := vk.PipelineLayoutCreateInfo {
		sType                  = .PIPELINE_LAYOUT_CREATE_INFO,
		setLayoutCount         = 0,
		pSetLayouts            = nil,
		pushConstantRangeCount = 0,
		pPushConstantRanges    = nil,
	}
	p_res := vk.CreatePipelineLayout(ctx.device.ptr, &pipeline_layout_info, nil, &pipeline.layout)
	if p_res != .SUCCESS {
		fmt.eprintln("Error creating pipeline layout")
		os.exit(1)
	}

	// Dynamic Rendering
	formats := []vk.Format{.R8G8B8A8_SRGB}
	// https://lesleylai.info/en/vk-khr-dynamic-rendering/
	rendering_create_info := vk.PipelineRenderingCreateInfo {
		sType                   = .PIPELINE_RENDERING_CREATE_INFO_KHR,
		colorAttachmentCount    = 1,
		pColorAttachmentFormats = raw_data(formats),
	}

	create_render_pass()

	create_info := vk.GraphicsPipelineCreateInfo {
		sType               = .GRAPHICS_PIPELINE_CREATE_INFO,
		renderPass          = vk.RenderPass{}, // Empty since we're using dynamic rendering (it wont let us use nullptr/nil?)
		stageCount          = 2,
		pStages             = &shader_stages[0],
		pVertexInputState   = &vertex_input_info,
		pInputAssemblyState = &input_assembly,
		pViewportState      = &viewport_state,
		pRasterizationState = &rasterizer_info,
		pMultisampleState   = &multisample_info,
		pDepthStencilState  = nil, // TODO
		pColorBlendState    = &blend_info,
		pDynamicState       = &dynamic_state_info,
		pTessellationState  = nil,
		layout              = pipeline.layout,
		// subpass             = 0,
		// basePipelineHandle  = vk.Pipeline{},
		// basePipelineIndex   = -1,
		pNext               = &rendering_create_info,
	}

	fmt.println("About to create graphics pipeline")

	res := vk.CreateGraphicsPipelines(ctx.device.ptr, 0, 1, &create_info, nil, &pipeline.handle)
	if res != .SUCCESS {
		fmt.eprintln("Error creating graphics pipeline")
		os.exit(1)
	}
	fmt.println("Successfully created graphics pipeline")

	return PipelineHandle(handle)
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

_renderpass_begin :: proc(enc: ^CmdEncoder, rpass: RenderpassInfo) {
	// unimplemented()
}

_renderpass_finish :: proc(enc: ^CmdEncoder) {
	// unimplemented()
}

_frame_start :: proc() {
	res := vk.ResetCommandPool(ctx.device.ptr, ctx.command_pool, {})
}

_frame_end :: proc() {
	vk.DeviceWaitIdle(ctx.device.ptr)
}
