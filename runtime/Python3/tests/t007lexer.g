lexer grammar t007lexer;
options {
  language = Python3;
}

FOO: 'f' ('o' | 'a' 'b'+)*;
