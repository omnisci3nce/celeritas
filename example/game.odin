package game

import "core:fmt"
import "core:time"
import "vendor:glfw"
import "../packages/core"
import "../packages/ral"

GameData :: struct {
  cube: core.Mesh,
  // TODO: material
}

game_init :: proc() -> GameData {

  cube_geo := core.cube_geo({2,2,2})
  cube_mesh := core.create_mesh(cube_geo, false)

  return GameData{
    cube = cube_mesh
  }
}

game_run :: proc(engine: ^core.Engine, data: GameData) {
  fmt.println("Run game")
  for {
    fmt.println("main loop:")
    if glfw.WindowShouldClose(engine.window) {
      break
    }
    glfw.PollEvents()

    // ral.renderpass_run()

    glfw.SwapBuffers(engine.window)
  }
}

main :: proc () {
  engine: core.Engine
  core.engine_init(&engine)

  // Initialise everything we need at the start. Shaders, pipelines, buffers, etc
  game_data := game_init()

  // Enter the main frame loop
  game_run(&engine, game_data)

  core.engine_shutdown(&engine)
}
