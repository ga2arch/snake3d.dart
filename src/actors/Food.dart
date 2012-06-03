class Food {
  
  Cube cube;
  
  Food() {
    cube = GeometryFactory.createCube(4, [1.0, 1.0, 0.0, 1.0]);
    cube.z = 2;
  }
  
  void spawnFood() {
    int time = new Date.now().value;
    
    cube.x = Random.getRandomEvenInt(2, 118, 4);
    cube.y = Random.getRandomEvenInt(2, 118, 4);
    
    snake.body.forEach((c) {
      if (c.x == cube.x && 
          c.y == cube.y) 
        spawnFood();
    });
  }
  
  void draw() {
    cube.draw();
  }
}
