class Grid {
  
  num width, heigth, size;
  num x, y, z;
  
  List<num> vertices;
  List<num> colors;
  List<num> indices;
  
  var vertexPositionBuffer,
      vertexColorBuffer,
      vertexIndexBuffer;
  
  Grid(this.width, this.heigth, this.size, this.vertices, this.colors) {
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
  }
  
  void _binds() {
    gl.bindBuffer(WebGLRenderingContext.ARRAY_BUFFER, vertexPositionBuffer);
    gl.vertexAttribPointer(shaders.vertexPositionAttribute, 3, 
      WebGLRenderingContext.FLOAT, false, 0, 0);

    gl.bindBuffer(WebGLRenderingContext.ARRAY_BUFFER, vertexColorBuffer);
    gl.vertexAttribPointer(shaders.vertexColorAttribute, 4, 
      WebGLRenderingContext.FLOAT, false, 0, 0);
  }
  
  void draw() {
    _binds();
    
    mvPushMatrix();
    gl.uniform3f(shaders.positionUniform, x, y, z);
    //mvMatrix *= Matrix4.rotation(rot, new Vector3(0.0, 0.0, 1.0));
    
    setMatrixUniforms();
    gl.drawArrays(WebGLRenderingContext.LINES, 0, (vertices.length/3).toInt());
    mvPopMatrix();
  }
}