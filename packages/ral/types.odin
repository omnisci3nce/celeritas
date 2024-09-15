// Backend-agnostic types used within RAL

package ral

// A unique handle to a `GPU_Buffer` resource allocated on a pool
BufferHandle :: distinct u64

// A unique handle to a `GPU_Texture` resource allocated on a pool
TextureHandle :: distinct u64

PipelineHandle :: distinct u64

RenderpassInfo :: struct {
  // TODO: color targets
  // TODO: maybe depth target
}

// Data required to create a [Pipeline] used for rendering
GraphicsPipelineDesc :: struct {
  label: string,
  vertex_desc: VertexDescription,
  // TODO: shaders
  shader_layouts: []ShaderDataLayout

}

BufferType :: enum {
	Vertex,
	Index,
	Uniform,
}

BufferUsage :: enum {
  // GPU-only memory. Cannot be read from the CPU-side
	DeviceLocal,
  // Host (CPU) visible. Can be read from the CPU-side but has slower performance for GPU operations
  Shared
}

TextureType :: enum {
  Tex2D,
  Tex3D,
  Tex2DArray,
  TexCubeMap
}

TextureFormat :: enum {
  RGBA_UNORM_8888,
  RGB_UNORM_888,
  DepthDefault
}

TextureDesc :: struct {
  type: TextureType,
  format: TextureFormat,
  extents: [2]u32,
  num_channels: u32
}

PrimitiveTopology :: enum {
  Point,
  Line,
  LineStrip,
  Triangle,
  TriangleStrip
}

CullMode :: enum {
  BackFace,
  FrontFace
}

Winding :: enum {
  CCW, // Counter clockwise
  CW   // Clockwise
}

CompareFunc :: enum {
  Never,
  Less,
  Equal,
  LessEqual,
  Greater,
  NotEqual,
  GreaterEqual,
  Always
}

// --- Vertex Attributes

VertexAttribKind :: enum {
  F32,
  F32x2,
  F32x3,
  F32x4,
  U32,
  U32x2,
  U32x3,
  U32x4,
  I32,
  I32x2,
  I32x3,
  I32x4,
}

VertexAttrib :: struct {
  label: string,
  kind: VertexAttribKind
}

VertexDescription :: struct {
  label: string,
  attributes: []VertexAttrib,
}

// --- Shaders

ShaderVisibility :: enum {
  Vertex,
  Fragment,
  Compute
}

// Bitflags for the shader stages this data should be accessible from
ShaderVisSet :: bit_set[ShaderVisibility]

ShaderBinding :: struct {
  label: string,
  visibility: ShaderVisSet,
  data: union {
    Bytes_Data,
    Buffer_Data,
    Texture_Data
  }
}

Bytes_Data :: struct {}
Buffer_Data :: struct {}
Texture_Data :: struct {}

ShaderDataLayout :: struct {
  bindings: []ShaderBinding
}

// Example code for the purposes of API brainstorming

// import "base:runtime"
// import v "core:mem/virtual"
// import "core:math/linalg"

// PBR_Params :: struct {
//   albedo: linalg.Vector3f32,
//   metallic: f32,
//   roughness: f32,
//   ambient_occlusion: f32
// }

// // we need to figure out from this, how to bind it to a buffer ?

// generate_shader_data_layout :: proc(arena: ^v.Arena, struct_data: $T) -> ShaderDataLayout {
//   return ShaderDataLayout{
//     // bindings = ..
//   }
// }

// _try_gen_bindings :: proc(arena: ^v.Arena, v: any) -> []ShaderBinding {
//   ti := runtime.type_info_core(type_info_of(v.id))

//   #partial switch info in ti.variant {
//     case runtime.Type_Info_Struct:
//      return _bindings_for_struct(arena, v, info)
//     case: 
//       panic("Shaders can only be provided structs at the moment")
//   }
// }

// _bindings_for_struct :: proc(arena: ^v.Arena, v: any, info: runtime.Type_Info_Struct) -> []ShaderBinding {
//   // loop over each field

//   return nil
// }

// _binding_for_entry :: proc(v: any) -> ShaderBinding {
//   unimplemented()
// }