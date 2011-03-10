package ANTLR::Runtime::TokenStream;

use Moose::Role;
#extends 'ANTLR::Runtime::IntStream';

requires 'LT';

requires 'get';

requires 'get_token_source';

requires 'to_string';

no Moose::Role;
1;
__END__
