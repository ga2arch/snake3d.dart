class Cube {

  WebGLRenderingContext gl;
  List<num> vertices;
  List<num> colors;
  List<num> indices;
  
  num x, y, z;
  
  var vertexPositionBuffer,
      vertexColorBuffer,
      vertexIndexBuffer;
  
  Cube(this.gl, this.vertices, this.colors, this.indices) {
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
  
  void _binds(Shaders shaders) {
    gl.bindBuffer(WebGLRenderingContext.ARRAY_BUFFER, vertexPositionBuffer);
    gl.vertexAttribPointer(shaders.vertexPositionAttribute, 3, 
      WebGLRenderingContext.FLOAT, false, 0, 0);

    gl.bindBuffer(WebGLRenderingContext.ARRAY_BUFFER, vertexColorBuffer);
    gl.vertexAttribPointer(shaders.vertexColorAttribute, 4, 
      WebGLRenderingContext.FLOAT, false, 0, 0);

    gl.bindBuffer(WebGLRenderingContext.ELEMENT_ARRAY_BUFFER, vertexIndexBuffer);
  }
  
  void draw(mvMatrix, pMatrix, shaders) {
    _binds(shaders);
    gl.uniform3f(shaders.positionUniform, x, y, z);
    
    setMatrixUniforms(shaders, pMatrix, mvMatrix);
    gl.drawElements(WebGLRenderingContext.TRIANGLE_STRIP, 36, WebGLRenderingContext.UNSIGNED_SHORT, 0);
  }

  void setMatrixUniforms(Shaders shaders, pMatrix, mvMatrix) {
    gl.uniformMatrix4fv(shaders.pMatrixUniform, false, pMatrix.buf);
    gl.uniformMatrix4fv(shaders.mvMatrixUniform, false, mvMatrix.buf);
  }
}
