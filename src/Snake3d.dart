#import('dart:html');

#source('Shaders.dart');
#source('Matrix4.dart');

#source('geometries/GeometryFactory.dart');
#source('geometries/Cube.dart');
#source('geometries/Grid.dart');

#source('input/Input.dart');
#source('input/Keys.dart');

#source('actors/Food.dart');
#source('actors/Snake.dart');

#source('utilities/Random.dart');

CanvasElement canvas;
WebGLRenderingContext gl;

Matrix4 mvMatrix;
Matrix4 pMatrix;
List<Matrix4> mvMatrixStack;

Shaders shaders;

Grid grid;
Snake snake;
Food food;

num currentTime, lastTime;
bool gameover = false;

// Fragment Shader 
// doc: http://en.wikipedia.org/wiki/Shader#Pixel_shaders 
String fragmentS = """
    precision mediump float;

    varying vec4 vColor;

    void main(void) {
        gl_FragColor = vColor;
    }""";

// Vertex Shader
// doc: http://en.wikipedia.org/wiki/Shader#Vertex_shaders
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

void main() {
  mvMatrix = Matrix4.identity();
  pMatrix  = Matrix4.identity();
  mvMatrixStack = [];
  
  lastTime = 0;
  currentTime = 0;
  
  initGL();
  initShaders();
  
  initElements();
  new Input();
  
  gl.clearColor(1.0, 1.0, 1.0, 1.0);
  gl.enable(WebGLRenderingContext.DEPTH_TEST);
  
  tick();
}

void initGL() {
  try {
    canvas = document.query('#canvas');
    gl = canvas.getContext('experimental-webgl');
  } catch(Exception e) {
    window.alert('No webgl');
    gameover = true;
  }
}

void initShaders() {
  shaders = new Shaders(gl, fragmentS, vertexS);
}

void initElements() {
  grid = GeometryFactory.createGrid(120, 120, 4);
  grid.x = 0;
  grid.y = 0;
  grid.z = 0;
  
  snake = new Snake();
  food = new Food();
  food.spawnFood();
}

void tick() {
  if (gameover) return;
  window.webkitRequestAnimationFrame((_) => tick());
  animate();
  checkCollision();
  drawScene();
}

void animate() {
  var timeNow = new Date.now().value;
  if (lastTime != 0) {
      var elapsed = (timeNow - lastTime) / 1000;
      snake.act(elapsed);
  }
  lastTime = timeNow;
}

void drawScene() {
  if (gameover) return;
  
  gl.viewport(0, 0, canvas.width, canvas.height);
  gl.clear(WebGLRenderingContext.COLOR_BUFFER_BIT | WebGLRenderingContext.DEPTH_BUFFER_BIT);

  pMatrix = Matrix4.perspective(45.0, canvas.width / canvas.height, 1.0, 2000.0);  
  
  mvMatrix = Matrix4.translation(new Vector3(-60.0, -30.0, -120.0));
  mvMatrix *= Matrix4.rotation(-45.0, new Vector3(1.0, 0.0, 0.0));
  
  grid.draw();
  snake.draw();
  food.draw();  
}

void checkCollision() {
  // check borders
  var snakeHead = snake.body.first();
  if (snakeHead.x < 2 || snakeHead.x > grid.width-2 || 
      snakeHead.y < 2 || snakeHead.y > grid.heigth-2)
    gameOver();
  
  //check food
  if (snakeHead.x == food.cube.x && 
      snakeHead.y == food.cube.y) {
    snake.eat();
    food.spawnFood();
  }
  
  //check itself
  int headCount = 0;
  snake.body.forEach((cube) {
    if (snakeHead.x == cube.x && 
        snakeHead.y == cube.y) 
      headCount++;
  });
  if (headCount > 1) gameOver();
}

void setMatrixUniforms() {
  gl.uniformMatrix4fv(shaders.pMatrixUniform, false, pMatrix.buf);
  gl.uniformMatrix4fv(shaders.mvMatrixUniform, false, mvMatrix.buf);
}

void mvPushMatrix() {
  mvMatrixStack.add(mvMatrix.clone());
}

void mvPopMatrix() {
  mvMatrix = mvMatrixStack.removeLast();
}

void gameOver() {
  print('Gameover${snake.body}');
  window.alert('Gameover');
  gameover = true;
}