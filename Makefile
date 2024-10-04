GLSL_COMPILER = glslangValidator

GLSL_SOURCES = $(wildcard assets/*.vert assets/*.frag)

SPIRV_OBJECTS = $(addsuffix .spv,$(GLSL_SOURCES))

# Compile vertex shaders
%.vert.spv: %.vert
	$(GLSL_COMPILER) -V $< -o $@


shaders: $(SPIRV_OBJECTS)
