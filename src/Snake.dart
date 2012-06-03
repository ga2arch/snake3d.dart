class Snake {
  
  static num UP    = 1,
             RIGHT = 2,
             LEFT  = 3,
             DOWN  = 4;
  
  num currentTime, direction;
  Queue body;
  
  Snake() {
    currentTime = 0;
    direction = RIGHT;
    body = new Queue();
    spawnBody();
  }
  
  void spawnBody() {
    for (int i=0; i < 2; i++) {
      var cube = GeometryFactory.createCube(gl, 4, [0.0, 1.0, 0.0, 1.0]);
      cube.x = 13-i*4;
      cube.y = 9;
      cube.z = 2;
      body.add(cube);
    }
  }
  
  void act(num delta) {
    currentTime += delta;
    
    if (Input.isKeyPressed(Keys.LEFT))
      snake.direction = Snake.LEFT;
    
    if (Input.isKeyPressed(Keys.RIGHT))
      snake.direction = Snake.RIGHT;
    
    if (Input.isKeyPressed(Keys.UP))
      snake.direction = Snake.UP;
    
    if (Input.isKeyPressed(Keys.DOWN))
      snake.direction = Snake.DOWN;
    
    if (Input.isKeyPressed(Keys.SPACE))
      snake.eat();
    
    if (currentTime > 0.8) {
      move();
      currentTime = 0;
    }
  }
  
  void draw(mvMatrix, pMatrix, shaders) {
    body.forEach((c) {
      c.draw(mvMatrix, pMatrix, shaders);
    });
  }
  
  void move() {
   num x = body.first().x; 
   num y = body.first().y;
      
   switch (direction) {
     case UP:    y += 4; break;
     case RIGHT: x += 4; break;
     case LEFT:  x -= 4; break;
     case DOWN:  y -= 4; break;
   }
      
   var ncube = body.removeLast();
   ncube.x = x;
   ncube.y = y;
   body.addFirst(ncube);
  }
  
  void eat() {
    var cube = GeometryFactory.createCube(gl, 4, [0.0, 1.0, 0.0, 1.0]);
    cube.x = body.last().x;
    cube.y = body.last().y;
    cube.z = 2;
    
    body.addLast(cube);
  }
}
