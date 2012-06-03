class Input {
   
  static num mouseX = 0, mouseY = 0;
  static Map _pressed;
  static Input _instance;
  
  Input() {
    _pressed = new Map();
    onKeyDown();
    onKeyUp();
  }
  
  static Input getInstance() {
    if (_instance == null) {
      _instance = new Input();
    }
    return _instance;
  }
  
  void onKeyDown() {
    document.on.keyDown.add((evt) {
      evt.preventDefault();
      _pressed[evt.keyCode] = true;
    });
  }
  
  void onKeyUp() {
    document.on.keyUp.add((evt) {
      evt.preventDefault();
      _pressed.remove(evt.keyCode);
    });
  }
  
  static bool isKeyPressed(num keyCode) {
    var status;
    if (_pressed.containsKey(keyCode)) status = _pressed[keyCode];
    else status = false;
    takeOf(keyCode);
    return status;
  }
  
  static void takeOf(num keyCode) {
    if (_pressed.containsKey(keyCode)) _pressed[keyCode] = false;
  }
}
