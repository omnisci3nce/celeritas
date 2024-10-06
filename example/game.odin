package game

import "core:fmt"
import "core:time"
import "vendor:glfw"
import "../packages/core"
import "../packages/ral"

WINDOW_WIDTH :: 1000
WINDOW_HEIGHT :: 1000

GameData :: struct {
  cube: core.Mesh,
  // TODO: material
}

RenderData :: struct {
  tri_pipeline: ral.PipelineHandle,
  vbuf: ral.BufferHandle,
}
render_data: RenderData

game_init :: proc() -> GameData {

  // cube_geo := core.cube_geo({2,2,2})
  // cube_mesh := core.create_mesh(cube_geo, false)

  return GameData{
    // cube = cube_mesh
  }
}

// Routine that will get run inside our single renderpass
render_game :: proc(enc: ^ral.CmdEncoder) {
  ral.bind_pipeline(enc, render_data.tri_pipeline) // bind the graphics pipeline
}

game_run :: proc(engine: ^core.Engine, game: GameData) {
  fmt.println("Run game")
  for {
    // fmt.println("main loop:")
    if glfw.WindowShouldClose(engine.window) {
      break
    }
    glfw.PollEvents()

    ral.frame_start()

    ral.renderpass_run(ral.RenderpassInfo {
      render_area_width = WINDOW_WIDTH,
      render_area_height = WINDOW_HEIGHT
    }, render_game)

    ral.frame_end()

    glfw.SwapBuffers(engine.window)
  }
}

render_init :: proc(engine: ^core.Engine) {
  // Create vertex buffer
  positions :=  [9]f32{
      0.0, -0.5, 0.0,
      0.5, 0.5, 0.0,
      -0.5, 0.5, 0.0,
  }

  render_data.vbuf = ral.gpu_buffer_create(size_of(positions), .Vertex, .Shared, &positions)

  // Create graphics pipeline
  render_data.tri_pipeline = ral.pipeline_create(ral.GraphicsPipelineDesc {
    label = "Draw Triangle Pipeline",
    vertex_desc = ral.VertexDescription {
        label = "Basic vert",
        attributes = {
           ral.VertexAttrib {
               label = "Position",
               kind = .F32x3
           }
        },
    },
    vs = {
        label = "Triangle Vertex Shader",
        path = "assets/tri.vert.spv",
        is_spirv = false,
        is_combined_vert_frag = false,
    },
    fs = {
        label = "Triangle Fragment Shader",
        path = "assets/tri.frag.spv",
        is_spirv = false,
        is_combined_vert_frag = false,
    },
    shader_layouts = {},
  })
}


main :: proc () {
  engine: core.Engine
  core.engine_init(&engine, WINDOW_WIDTH, WINDOW_HEIGHT)

  render_init(&engine)

  // Initialise everything we need at the start. Shaders, pipelines, buffers, etc
  game_data := game_init()

  // Enter the main frame loop
  game_run(&engine, game_data)

  core.engine_shutdown(&engine)
}
