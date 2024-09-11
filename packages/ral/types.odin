package ral

// A unique handle to a `GPU_Buffer` resource allocated on a pool
BufferHandle :: distinct u64

// A unique handle to a `GPU_Texture` resource allocated on a pool
TextureHandle :: distinct u64

PipelineHandle :: distinct u64

Renderpass :: struct {
  // TODO
}

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