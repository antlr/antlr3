tree grammar TTree;

options {

    // Default but name it anyway
    //
    language   = Java;

    // Use the vocab from the parser (not the lexer)
    // The ANTLR Maven plugin knows how to work out the
    // relationships between the .g files and it will build
    // the tree parser after the parser. It will also rebuild
    // the tree parser if the parser is rebuilt.
    //
    tokenVocab = TParser;

    // Use ANTLR built-in CommonToken for tree nodes
    //
    ASTLabelType = CommonToken;
}

// What package should the generated source exist in?
//
@header {

    package ${package};
}

a : ^(SCRIPT stuff+)
  | SCRIPT
  ;

stuff
  : keyser
  | expression
  ;

keyser
  : ^(KEYSER SOZE)
    { System.out.println("Found Keyser Soze!!"); }
  ;

expression
  : ^(ADD expression expression)
  | ID
  | INT
  | STRING
  ;

