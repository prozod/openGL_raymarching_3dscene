#include <glad/glad.h>
#include <GLFW/glfw3.h>
#ifndef SHADER_HPP
#define SHADER_HPP

GLuint LoadShaders(const char *vertex_file_path,
                   const char *fragment_file_path);

#endif
