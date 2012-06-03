class Snake {
  
  static num UP = 1,
             RIGHT = 2,
             LEFT = 3,
             DOWN = 4;
  
  var currentTime;
  Queue body;
  var direction;
  bool gotdir;
  
  Snake() {
    //head = {'x':10, 'y':10};
    currentTime = 0;
    direction = RIGHT;
    gotdir = false;
    body = new Queue.from([[11, 9], [9, 9]]);
  }
  
  void act(num delta) {
    currentTime += delta;
    if (currentTime > 0.8) {
      move();
      currentTime = 0;
      gotdir = false;
    }
  }
  
  void move() {
   var x = body.first()[0]; 
   var y = body.first()[1];
      
   if (direction == UP) {
     y += 2;
   } 
   if (direction == RIGHT) {
     x += 2;
   }
   if (direction == LEFT) {
     x -= 2;
   }
   if (direction == DOWN) {
     y -= 2;
   }
     
   body.addFirst([x, y]);
   body.removeLast();
  }
  
  void eaten() {
    body.addLast(body.last());
  }
  
  void reverse() {
    Queue temp = new Queue.from(snake.body);
    body.clear();
    temp.forEach((cube) => body.addFirst(cube));
    var head = body.first();
    var second;
    int i = 0;
    body.forEach((cube) {
      if (i == 1) 
        second = cube; 
      else 
        i++;
    });
    
    if (head[0] < second[0])
      direction = LEFT;
    if (head[0] > second[0])
      direction = RIGHT;
    if (head[1] < second[1])
      direction = DOWN;
    if (head[1] > second[1])
      direction = UP;
    
  }
  
}
