#include "common/shader.hpp"
#include <iostream>
#include <glm/glm.hpp>
#include <glm/gtc/type_ptr.hpp>
#include <glm/gtc/matrix_transform.hpp>

const int SCREEN_WIDTH = 1280;
const int SCREEN_HEIGHT = 960;

static const GLfloat quadVertices[] = {
    -1.0f, -1.0f, 1.0f, -1.0f, -1.0f, 1.0f, 1.0f, 1.0f,
};

// initial camera position and direction
glm::vec3 ro = glm::vec3(3.0f, 1.0f, 5.0f);
glm::vec3 rd = glm::normalize(glm::vec3(0.0f, 0.0f, -1.0f));

const float moveSpeed = 0.05f;
const float rotateSpeed = 0.05f;

// right and up vectors for camera movement
glm::vec3 right = glm::normalize(glm::cross(rd, glm::vec3(0.0f, 1.0f, 0.0f)));
glm::vec3 up = glm::cross(right, rd);

void rotateCamera(float angle) {
  glm::mat4 rotationMatrix =
      glm::rotate(glm::mat4(1.0f), angle, glm::vec3(0.0f, 1.0f, 0.0f));
  rd = glm::mat3(rotationMatrix) * rd;
  right = glm::mat3(rotationMatrix) * right;
  up = glm::cross(right, rd);
}

void handleInput(GLFWwindow *window) {
  if (glfwGetKey(window, GLFW_KEY_W) == GLFW_PRESS) {
    ro += rd * moveSpeed; // move forward (W)
  }
  if (glfwGetKey(window, GLFW_KEY_S) == GLFW_PRESS) {
    ro -= rd * moveSpeed; // move backward (S)
  }
  if (glfwGetKey(window, GLFW_KEY_A) == GLFW_PRESS) {
    ro -= right * moveSpeed; // move left (A)
  }
  if (glfwGetKey(window, GLFW_KEY_D) == GLFW_PRESS) {
    ro += right * moveSpeed; // move right (D)
  }

  if (glfwGetKey(window, GLFW_KEY_UP) == GLFW_PRESS) {
    ro += up * moveSpeed; // move up (UP arrrow)
  }
  if (glfwGetKey(window, GLFW_KEY_DOWN) == GLFW_PRESS) {
    ro -= up * moveSpeed; // move down (DOWN)
  }

  if (glfwGetKey(window, GLFW_KEY_LEFT) == GLFW_PRESS) {
    rotateCamera(rotateSpeed); // rotate left
  }
  if (glfwGetKey(window, GLFW_KEY_RIGHT) == GLFW_PRESS) {
    rotateCamera(-rotateSpeed); // rotate right
  }
}

int main() {
  if (!glfwInit()) {
    std::cerr << "Failed to initialize GLFW\n";
    return -1;
  }
  glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
  glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
  glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);

  GLFWwindow *window =
      glfwCreateWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "3D Scene THU", NULL, NULL);
  if (!window) {
    std::cerr << "Failed to open GLFW window\n";
    glfwTerminate();
    return -1;
  }
  glfwMakeContextCurrent(window);

  if (!gladLoadGLLoader((GLADloadproc)glfwGetProcAddress)) {
    std::cerr << "Failed to initialize GLAD\n";
    return -1;
  }

  GLuint programID = LoadShaders("../vertShader.glsl", "../fragShader.glsl");

  GLuint VAO, VBO;
  glGenVertexArrays(1, &VAO);
  glGenBuffers(1, &VBO);

  glBindVertexArray(VAO);

  glBindBuffer(GL_ARRAY_BUFFER, VBO);
  glBufferData(GL_ARRAY_BUFFER, sizeof(quadVertices), quadVertices,
               GL_STATIC_DRAW);

  glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, 2 * sizeof(float), (void *)0);
  glEnableVertexAttribArray(0);

  glBindVertexArray(0);

  // uniform locations
  GLuint resolutionLoc = glGetUniformLocation(programID, "u_resolution");
  GLuint timeLoc = glGetUniformLocation(programID, "u_time");
  GLuint cameraPosLoc = glGetUniformLocation(programID, "u_cameraPos");
  GLuint cameraDirLoc = glGetUniformLocation(programID, "u_cameraDir");

  float time = 0.0f;
  while (!glfwWindowShouldClose(window) &&
         glfwGetKey(window, GLFW_KEY_ESCAPE) != GLFW_PRESS) {
    // Update time
    time += 0.01f;
    handleInput(window);

    glClear(GL_COLOR_BUFFER_BIT);

    glUseProgram(programID);

    glUniform2f(resolutionLoc, (float)SCREEN_WIDTH, (float)SCREEN_HEIGHT);
    glUniform1f(timeLoc, time);
    glUniform3f(cameraPosLoc, ro.x, ro.y,
                ro.z); // init the camera position uniform
    glUniform3f(cameraDirLoc, rd.x, rd.y,
                rd.z); // send the updated camera direction to the shader

    glBindVertexArray(VAO);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

    glfwSwapBuffers(window);
    glfwPollEvents();
  }

  glDeleteVertexArrays(1, &VAO);
  glDeleteBuffers(1, &VBO);
  glDeleteProgram(programID);

  glfwTerminate();
  return 0;
}
