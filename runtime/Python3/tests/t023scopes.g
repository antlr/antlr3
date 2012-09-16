grammar t023scopes;

options {
    language=Python3;
}

prog
scope {
name
}
    :   ID {$prog::name=$ID.text;}
    ;

ID  :   ('a'..'z')+
    ;

WS  :   (' '|'\n'|'\r')+ {$channel=HIDDEN}
    ;
