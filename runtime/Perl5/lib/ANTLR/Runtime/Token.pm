package ANTLR::Runtime::Token;

use Readonly;

use feature qw( state );

use ANTLR::Runtime::CharStream;
#use ANTLR::Runtime::CommonToken;

use Moose::Role;

Readonly my $EOR_TOKEN_TYPE => 1;
sub EOR_TOKEN_TYPE { $EOR_TOKEN_TYPE }

# imaginary tree navigation type; traverse "get child" link
Readonly my $DOWN => 2;
sub DOWN { $DOWN }

# imaginary tree navigation type; finish with a child list
Readonly my $UP => 3;
sub UP { $UP }

Readonly my $MIN_TOKEN_TYPE => $UP + 1;
sub MIN_TOKEN_TYPE { $MIN_TOKEN_TYPE }

# All tokens go to the parser (unless skip() is called in that rule)
# on a particular "channel".  The parser tunes to a particular channel
# so that whitespace etc... can go to the parser on a "hidden" channel.
Readonly my $DEFAULT_CHANNEL => 0;
sub DEFAULT_CHANNEL { $DEFAULT_CHANNEL }

# Anything on different channel than DEFAULT_CHANNEL is not parsed
# by parser.
Readonly my $HIDDEN_CHANNEL => 99;
sub HIDDEN_CHANNEL { $HIDDEN_CHANNEL }

sub EOF { ANTLR::Runtime::CharStream->EOF }

#Readonly my $EOF_TOKEN => ANTLR::Runtime::CommonToken->new({ type => EOF });
sub EOF_TOKEN {
    require ANTLR::Runtime::CommonToken;
    state $EOF_TOKEN = ANTLR::Runtime::CommonToken->new({ type => EOF });
    return $EOF_TOKEN;
}

Readonly my $INVALID_TOKEN_TYPE => 0;
sub INVALID_TOKEN_TYPE { $INVALID_TOKEN_TYPE }

#Readonly my $INVALID_TOKEN => ANTLR::Runtime::CommonToken->new({ type => INVALID_TOKEN_TYPE });
sub INVALID_TOKEN {
    require ANTLR::Runtime::CommonToken;
    state $INVALID_TOKEN = ANTLR::Runtime::CommonToken->new({ type => INVALID_TOKEN_TYPE });
    return $INVALID_TOKEN;
}

# In an action, a lexer rule can set token to this SKIP_TOKEN and ANTLR
# will avoid creating a token for this symbol and try to fetch another.
#Readonly my $SKIP_TOKEN => ANTLR::Runtime::CommonToken->new({ type => INVALID_TOKEN_TYPE });
sub SKIP_TOKEN {
    require ANTLR::Runtime::CommonToken;
    state $SKIP_TOKEN = ANTLR::Runtime::CommonToken->new({ type => INVALID_TOKEN_TYPE });
    return $SKIP_TOKEN;
}

requires 'get_text', 'set_text';

requires 'get_type', 'set_type';

requires 'get_line', 'set_line';

requires 'get_char_position_in_line', 'set_char_position_in_line';

requires 'get_channel', 'set_channel';

requires 'get_token_index', 'set_token_index';

requires 'get_input_stream', 'set_input_stream';

no Moose::Role;
1;
