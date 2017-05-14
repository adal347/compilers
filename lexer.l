%{
#ifdef PRINT
#define TOKEN(t) printf("Token: " #t "\n");
#else
#define TOKEN(t) return (t);
#endif
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
{number}                 TOKEN(INTEGER)
{id}                     TOKEN(ID)
\"[^\n"]*\"              TOKEN(STRING)
\/\*[^"]*\*\/            ;
\/\/[^\n"]*              ;
"\n"                     ;
[[:space:]]+             ;
.                        printf("illegal token\n");
%%
