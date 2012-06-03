class Random {
  
  static int getRandomEvenInt(num begin, num end, num interval) {
    List numbers = [];
    
    if (begin % 2 != 0) begin++;
    
    for (int i=begin; i <= end; i+=4) {
      numbers.add([Math.random(), i]);
    }
        
    numbers.sort((a, b) {
      if (a[0] < b[0])  return -1;
      if (a[0] == b[0]) return 0;
      if (a[0] > b[0])  return 1;
    });
    
    return numbers[0][1];
  }
  
}
