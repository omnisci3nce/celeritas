package game

import "core:fmt"
import "core:time"
import "vendor:glfw"
import "../packages/core"
import "../packages/ral"

GameData :: struct {

}

game_init :: proc() -> GameData {

  cube_geo := core.cube_geo({2,2,2})
  cube_mesh := create_mesh(cube_geo)

  return GameData{}
}

game_run :: proc(engine: ^core.Engine, data: GameData) {
  for {
    if glfw.WindowShouldClose(engine.window) {
      break
    }
    glfw.PollEvents()

    glfw.SwapBuffers(engine.window)
  }
}

main :: proc () {
  engine: core.Engine
  core.engine_init(&engine)

  game_data := game_init()

  game_run(&engine, game_data)

  core.engine_shutdown(&engine)
}
