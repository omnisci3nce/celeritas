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

  for {
    if should_exit {
      break
    }
    glfw.PollEvents()

    // Write your code here

    glfw.SwapBuffers(engine.window)
  }
}
