package ANTLR::Runtime::CharStream;

use Carp;
use Readonly;

use Moose::Role;
#extends 'ANTLR::Runtime::IntStream';

Readonly my $EOF => -1;
sub EOF { return $EOF }

requires 'substring';

requires 'LT';

requires 'get_line', 'set_line';

requires 'get_char_position_in_line', 'set_char_position_in_line';

no Moose::Role;
1;
