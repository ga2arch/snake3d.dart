class Shaders {
  
  WebGLRenderingContext gl;
  var shaderProgram;
  
  String fragmentS, vertexS;
  
  var vertexPositionAttribute,
      vertexColorAttribute;
  
  var pMatrixUniform,
      mvMatrixUniform,
      positionUniform;
  
  Shaders(this.gl, this.fragmentS, this.vertexS) {
    init();
  }
  
  void init() {    
    var fragmentShader = compileShader(fragmentS, WebGLRenderingContext.FRAGMENT_SHADER);
    var vertexShader = compileShader(vertexS, WebGLRenderingContext.VERTEX_SHADER);
    
    shaderProgram = gl.createProgram();
    gl.attachShader(shaderProgram, fragmentShader);
    gl.attachShader(shaderProgram, vertexShader);
    gl.linkProgram(shaderProgram);
    gl.useProgram(shaderProgram);
    
    vertexPositionAttribute = gl.getAttribLocation(shaderProgram, "aVertexPosition");
    gl.enableVertexAttribArray(vertexPositionAttribute);
    
    vertexColorAttribute = gl.getAttribLocation(shaderProgram, "aVertexColor");
    gl.enableVertexAttribArray(vertexColorAttribute);
    
    pMatrixUniform = gl.getUniformLocation(shaderProgram, "uPMatrix");
    mvMatrixUniform = gl.getUniformLocation(shaderProgram, "uMVMatrix");
    positionUniform = gl.getUniformLocation(shaderProgram, "uPosition");
  }
  
  compileShader(String strShader, int type) {
    var shader = gl.createShader(type);
    gl.shaderSource(shader, strShader);
    gl.compileShader(shader);
    return shader;
  }
  
}
