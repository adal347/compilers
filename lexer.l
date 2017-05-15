%{
#ifdef PRINT
#define TOKEN(t) printf("Token: " #t "\n");
#define INTEGER_TOKEN(t) printf("Number %d Token: " #t "\n", atoi(yytext));
#define ID_TOKEN(t) printf("ID %s Token: " #t "\n", yytext);
#define STRING_TOKEN(t) printf("String %s Token: " #t "\n", yytext);
#else
#define TOKEN(t) return (t);
#define INTEGER_TOKEN(t) yylval.iVal = atoi(yytext); return (t);
#define ID_TOKEN(t) yylval.iVal = installId(yytext); return (t);
#define STRING_TOKEN(t) yylval.iVal = installid(yytext); return (t);
#endif

#include <strings.h>
extern SYMTABNODEPTR symTab[SYMTABSIZE];
extern int currentSymTabSize;
%}

digit                    [0-9]
letter                   [a-zA-Z]
number                   {digit}+
id                       [a-z][a-zA-Z0-9]*

%%
"cilk"                   TOKEN(CILK)
"spawn"                  TOKEN(SPAWN)
"Cilk_sync"              TOKEN(CILK_SYNC)
"Cilk_for"               TOKEN(CILK_FOR)
"printf"                 TOKEN(PRINT)
"return"                 TOKEN(RETURN)
"if"                     TOKEN(IF)
"else"                   TOKEN(ELSE)
"int"                    TOKEN(INT)
"char"                   TOKEN(CHAR)
"<"                      TOKEN(LT)
">"                      TOKEN(GT)
"<="                     TOKEN(LE)
">="                     TOKEN(GE)
"!="                     TOKEN(NE)
"!"                      TOKEN(NOT)
"=="                     TOKEN(EQ)
"&&"                     TOKEN(AND)
"||"                     TOKEN(OR)
"++"                     TOKEN(PP)
"--"                     TOKEN(MM)
"="                      TOKEN(ASSIGN)
"+"                      TOKEN(PLUS)
"-"                      TOKEN(MINUS)
"*"                      TOKEN(MULT)
"/"                      TOKEN(DIVIDE)
"%"                      TOKEN(MOD)
"("                      TOKEN(OPAREN)
")"                      TOKEN(CPAREN)
"{"                      TOKEN(OPCOR)
"}"                      TOKEN(CCOR)
";"                      TOKEN(SEMICOLON)
"+="                     TOKEN(PLUSEQ)
"-="                     TOKEN(MINUSEQ)
","                      TOKEN(COMA)
{number}                 INTEGER_TOKEN(INTEGER)
{id}                     ID_TOKEN(ID)
\"[^\n"]*\"              STRING_TOKEN(STRING)
\/\*[^"]*\*\/            ;
\/\/[^\n"]*              ;
"\n"                     ;
[[:space:]]+             ;
.                        printf("illegal token\n");
%%

SYMTABNODEPTR newSymTabNode() {
    return ((SYMTABNODEPTR)malloc(sizeof(SYMTABNODE)));
}

int installId(char *id){
    extern SYMTABNODEPTR symTab[SYMTABSIZE];
    extern int currentSymTabSize;
    int index;

    index = lookup(id);
    if(index >= 0){
        return (index);
    }else{
        if(currentSymTabSize >= SYMTABSIZE){
            /*symtab is full*/
            return (NOTHING);
        }else{
            symTab[currentSymTabSize] = newSymTabNode();
            strncpy(symTab[currentSymTabSize]->identifier,id,IDLENGTH);
            symTab[currentSymTabSize]->identifier[IDLENGTH-1] = '\0';
            return (currentSymTabSize++);
        }
    }
}

int lookup(char *s)
{
    extern SYMTABNODEPTR symTab[SYMTABSIZE];
    extern int currentSymTabSize;
    int i;

    for(i=0; i<currentSymTabSize; i++)
    {
        if(strncmp(s,symTab[i]->identifier,IDLENGTH) == 0)
        {
            return (i);
        }
    }
    return (-1);
}
