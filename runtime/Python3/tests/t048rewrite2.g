lexer grammar t048rewrite2;
options {
    language=Python3;
}

ID : 'a'..'z'+;
INT : '0'..'9'+;
SEMI : ';';
PLUS : '+';
MUL : '*';
ASSIGN : '=';
WS : ' '+;
