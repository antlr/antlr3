lexer grammar t029synpredgate;
options {
  language = Python3;
}

FOO
    : ('ab')=> A
    | ('ac')=> B
    ;

fragment
A: 'a';

fragment
B: 'a';

