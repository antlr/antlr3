lexer grammar t010lexer;
options {
  language = Python3;
}

IDENTIFIER: ('a'..'z'|'A'..'Z'|'_') ('a'..'z'|'A'..'Z'|'0'..'9'|'_')*;
WS: (' ' | '\n')+;
