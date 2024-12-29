cmake_minimum_required(VERSION 3.29)
project(3dfun)

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

#include_directories(common)
#include_directories(dependencies)
#include_directories(dependencies/include)
#include_directories(dependencies/include/glad)
#include_directories(dependencies/include/glm)
#include_directories(dependencies/include/GLFW)
#include_directories(dependencies/include/KHR)

add_executable(3dfun
    common/shader.cpp
    common/shader.hpp
    glad.c
    main.cpp)

target_include_directories(3dfun PRIVATE ${CMAKE_SOURCE_DIR}/dependencies/include)
target_link_directories(3dfun PRIVATE ${CMAKE_SOURCE_DIR}/dependencies/lib)

find_package(OpenGL REQUIRED)
find_package(glfw3 3.3 REQUIRED)

target_link_libraries(3dfun
        ${CMAKE_SOURCE_DIR}/dependencies/lib/libglfw.3.4.dylib
        OpenGL::GL
        glfw
        "-framework OpenGL"    # Use OpenGL framework
        "-framework Cocoa"      # Required for macOS GUI
        "-framework IOKit"
        "-framework CoreVideo"
)
