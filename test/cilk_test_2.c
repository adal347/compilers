int a, b, c;

cilk int main(){
  char i, j;
  i = "Hola";
  c = 0;
  //This is a comment
  /* Another Comment */
  Cilk_for (a = 1; a < 1; a--) {
    c += a;
    b = c + 1;
  }
  if (a < b) {
    a -= b;
  } else {
    a += b;
  }
  return 0;
}
