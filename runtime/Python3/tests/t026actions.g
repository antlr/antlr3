grammar t026actions;
options {
  language = Python3;
}

@lexer::init {
    self.foobar = 'attribute;'
}

prog
@init {
    self.capture('init;')
}
@after {
    self.capture('after;')
}
    :   IDENTIFIER EOF
    ;
    catch [ RecognitionException as exc ] {
        self.capture('catch;')
        raise
    }
    finally {
        self.capture('finally;')
    }


IDENTIFIER
    : ('a'..'z'|'A'..'Z'|'_') ('a'..'z'|'A'..'Z'|'0'..'9'|'_')*
        {
            # a comment
          self.capture('action;')
            self.capture('{!r} {!r} {!r} {!r} {!r} {!r} {!r} {!r};'.format($text, $type, $line, $pos, $index, $channel, $start, $stop))
            if True:
                self.capture(self.foobar)
        }
    ;

WS: (' ' | '\n')+;
