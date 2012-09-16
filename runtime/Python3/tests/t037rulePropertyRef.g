grammar t037rulePropertyRef;
options {
  language = Python3;
}

a returns [bla]
@after {
    $bla = $start, $stop, $text
}
    : A+
    ;

A: 'a'..'z';

WS: ' '+  { $channel = HIDDEN };
