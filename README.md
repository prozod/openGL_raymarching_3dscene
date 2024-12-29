# C++/OpenGL Basic 3D Scene (Raymarching/Signed Distance Functions)
A simple 3D scene/plane where I make use of fragment shaders to implement different objects iteratively (I believe this is called *raymarching*), using Signed Distance Functions, then cast a light (Phong) over them and add shadows.

The scene is a bit laggy when the shadows are on, I feel like the way I compute the rays hitting objects is not correct. 

### To build:
- From root of this folder do `mkdir build && cd build`
- `cmake .. -DCMAKE_BUILD_TYPE=Debug` (the flag is not required)
- `make && ./3dfun`

### Screenshots/video

<img alt="logofireball" src="/external_assets/ss1.png" height="400" width="auto">
<img alt="logofireball" src="/external_assets/ss2.png" height="400" width="auto">

https://github.com/user-attachments/assets/be2a4e51-c472-4e79-b8b9-4f9ab1039995

