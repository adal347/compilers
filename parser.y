%token CILK SPAWN CILK_SYNC CILK_FOR PRINT RETURN
       IF ELSE INT CHAR LT GT LE GE NE NOT EQ AND
       OR PP MM ASSIGN PLUS MINUS MULT DIVIDE MOD
       OPAREN CPAREN OPCOR CCOR SEMICOLON PLUSEQ
       MINUSEQ COMA
%token ID INTEGER STRING

%%

program : declarationList
;

declarationList : declaration declarationList
                  | declaration
;

declaration : varDeclaration
              | funDeclaration
;

varDeclaration : typeSpecifier varDeclList SEMICOLON
;

varDeclList : varDeclList COMA varDeclId
              | varDeclId
;

varDeclId : ID
;

typeSpecifier : INT
                | CHAR
;

funDeclaration : CILK typeSpecifier ID OPAREN CPAREN OPCOR statement CCOR
;

statement : expressionStmt
            | selectionStmt
            | iterationStmt
            | returnStmt
;

expressionStmt : expression SEMICOLON statement
                 | expression SEMICOLON
                 | SEMICOLON
;

selectionStmt : IF OPAREN simpleExpression CPAREN OPCOR statement CCOR statement
                | IF OPAREN simpleExpression CPAREN OPCOR statement CCOR ELSE OPCOR statement CCOR statement
;

iterationStmt : CILK_FOR OPAREN expression SEMICOLON relExpression SEMICOLON expression CPAREN OPCOR statement CCOR statement
;

expression : typeSpecifier varDeclList
             | mutable ASSIGN sumExpression
             | mutable PLUSEQ mutable
             | mutable MINUSEQ mutable
             | mutable PP
             | mutable MM
             | simpleExpression
             | sumExpression
;

simpleExpression : simpleExpression OR andExpression
                   | andExpression
;

andExpression : andExpression AND unaryRelExpression
                | unaryRelExpression
;

unaryRelExpression : NOT unaryRelExpression
                     | relExpression
;

relExpression : mutable relop mutable
;

relop : LE
        | LT
        | GT
        | GE
        | EQ
        | NE
;

sumExpression : mutable sumop sumExpression
                | mutable
;

sumop : PLUS
        | MINUS
;

returnStmt : RETURN mutable SEMICOLON
;

mutable : ID
          | INTEGER
          | STRING
;

%%
#include "lex.yy.c"
