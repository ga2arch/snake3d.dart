#import('dart:html');

#source('matrix4.dart');

#source('Cube.dart');
#source('Grid.dart');

#source('Shaders.dart');
#source('GeometryFactory.dart');

#source('Input.dart');
#source('Keys.dart');

#source('Snake.dart');


WebGLRenderingContext gl;
Matrix4 mvMatrix;
Matrix4 pMatrix;

CanvasElement canvas;
Shaders shaders;

var grid, cube;

var mvMatrixStack;
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
  shaders = new Shaders(gl, fragmentS, vertexS);
}

void mvPushMatrix() {
  mvMatrixStack.add(mvMatrix.clone());
}

void mvPopMatrix() {
  mvMatrix = mvMatrixStack.removeLast();
}

void drawScene() {
  gl.viewport(0, 0, canvas.width, canvas.height);
  gl.clear(WebGLRenderingContext.COLOR_BUFFER_BIT | WebGLRenderingContext.DEPTH_BUFFER_BIT);

  pMatrix = Matrix4.perspective(45.0, canvas.width / canvas.height, 1.0, 2000.0);  
  
  mvMatrix = Matrix4.translation(new Vector3(-60.0, -30.0, -120.0));
  mvMatrix *= Matrix4.rotation(-45.0, new Vector3(1.0, 0.0, 0.0));
  
  mvPushMatrix();
  grid.draw(mvMatrix, pMatrix, shaders);
  mvPopMatrix();
  
  mvPushMatrix();
  cube.draw(mvMatrix, pMatrix, shaders);
  mvPopMatrix();

}

void drawSnake() {
  snake.body.forEach((cube) {
    //drawCube(cube[0], cube[1], 1);
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
  //initBuffers();
  
  grid = GeometryFactory.createGrid(gl, 120, 120, 4);
  grid.x = 0;
  grid.y = 0;
  grid.z = 0;
  
  cube = GeometryFactory.createCube(gl, 5, [0.0, 1.0, 0.0, 1.0]);
  cube.x = 10;
  cube.y = 10;
  cube.z = 0;
  
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




