package game

import "core:fmt"
import "core:time"
import "vendor:glfw"
import "../packages/core"
import "../packages/ral"

main :: proc () {
  engine: core.Engine

  core.engine_init(&engine)

  should_exit := false
  count := 0

  for {
    if glfw.WindowShouldClose(engine.window) {
      break
    }
    glfw.PollEvents()

    fmt.printfln("main loop %d", count)

    glfw.SwapBuffers(engine.window)
    count += 1

    if count == 1000000 {
      should_exit = true
    }
  }
}
