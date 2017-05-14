int x, y;

cilk int main(){
  char x, y;
  x = "Hola";
  //This is a comment
  /* Another Comment */
  Cilk_for (x = 1; x < 1; x--) {
    int a;
    x += y;
    y = x + 1;
  }
  if (x < y) {
    x -= y;
  } else {
    x += y;
  }
  return 0;
}
