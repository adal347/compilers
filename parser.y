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
                           INTEGER_VALUE, STRING_VALUE, ID_VALUE, CHARACTER_VALUE
                         };

  char *NodeName[] = { "PROGRAM", "DECLARATIONLIST", "DECLARATION", "VARDECLARATION",
                       "VARDECLLIST", "VARDECLID", "TYPEESPECIFIER", "FUNDECLARATION",
                       "STATEMENT", "EXPRESSIONSTMT", "SELECTIONSTMT", "ITERATIONSTMT",
                       "EXPRESSION", "SIMPLEEXPRESSION", "ANDEXPRESSION", "UNARYRELEXPRESSION",
                       "RELEXPRESSION", "RELOP", "SUMEXPRESSION", "SUMOP", "RETURNSTMT", "MUTABLE",
                       "INTEGER_VALUE", "STRING_VALUE", "ID_VALUE", "CHARACTER_VALUE"
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
  #ifdef DEBUG
  void printTree(TERNARY_TREE, int);
  #endif
  void writeCode(TERNARY_TREE);

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

%token CILK MAIN SPAWN CILK_SYNC CILK_FOR PRINT RETURN
       IF ELSE INT CHAR LT GT LE GE NE NOT EQ AND
       OR PP MM ASSIGN PLUS MINUS MULT DIVIDE MOD
       OPAREN CPAREN OPCOR CCOR SEMICOLON PLUSEQ
       MINUSEQ COMA
%token<iVal> ID INTEGER STRING CHARACTER

%type<tVal> program declarationList declaration varDeclaration
             varDeclList varDeclId typeSpecifier funDeclaration
             statement expressionStmt selectionStmt iterationStmt
             expression simpleExpression andExpression unaryRelExpression
             relExpression relop sumExpression sumop returnStmt mutable


%%

program : declarationList
          {
            TERNARY_TREE ParseTree;
            ParseTree = create_node(NOTHING, PROGRAM, $1, NULL, NULL, NULL, NULL);
            #ifdef DEBUG
            printTree(ParseTree, 0);
            #endif
            writeCode(ParseTree);
          }
;

declarationList : declaration declarationList
                    {
                      $$ = create_node(NOTHING, DECLARATIONLIST, $1, $2, NULL, NULL, NULL);
                    }
                  | declaration
                    {
                      $$ = create_node(NOTHING, DECLARATIONLIST, $1, NULL, NULL, NULL, NULL);
                    }
;

declaration : varDeclaration
                {
                  $$ = create_node(NOTHING, DECLARATION, $1, NULL, NULL, NULL, NULL);
                }
              | funDeclaration
                {
                  $$ = create_node(NOTHING, DECLARATION, $1, NULL, NULL, NULL, NULL);
                }
;

varDeclaration : typeSpecifier varDeclList SEMICOLON
                    {
                      $$ = create_node(NOTHING, VARDECLARATION, $1, $2, NULL, NULL, NULL);
                    }
;

varDeclList : varDeclList COMA varDeclId
                {
                  $$ = create_node(COMA, VARDECLLIST, $1, $3, NULL, NULL, NULL);
                }
              | varDeclId
                {
                  $$ = create_node(NOTHING, VARDECLLIST, $1, NULL, NULL, NULL, NULL);
                }
;

varDeclId : ID
            {
              $$ = create_node($1, ID_VALUE, NULL, NULL, NULL, NULL, NULL);
            }
;

typeSpecifier : INT
                {
                  $$ = create_node(INT, TYPEESPECIFIER, NULL, NULL, NULL, NULL, NULL);
                }
                | CHAR
                {
                  $$ = create_node(CHAR, TYPEESPECIFIER, NULL, NULL, NULL, NULL, NULL);
                }
;

funDeclaration : CILK INT MAIN OPAREN CPAREN OPCOR statement CCOR
                  {
                    $$ = create_node(NOTHING, FUNDECLARATION, $7, NULL, NULL, NULL, NULL);
                  }
;

statement : expressionStmt
              {
                $$ = create_node(NOTHING, STATEMENT, $1, NULL, NULL, NULL, NULL);
              }
            | selectionStmt
              {
                $$ = create_node(NOTHING, STATEMENT, $1, NULL, NULL, NULL, NULL);
              }
            | iterationStmt
              {
                $$ = create_node(NOTHING, STATEMENT, $1, NULL, NULL, NULL, NULL);
              }
            | returnStmt
              {
                $$ = create_node(NOTHING, STATEMENT, $1, NULL, NULL, NULL, NULL);
              }
;

expressionStmt : expression SEMICOLON statement
                  {
                    $$ = create_node(NOTHING, EXPRESSIONSTMT, $1, $3, NULL, NULL, NULL);
                  }
                 | expression SEMICOLON
                  {
                    $$ = create_node(NOTHING, EXPRESSIONSTMT, $1, NULL, NULL, NULL, NULL);
                  }
                 | SEMICOLON
                  {
                    $$ = create_node(SEMICOLON, DECLARATIONLIST, NULL, NULL, NULL, NULL, NULL);
                  }
;

selectionStmt : IF OPAREN simpleExpression CPAREN OPCOR statement CCOR statement
                  {
                    $$ = create_node(NOTHING, SELECTIONSTMT, $3, $6, $8, NULL, NULL);
                  }
                | IF OPAREN simpleExpression CPAREN OPCOR statement CCOR ELSE OPCOR statement CCOR statement
                  {
                    $$ = create_node(ELSE, SELECTIONSTMT, $3, $6, $10, $12, NULL);
                  }
;

iterationStmt : CILK_FOR OPAREN expression SEMICOLON relExpression SEMICOLON expression CPAREN OPCOR statement CCOR statement
                {
                  $$ = create_node(NOTHING, ITERATIONSTMT, $3, $5, $7, $10, $12);
                }
;

expression : typeSpecifier varDeclList
                {
                  $$ = create_node(NOTHING, EXPRESSION, $1, $2, NULL, NULL, NULL);
                }
             | mutable ASSIGN sumExpression
                {
                  $$ = create_node(ASSIGN, EXPRESSION, $1, $3, NULL, NULL, NULL);
                }
             | mutable PLUSEQ mutable
                {
                  $$ = create_node(PLUSEQ, EXPRESSION, $1, $3, NULL, NULL, NULL);
                }
             | mutable MINUSEQ mutable
                {
                  $$ = create_node(MINUSEQ, EXPRESSION, $1, $3, NULL, NULL, NULL);
                }
             | mutable PP
                {
                  $$ = create_node(PP, EXPRESSION, $1, NULL, NULL, NULL, NULL);
                }
             | mutable MM
                {
                  $$ = create_node(MM, EXPRESSION, $1, NULL, NULL, NULL, NULL);
                }
             | simpleExpression
                {
                  $$ = create_node(NOTHING, EXPRESSION, $1, NULL, NULL, NULL, NULL);
                }
             | sumExpression
                {
                  $$ = create_node(NOTHING, EXPRESSION, $1, NULL, NULL, NULL, NULL);
                }
             | printExpression
                {
                  $$ = create_node(NOTHING, EXPRESSION, $1, NULL, NULL, NULL, NULL);
                }
;

simpleExpression : simpleExpression OR andExpression
                    {
                      $$ = create_node(OR, SIMPLEEXPRESSION, $1, $3, NULL, NULL, NULL);
                    }
                   | andExpression
                    {
                      $$ = create_node(NOTHING, SIMPLEEXPRESSION, $1, NULL, NULL, NULL, NULL);
                    }
;

printExpression : PRINT OPCOR STRING CCOR
                    {
                      $$ = create_node($3, STRING_VALUE, NULL, NULL, NULL, NULL, NULL);
                    }
;

andExpression : andExpression AND unaryRelExpression
                  {
                    $$ = create_node(AND, ANDEXPRESSION, $1, $3, NULL, NULL, NULL);
                  }
                | unaryRelExpression
                  {
                    $$ = create_node(NOTHING, ANDEXPRESSION, $1, NULL, NULL, NULL, NULL);
                  }
;

unaryRelExpression : NOT unaryRelExpression
                      {
                        $$ = create_node(NOT, UNARYRELEXPRESSION, $2, NULL, NULL, NULL, NULL);
                      }
                     | relExpression
                      {
                        $$ = create_node(NOTHING, UNARYRELEXPRESSION, $1, NULL, NULL, NULL, NULL);
                      }
;

relExpression : mutable relop mutable
                {
                  $$ = create_node(NOTHING, RELEXPRESSION, $1, $2, $3, NULL, NULL);
                }
;

relop : LE
          {
            $$ = create_node(LE, RELOP, NULL, NULL, NULL, NULL, NULL);
          }
        | LT
          {
            $$ = create_node(LT, RELOP, NULL, NULL, NULL, NULL, NULL);
          }
        | GT
          {
            $$ = create_node(GT, RELOP, NULL, NULL, NULL, NULL, NULL);
          }
        | GE
          {
              $$ = create_node(GE, RELOP, NULL, NULL, NULL, NULL, NULL);
          }
        | EQ
          {
              $$ = create_node(EQ, RELOP, NULL, NULL, NULL, NULL, NULL);
          }
        | NE
          {
            $$ = create_node(NE, RELOP, NULL, NULL, NULL, NULL, NULL);
          }
;

sumExpression : mutable sumop sumExpression
                  {
                    $$ = create_node(NOTHING, SUMEXPRESSION, $1, $2, $3, NULL, NULL);
                  }
                | mutable
                  {
                    $$ = create_node(NOTHING, SUMEXPRESSION, $1, NULL, NULL, NULL, NULL);
                  }
;

sumop : PLUS
          {
            $$ = create_node(PLUS, SUMOP, NULL, NULL, NULL, NULL, NULL);
          }
        | MINUS
          {
            $$ = create_node(PLUS, SUMOP, NULL, NULL, NULL, NULL, NULL);
          }
;

returnStmt : RETURN mutable SEMICOLON
              {
                $$ = create_node(NOTHING, RETURNSTMT, $2, NULL, NULL, NULL, NULL);
              }
;

mutable : ID
            {
              $$ = create_node($1, ID_VALUE, NULL, NULL, NULL, NULL, NULL);
            }
          | INTEGER
            {
              $$ = create_node($1, INTEGER_VALUE, NULL, NULL, NULL, NULL, NULL);
            }
          | CHARACTER
            {
              $$ = create_node($1, CHARACTER_VALUE, NULL, NULL, NULL, NULL, NULL);
            }
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

#ifdef DEBUG
void printTree(TERNARY_TREE t, int indent) {
  int i = 0;
  if (t == NULL) return;
  for (i = indent; i; i--) printf(" ");
  if(t->nodeIdentifier == INTEGER_VALUE)
    printf("Integer: %d ", t->item);
  else if(t->nodeIdentifier == STRING_VALUE)
    if(t->item > 0 && t->item < SYMTABSIZE)
      printf("String: %s ", symTab[t->item]->identifier);
    else
      printf("Unknown identifier: %d ", t->item);
  else if(t->nodeIdentifier == ID_VALUE)
    if(t->item > 0 && t->item < SYMTABSIZE)
      printf("Identifier: %s ", symTab[t->item]->identifier);
    else
      printf("Unknown identifier: %d", t->item);
  if (t->item != NOTHING) printf("Item: %d ", t->item);
  if (t->nodeIdentifier < 0 || t->nodeIdentifier > sizeof(NodeName))
    printf("Uknown nodeIdentifier: %d\n", t->nodeIdentifier);
  else
    printf("nodeIdentifier %s\n", NodeName[t->nodeIdentifier]);
  printTree(t->first, indent+3);
  printTree(t->second, indent+3);
  printTree(t->third, indent+3);
  printTree(t->fourth, indent+3);
  printTree(t->fifth, indent+3);
}
#endif

void writeCode(TERNARY_TREE t) {

  if (t == NULL) return;
  switch(t->nodeIdentifier) {
    case (PROGRAM):
      printf("#include <stdio.h>\n");
      printf("#include <stdlib.h>\n");
      writeCode(t->first);
      return;
    case (DECLARATIONLIST):
      if (t->second == NULL) writeCode(t->first);
      else {
        writeCode(t->first);
        writeCode(t->second);
      }
      return;
    case (VARDECLARATION):
      writeCode(t->first);
      writeCode(t->second);
      printf(";\n");
      return;
    case (VARDECLLIST):
      writeCode(t->first);
      if(t->second != NULL) {
        printf(", ");
        writeCode(t->second);
      }
      return;
    case (VARDECLID):
      if(t->item > 0 && t->item < SYMTABSIZE)
        printf("%s ", symTab[t->item]->identifier);
      else
        printf("ID ");
      return;
    case (TYPEESPECIFIER):
      if(t->item == INT)
        printf("int ");
      else
        printf("char ");
      return;
    case (FUNDECLARATION):
      printf("int main(){\n" );
      writeCode(t->first);
      printf("}\n");
      return;
    case (EXPRESSIONSTMT):
      if (t->item == SEMICOLON) printf(";\n");
      else if(t->second == NULL) {
        writeCode(t->first);
        printf(";\n");
      } else {
        writeCode(t->first);
        printf(";\n");
        writeCode(t->second);
      }
      return;
    case (SELECTIONSTMT):
      if (t->item != ELSE) {
        printf("if (");
        writeCode(t->first);
        printf(") {\n");
        writeCode(t->second);
        printf("}\n");
        writeCode(t->third);
      } else {
        printf("if (");
        writeCode(t->first);
        printf(") {\n");
        writeCode(t->second);
        printf("} else {\n");
        writeCode(t->third);
        printf("}\n");
        writeCode(t->fourth);
      }
      return;
    case (ITERATIONSTMT):
      printf("for (");
      writeCode(t->first);
      printf("; ");
      writeCode(t->second);
      printf("; ");
      writeCode(t->third);
      printf(") {\n");
      writeCode(t->fourth);
      printf("}\n");
      writeCode(t->fifth);
      return;
    case (EXPRESSION):
      if (t->item == NOTHING && t->second != NULL) {
        writeCode(t->first);
        writeCode(t->second);
      } else if (t->item == ASSIGN) {
        writeCode(t->first);
        printf(" = ");
        writeCode(t->second);
      } else if (t->item == PLUSEQ) {
        writeCode(t->first);
        printf(" += ");
        writeCode(t->second);
      } else if (t->item == MINUSEQ) {
        writeCode(t->first);
        printf(" -= ");
        writeCode(t->second);
      } else if (t->item == PP) {
        writeCode(t->first);
        printf("++");
      } else if (t->item == MM) {
        writeCode(t->first);
        printf("--");
      } else {
        writeCode(t->first);
      }
      return;
    case (SIMPLEEXPRESSION):
      if (t->second != NULL) {
        writeCode(t->first);
        printf(" || ");
        writeCode(t->second);
      } else {
        writeCode(t->first);
      }
      return;
    case (ANDEXPRESSION):
      if (t->second != NULL) {
        writeCode(t->first);
        printf(" && ");
        writeCode(t->second);
      } else {
        writeCode(t->first);
      }
      return;
    case (UNARYRELEXPRESSION):
      if (t->item == NOT) {
        printf("!");
        writeCode(t->first);
      } else {
        writeCode(t->first);
      }
      return;
    case (RELEXPRESSION):
      writeCode(t->first);
      writeCode(t->second);
      writeCode(t->third);
      return;
    case (RELOP):
      if (t->item == LE) {
        printf(" <= ");
      } else if (t->item == LT) {
        printf(" < ");
      } else if (t->item == GT) {
        printf(" > ");
      } else if (t->item == GE) {
        printf(" >= ");
      } else if (t->item == EQ) {
        printf(" == ");
      } else if (t->item == NE) {
        printf(" != ");
      }
      return;
    case (SUMEXPRESSION):
      writeCode(t->first);
      writeCode(t->second);
      writeCode(t->third);
      return;
    case (SUMOP):
      if (t->item == PLUS) {
        printf(" + ");
      } else {
        printf(" - ");
      }
      return;
    case (RETURNSTMT):
      printf("return ");
      writeCode(t->first);
      printf(";\n");
      return;
    case (STRING_VALUE):
      if(t->item > 0 && t->item < SYMTABSIZE)
        printf("printf(%s)", symTab[t->item]->identifier);
      else
        printf("STRING ");
      return;
    case (INTEGER_VALUE):
      printf("%d", t->item);
      return;
    case (ID_VALUE):
      if(t->item > 0 && t->item < SYMTABSIZE)
        printf("%s ", symTab[t->item]->identifier);
      else
        printf("a ");
      return;
    case (CHARACTER_VALUE):
      if(t->item > 0 && t->item < SYMTABSIZE)
        printf("%s ", symTab[t->item]->identifier);
      else
        printf("CHAR ");
      return;
    default:
      writeCode(t->first);
      return;
  }
  writeCode(t->first);
  writeCode(t->second);
  writeCode(t->third);
  writeCode(t->fourth);
  writeCode(t->fifth);
}

#include "lex.yy.c"
