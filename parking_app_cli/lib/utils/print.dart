void printColor(String text, String type) {
  switch (type) {
    case 'success':
      print('\x1B[32m$text\x1B[0m\n'); // green
      break;
    case 'error':
      print('\x1B[31m$text\x1B[0m\n'); // red
      break;
    case 'info':
      print('\x1B[36m$text\x1B[0m\n'); // cyan
      break;
  }
}
