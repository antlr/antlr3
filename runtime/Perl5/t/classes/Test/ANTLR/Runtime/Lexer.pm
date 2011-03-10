package Test::ANTLR::Runtime::Lexer;

use Test::More;

use ANTLR::Runtime::ANTLRStringStream;
use ANTLR::Runtime::Lexer;

use Moose;

BEGIN { extends 'My::Test::Class' }

sub constructor : Test(1) {
    my $input = ANTLR::Runtime::ANTLRStringStream->new({ input => 'ABC' });
    my $lexer = ANTLR::Runtime::Lexer->new({ input => $input });
    ok defined $lexer;
}

no Moose;
__PACKAGE__->meta->make_immutable(inline_constructor => 0);
1;
