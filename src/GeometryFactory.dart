class GeometryFactory {
  
  static Cube createCube(WebGLRenderingContext gl, num size, List color) {
    var vertices = [
                // Front face
                -1.0, -1.0,  1.0,
                 1.0, -1.0,  1.0,
                 1.0,  1.0,  1.0,
                -1.0,  1.0,  1.0,

                // Back face
                -1.0, -1.0, -1.0,
                -1.0,  1.0, -1.0,
                 1.0,  1.0, -1.0,
                 1.0, -1.0, -1.0,

                // Top face
                -1.0,  1.0, -1.0,
                -1.0,  1.0,  1.0,
                 1.0,  1.0,  1.0,
                 1.0,  1.0, -1.0,

                // Bottom face
                -1.0, -1.0, -1.0,
                 1.0, -1.0, -1.0,
                 1.0, -1.0,  1.0,
                -1.0, -1.0,  1.0,

                // Right face
                 1.0, -1.0, -1.0,
                 1.0,  1.0, -1.0,
                 1.0,  1.0,  1.0,
                 1.0, -1.0,  1.0,

                // Left face
                -1.0, -1.0, -1.0,
                -1.0, -1.0,  1.0,
                -1.0,  1.0,  1.0,
                -1.0,  1.0, -1.0
            ];
    vertices = vertices.map((v) => v * size/2);
    var colors = [];
    for (int i=0; i < 4*3*4; i++) {
      colors.addAll(color);
    }
    
    var indices = [
                             0, 1, 2,      0, 2, 3,    // Front face
                             4, 5, 6,      4, 6, 7,    // Back face
                             8, 9, 10,     8, 10, 11,  // Top face
                             12, 13, 14,   12, 14, 15, // Bottom face
                             16, 17, 18,   16, 18, 19, // Right face
                             20, 21, 22,   20, 22, 23  // Left face
                         ];
    
    Cube cube = new Cube(gl, vertices, colors, indices);
    return cube;
  }
  
  static Grid createGrid(gl, num width, num height, num size) {
    var vertices = [];
    for (int x=0; x <= width; x+=size) {
      vertices.addAll([x, 0.0, 0.0]);
      vertices.addAll([x, height, 0.0]);
      
      vertices.addAll([0.0, x, 0.0]);
      vertices.addAll([width, x, 0.0]);
    }
    
    var colors = [];
    for (int i=0; i < vertices.length; i++) {
     colors.addAll([0.658824, 0.658824, 0.658824, 1.0]);
    }
    
    return new Grid(gl, width, height, size, vertices, colors);
  }
  
}
