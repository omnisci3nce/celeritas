#version 450

layout(location = 0) in vec3 position;

layout(location = 0) out vec3 fragColour;

void main() {
    fragColour = position;
    gl_Position = vec4(position, 1.0);
}
