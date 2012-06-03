class Cube {

  List<num> vertices;
  List<num> colors;
  List<num> indices;
  
  num x, y, z;
  
  var vertexPositionBuffer,
      vertexColorBuffer,
      vertexIndexBuffer;
  
  Cube(this.vertices, this.colors, this.indices) {
    initBuffers();
  }
  
  void initBuffers() {
    vertexPositionBuffer = gl.createBuffer();
    gl.bindBuffer(WebGLRenderingContext.ARRAY_BUFFER, vertexPositionBuffer);
    gl.bufferData(WebGLRenderingContext.ARRAY_BUFFER, new Float32Array.fromList(vertices), 
      WebGLRenderingContext.STATIC_DRAW);
    
    vertexColorBuffer = gl.createBuffer();
    gl.bindBuffer(WebGLRenderingContext.ARRAY_BUFFER, vertexColorBuffer);
    gl.bufferData(WebGLRenderingContext.ARRAY_BUFFER, new Float32Array.fromList(colors), 
      WebGLRenderingContext.STATIC_DRAW);
    
    vertexIndexBuffer = gl.createBuffer();
    gl.bindBuffer(WebGLRenderingContext.ELEMENT_ARRAY_BUFFER, vertexIndexBuffer);
    gl.bufferData(WebGLRenderingContext.ELEMENT_ARRAY_BUFFER, 
      new Uint16Array.fromList(indices), 
      WebGLRenderingContext.STATIC_DRAW);
  }
  
  void _binds() {
    gl.bindBuffer(WebGLRenderingContext.ARRAY_BUFFER, vertexPositionBuffer);
    gl.vertexAttribPointer(shaders.vertexPositionAttribute, 3, 
      WebGLRenderingContext.FLOAT, false, 0, 0);

    gl.bindBuffer(WebGLRenderingContext.ARRAY_BUFFER, vertexColorBuffer);
    gl.vertexAttribPointer(shaders.vertexColorAttribute, 4, 
      WebGLRenderingContext.FLOAT, false, 0, 0);

    gl.bindBuffer(WebGLRenderingContext.ELEMENT_ARRAY_BUFFER, vertexIndexBuffer);
  }
  
  void draw() {
    _binds();
    
    mvPushMatrix();
    gl.uniform3f(shaders.positionUniform, x, y, z);
    
    setMatrixUniforms();
    gl.drawElements(WebGLRenderingContext.TRIANGLE_STRIP, 36, WebGLRenderingContext.UNSIGNED_SHORT, 0);
    mvPopMatrix();
  }
}
