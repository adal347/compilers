#include <stdio.h>

extern char* yytext;

int main(void){
	#if YYDEBUG == 1
	extern int yydebug;
	yydebug = 1;
	#endif
	return(yyparse());
}

void yyerror(char *s){
	fprintf(stderr, "Error : Existing %s\n", s);
}
