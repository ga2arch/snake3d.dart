#import('dart:html');
#source('matrix4.dart');
#source('Snake.dart');
#source('Input.dart');
#source('Keys.dart');

WebGLRenderingContext gl;
Matrix4 mvMatrix;
Matrix4 pMatrix;

CanvasElement canvas;

var mvMatrixStack;
var shaderProgram;
Map attribs;

var cubeVertexPositionBuffer;
var cubeVertexColorBuffer, cubeVertexColorBuffer2;
var cubeVertexIndexBuffer;

var rectangleVertexPositionBuffer, rectangleVertexColorBuffer;

var vertexPositionAttribute, vertexColorAttribute;
var textureCoordAttribute;

var lineVertexPositionBuffer, lineVertexColorBuffer;

var pMatrixUniform, mvMatrixUniform, positionUniform;
var rCube;
var lastTime;

var snake;
var food;
var random;

num WIDTH = 60;
num HEIGHT = 60;
bool gameover = false;

String fragmentS = """
    precision mediump float;

    varying vec4 vColor;

    void main(void) {
        gl_FragColor = vColor;
    }""";
    
String vertexS = """
    attribute vec3 aVertexPosition;
    attribute vec4 aVertexColor;

    uniform mat4 uMVMatrix;
    uniform mat4 uPMatrix;
    uniform vec3 uPosition;

    varying vec4 vColor;

    void main(void) {
        gl_Position = uPMatrix * uMVMatrix * vec4(aVertexPosition + uPosition, 1.0);
        vColor = aVertexColor;
    }""";

void initGL() {
  try {
    gl = canvas.getContext('experimental-webgl');
  } catch(Exception e) {
    
  }
}

void initShaders() {
  attribs = {};
  
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

void mvPushMatrix() {
  mvMatrixStack.add(mvMatrix.clone());
}

void mvPopMatrix() {
  mvMatrix = mvMatrixStack.removeLast();
}

void setMatrixUniforms() {
  gl.uniformMatrix4fv(pMatrixUniform, false, pMatrix.buf);
  gl.uniformMatrix4fv(mvMatrixUniform, false, mvMatrix.buf);
}

void initBuffers() { 
  rectangleVertexPositionBuffer = gl.createBuffer();
  gl.bindBuffer(WebGLRenderingContext.ARRAY_BUFFER, rectangleVertexPositionBuffer);
  /*var vertices = [  0.5,  1.0,  0.0, 
               -0.5,  1.0,  0.0,
               -0.5, -1.0,  0.0,
                0.5, -1.0,  0.0
               ];*/
  
  var vertices  = [
                             1.0,  1.0,  0.0,
                             -1.0,  1.0,  0.0,
                              1.0, -1.0,  0.0,
                             -1.0, -1.0,  0.0
                         ];
  
  gl.bufferData(WebGLRenderingContext.ARRAY_BUFFER, new Float32Array.fromList(vertices), WebGLRenderingContext.STATIC_DRAW);

  rectangleVertexColorBuffer = gl.createBuffer();
  gl.bindBuffer(WebGLRenderingContext.ARRAY_BUFFER, rectangleVertexColorBuffer);
  var colors = [];
  for (var i=0; i < 4; i++) {
      [0.5, 0.34983, 1.0, 1.0].map((x) => colors.add(x));
  }
  gl.bufferData(WebGLRenderingContext.ARRAY_BUFFER, new Float32Array.fromList(colors), WebGLRenderingContext.STATIC_DRAW);
  
  // grid
  
  lineVertexPositionBuffer = gl.createBuffer();
  gl.bindBuffer(WebGLRenderingContext.ARRAY_BUFFER, lineVertexPositionBuffer);
  
  vertices = [];
  
  for (int x=0; x <= 120; x+=4) {
    [x, 0.0, 0.0].map((e) => vertices.add(e));
    [x, 120.0, 0.0].map((e) => vertices.add(e));
  }
  
  print(vertices.length);
  
  /*vertices  = [0.0, 0.0, 0.0,
               0.0, 120.0, 0.0,
               50.0, 0.0, 0.0,
               50.0, 120, 0.0];*/
  
  gl.bufferData(WebGLRenderingContext.ARRAY_BUFFER, new Float32Array.fromList(vertices), WebGLRenderingContext.STATIC_DRAW);

  lineVertexColorBuffer = gl.createBuffer();
  gl.bindBuffer(WebGLRenderingContext.ARRAY_BUFFER, lineVertexColorBuffer);
  colors = [];
  
  for (int i=0; i < vertices.length/3; i++) {
    [0.658824, 0.658824, 0.658824, 1.0].map((e) => colors.add(e));
  }
  
  gl.bufferData(WebGLRenderingContext.ARRAY_BUFFER, new Float32Array.fromList(colors), WebGLRenderingContext.STATIC_DRAW);
  
  
  // cube
  cubeVertexPositionBuffer = gl.createBuffer();
  gl.bindBuffer(WebGLRenderingContext.ARRAY_BUFFER, cubeVertexPositionBuffer);
  vertices = [
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
  
  gl.bufferData(WebGLRenderingContext.ARRAY_BUFFER, new Float32Array.fromList(vertices), WebGLRenderingContext.STATIC_DRAW);
  //cubeVertexPositionBuffer.itemSize = 3;
  //cubeVertexPositionBuffer.numItems = 24;

  cubeVertexColorBuffer = gl.createBuffer();
  gl.bindBuffer(WebGLRenderingContext.ARRAY_BUFFER, cubeVertexColorBuffer);
  /*colors = [
      [0.0, 1.0, 0.0, 1.0], // Front face
      [0.0, 1.0, 0.0, 1.0], // Back face
      [0.0, 1.0, 0.0, 1.0], // Top face
      [0.0, 1.0, 0.0, 1.0], // Bottom face
      [0.0, 1.0, 0.0, 1.0], // Right face
      [0.0, 1.0, 0.0, 1.0]  // Left face
  ];

  var unpackedColors = [];
  for (final i in colors) {
    for (var j=0; j<4; j++) {
      for (final e in i)
        unpackedColors.add(e);
    }
  }*/
  
  colors = [];
          for (int i=0; i < 4*3*4; i++) {
            [0.0, 1.0, 0.0, 1.0].map((e) => colors.add(e));
          }
  
  gl.bufferData(WebGLRenderingContext.ARRAY_BUFFER, new Float32Array.fromList(colors), WebGLRenderingContext.STATIC_DRAW);
  
  cubeVertexColorBuffer2 = gl.createBuffer();
  gl.bindBuffer(WebGLRenderingContext.ARRAY_BUFFER, cubeVertexColorBuffer2);
  colors = [];
          for (int i=0; i < 4*3*4; i++) {
            [1.0, 0.0, 0.0, 1.0].map((e) => colors.add(e));
          }
  
  gl.bufferData(WebGLRenderingContext.ARRAY_BUFFER, new Float32Array.fromList(colors), WebGLRenderingContext.STATIC_DRAW);
   
  
  cubeVertexIndexBuffer = gl.createBuffer();
  gl.bindBuffer(WebGLRenderingContext.ELEMENT_ARRAY_BUFFER, cubeVertexIndexBuffer);
  var cubeVertexIndices = [
      0, 1, 2,      0, 2, 3,    // Front face
      4, 5, 6,      4, 6, 7,    // Back face
      8, 9, 10,     8, 10, 11,  // Top face
      12, 13, 14,   12, 14, 15, // Bottom face
      16, 17, 18,   16, 18, 19, // Right face
      20, 21, 22,   20, 22, 23  // Left face
  ];
  gl.bufferData(WebGLRenderingContext.ELEMENT_ARRAY_BUFFER, new Uint16Array.fromList(cubeVertexIndices), WebGLRenderingContext.STATIC_DRAW);
  

}

void drawRectangle(x, y, z) {
  mvPushMatrix();

  mvMatrix *= Matrix4.translation(new Vector3(x, y, z));
  
  setMatrixUniforms();
  gl.drawArrays(WebGLRenderingContext.TRIANGLE_STRIP, 0, 4);
  
  mvPopMatrix();
}

void drawCube(x, y, z) {
  mvPushMatrix();

  gl.uniform3f(positionUniform, x, y, z);
  mvMatrix *= Matrix4.scale(new Vector3(2.0, 2.0, 2.0));
  
  setMatrixUniforms();
  gl.drawElements(WebGLRenderingContext.TRIANGLE_STRIP, 36, WebGLRenderingContext.UNSIGNED_SHORT, 0);
  
  mvPopMatrix();
}

void drawLine(x, y, z, rot) {
  mvPushMatrix();

  gl.uniform3f(positionUniform, x, y, z);
  mvMatrix *= Matrix4.rotation(rot, new Vector3(0.0, 0.0, 1.0));

  setMatrixUniforms();
  gl.drawArrays(WebGLRenderingContext.LINES, 0, 62);
  
  mvPopMatrix();
}

void drawScene() {
  gl.viewport(0, 0, canvas.width, canvas.height);
  gl.clear(WebGLRenderingContext.COLOR_BUFFER_BIT | WebGLRenderingContext.DEPTH_BUFFER_BIT);

  pMatrix = Matrix4.perspective(45.0, canvas.width / canvas.height, 1.0, 2000.0);  
  
  mvMatrix = Matrix4.translation(new Vector3(-60.0, -30.0, -120.0));
  mvMatrix *= Matrix4.rotation(-45.0, new Vector3(1.0, 0.0, 0.0));
  //mvMatrix *= Matrix4.rotation(30.0, new Vector3(0.0, 0.0, 1.0));
  //mvMatrix %= new Vector3(1.0, 1.0, Math.sin(1));

  /*gl.bindBuffer(WebGLRenderingContext.ARRAY_BUFFER, rectangleVertexPositionBuffer);
  gl.vertexAttribPointer(vertexPositionAttribute, 3, WebGLRenderingContext.FLOAT, false, 0, 0);

  gl.bindBuffer(WebGLRenderingContext.ARRAY_BUFFER, rectangleVertexColorBuffer);
  gl.vertexAttribPointer(vertexColorAttribute, 4, WebGLRenderingContext.FLOAT, false, 0, 0);
  
  for (var x = 0; x < 30; x += 2)
  for (var y = 0; y < 30; y += 2) {
    //drawRectangle(x, y, 0.0);
  }*/
  
  gl.bindBuffer(WebGLRenderingContext.ARRAY_BUFFER, cubeVertexPositionBuffer);
  gl.vertexAttribPointer(vertexPositionAttribute, 3, WebGLRenderingContext.FLOAT, false, 0, 0);

  gl.bindBuffer(WebGLRenderingContext.ARRAY_BUFFER, cubeVertexColorBuffer);
  gl.vertexAttribPointer(vertexColorAttribute, 4, WebGLRenderingContext.FLOAT, false, 0, 0);

  gl.bindBuffer(WebGLRenderingContext.ELEMENT_ARRAY_BUFFER, cubeVertexIndexBuffer);
  
  drawSnake();
  
  gl.bindBuffer(WebGLRenderingContext.ARRAY_BUFFER, cubeVertexPositionBuffer);
  gl.vertexAttribPointer(vertexPositionAttribute, 3, WebGLRenderingContext.FLOAT, false, 0, 0);

  gl.bindBuffer(WebGLRenderingContext.ARRAY_BUFFER, cubeVertexColorBuffer2);
  gl.vertexAttribPointer(vertexColorAttribute, 4, WebGLRenderingContext.FLOAT, false, 0, 0);

  gl.bindBuffer(WebGLRenderingContext.ELEMENT_ARRAY_BUFFER, cubeVertexIndexBuffer);
  
  drawCube(food[0], food[1], 1);
   
  gl.bindBuffer(WebGLRenderingContext.ARRAY_BUFFER, lineVertexPositionBuffer);
  gl.vertexAttribPointer(vertexPositionAttribute, 3, WebGLRenderingContext.FLOAT, false, 0, 0);

  gl.bindBuffer(WebGLRenderingContext.ARRAY_BUFFER, lineVertexColorBuffer);
  gl.vertexAttribPointer(vertexColorAttribute, 4, WebGLRenderingContext.FLOAT, false, 0, 0);
  
  drawLine(0, 0, 0, 0); 
  drawLine(-120, 0, 0, -90);
}

void drawSnake() {
  snake.body.forEach((cube) {
    drawCube(cube[0], cube[1], 1);
  });
  print(snake.body);
}

var currentTime;

void animate() {
  var timeNow = new Date.now().value;
  if (lastTime != 0) {
      var elapsed = (timeNow - lastTime) / 1000;
      snake.act(elapsed);

      if (!snake.gotdir) {
      if (Input.isKeyPressed(Keys.LEFT)) {
        if (snake.direction == Snake.RIGHT) {
          snake.reverse();
        } else 
          snake.direction = Snake.LEFT;
      }
      if (Input.isKeyPressed(Keys.RIGHT))
        if (snake.direction == Snake.LEFT) {
          snake.reverse();
        } else 
          snake.direction = Snake.RIGHT;
      if (Input.isKeyPressed(Keys.UP))
        if (snake.direction == Snake.DOWN) {
          snake.reverse();
        } else 
          snake.direction = Snake.UP;
      if (Input.isKeyPressed(Keys.DOWN))
        if (snake.direction == Snake.UP) {
          snake.reverse();
        } else 
          snake.direction = Snake.DOWN;
      if (Input.isKeyPressed(Keys.SPACE)) {
        snake.eaten();
        }
      snake.gotdir = true;
      } 
  }
  lastTime = timeNow;
}

void tick() {
  if (gameover) return;
  window.webkitRequestAnimationFrame((_) => tick());
  animate();
  checkCollision();
  drawScene();
}

void main() {
  mvMatrix = Matrix4.identity();
  pMatrix =  Matrix4.identity();
  mvMatrixStack = [];
  rCube = 0;
  lastTime = 0;
  currentTime = 0;
  
  canvas = document.query('#canvas');
  initGL();
  initShaders();
  initBuffers();
  
  snake = new Snake();
  food = [0, 0];
  spawnFood();
  
  var input = new Input();
  
  gl.clearColor(1.0, 1.0, 1.0, 1.0);
  gl.enable(WebGLRenderingContext.DEPTH_TEST);
  
  //document.on.keyDown.add(onKeyDown);
  
  tick();
}

void onKeyDown(evt) {
  /*evt.preventDefault();
  if (evt.keyCode == 37)
    snake.direction = Snake.LEFT;
  if (evt.keyCode == 39)
    snake.direction = Snake.RIGHT;
  if (evt.keyCode == 38)
    snake.direction = Snake.UP;
  if (evt.keyCode == 40)
    snake.direction = Snake.DOWN;
  if (evt.keyCode == Keys.SPACE) 
    snake.eaten();*/
}



void checkCollision() {
  // check borders
  var snakeHead = snake.body.first();
  if (snakeHead[0] < 1 || snakeHead[0] > WIDTH-1 || snakeHead[1] < 1 || snakeHead[1] > HEIGHT -1 ) {
    gameOver();
  }
  
  //check food
  if (snakeHead[0] == food[0] && snakeHead[1] == food[1]) {
    snake.eaten();
    spawnFood();
  }
  
  //check itself
  int headCount = 0;
  snake.body.forEach((cube) {
    if (snakeHead[0] == cube[0] && snakeHead[1] == cube[1]) headCount++;
  });
  if (headCount > 1) gameOver();
  
}

void spawnFood() {
  int time = new Date.now().value;
  
  var x = (time % (WIDTH/2)).floor() * 2 + 1;
  var y = (time % (HEIGHT/2)).floor() * 2 + 1;
  
  food[0] = x;
  food[1] = y;
  
  print(x);
  print(y);
  
  snake.body.forEach((cube) {
    if (cube[0] == food[0] && cube[1] == food[1]) spawnFood();
  });
}

void gameOver() {
  print('Gameover${snake.body}');
  window.alert('Gameover');
  gameover = true;
}

compileShader(String strShader, int type) {
  var shader = gl.createShader(type);
  gl.shaderSource(shader, strShader);
  gl.compileShader(shader);
  return shader;
}


