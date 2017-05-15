%{
  #include <stdio.h>
  #include <stdlib.h>

  #define SYMTABSIZE 37
  #define IDLENGTH 15
  #define NOTHING -1
  #define INDENTOFFSET 2

  enum ParseTreeNodeType { PROGRAM, DECLARATIONLIST, DECLARATION, VARDECLARATION,
                           VARDECLLIST, VARDECLID, TYPEESPECIFIER, FUNDECLARATION,
                           STATEMENT, EXPRESSIONSTMT, SELECTIONSTMT, ITERATIONSTMT,
                           EXPRESSION, SIMPLEEXPRESSION, ANDEXPRESSION, UNARYRELEXPRESSION,
                           RELEXPRESSION, RELOP, SUMEXPRESSION, SUMOP, RETURNSTMT, MUTABLE,
                           INTEGER_VALUE, STRING_VALUE, ID_VALUE
                         };

  char *NodeName[] = { "PROGRAM", "DECLARATIONLIST", "DECLARATION", "VARDECLARATION",
                       "VARDECLLIST", "VARDECLID", "TYPEESPECIFIER", "FUNDECLARATION",
                       "STATEMENT", "EXPRESSIONSTMT", "SELECTIONSTMT", "ITERATIONSTMT",
                       "EXPRESSION", "SIMPLEEXPRESSION", "ANDEXPRESSION", "UNARYRELEXPRESSION",
                       "RELEXPRESSION", "RELOP", "SUMEXPRESSION", "SUMOP", "RETURNSTMT", "MUTABLE",
                       "INTEGER_VALUE", "STRING_VALUE", "ID_VALUE"
                      };

  #ifndef TRUE
  #define TRUE 1
  #endif

  #ifndef FALSE
  #define FALSE 0
  #endif

  #ifndef NULL
  #define NULL 0
  #endif

  struct treeNode {
    int item;
    int nodeIdentifier;
    struct treeNode *first;
    struct treeNode *second;
    struct treeNode *third;
    struct treeNode *fourth;
    struct treeNode *fifth;
  };

  typedef struct treeNode TREE_NODE;

  typedef TREE_NODE *TERNARY_TREE;

  TERNARY_TREE create_node(int, int, TERNARY_TREE, TERNARY_TREE, TERNARY_TREE, TERNARY_TREE, TERNARY_TREE);

  struct symTabNode {
    char identifier[IDLENGTH];
  };

  typedef struct symTabNode SYMTABNODE;
  typedef SYMTABNODE *SYMTABNODEPTR;

  SYMTABNODEPTR symTab[SYMTABSIZE];

  int currentSymTabSize = 0;

%}

%start program

%union {
  int iVal;
  TERNARY_TREE tVal;
}

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

TERNARY_TREE create_node(int ival, int case_identifier, TERNARY_TREE p1,
                          TERNARY_TREE p2, TERNARY_TREE p3, TERNARY_TREE p4, TERNARY_TREE p5) {
  TERNARY_TREE t;
  t = (TERNARY_TREE)malloc(sizeof(TREE_NODE));
  t->item = ival;
  t->nodeIdentifier = case_identifier;
  t->first = p1;
  t->second = p2;
  t->third = p3;
  t->fourth = p4;
  t->fifth = p5;
  return (t);
}

#include "lex.yy.c"
