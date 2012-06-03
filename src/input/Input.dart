class Input {
   
  static num mouseX = 0, mouseY = 0;
  static Map _pressed;
  static Input _instance;
  
  Input() {
    _pressed = new Map();
    onKeyDown();
    onKeyUp();
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
    if (_pressed.containsKey(keyCode)) return _pressed[keyCode];
    else return false;
  }
}
