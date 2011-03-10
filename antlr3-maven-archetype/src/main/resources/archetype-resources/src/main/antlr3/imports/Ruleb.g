// A single rule in a grammar that must be imported by the demo
// parser Tparser.g
// This is just here to show that import grammars are stored in their
// own imports directory: src/main/antlr3/imports
//
parser grammar Ruleb;

b
   : keyser SEMI!
   | expression SEMI!
   ;
