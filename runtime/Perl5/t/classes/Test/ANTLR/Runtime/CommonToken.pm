package Test::ANTLR::Runtime::CommonToken;

use Test::More;

use ANTLR::Runtime::Token;

use Moose;

BEGIN { extends 'My::Test::Class' }

sub constructor : Test(1) {
    my $token = ANTLR::Runtime::CommonToken->new({
        input => undef,
        type => 0,
        channel => 0,
        start => 0,
        stop => 1,
    });
    is $token->get_start_index(), 0;
}

sub same : Test(2) {
    ok(ANTLR::Runtime::Token->EOF_TOKEN == ANTLR::Runtime::Token->EOF_TOKEN);
    ok(ANTLR::Runtime::Token->SKIP_TOKEN == ANTLR::Runtime::Token->SKIP_TOKEN);
}

sub not_same : Test(2) {
    ok !(ANTLR::Runtime::Token->EOF_TOKEN  != ANTLR::Runtime::Token->EOF_TOKEN);
    ok !(ANTLR::Runtime::Token->SKIP_TOKEN != ANTLR::Runtime::Token->SKIP_TOKEN);
}

sub bool_eof : Test(1) {
    ok !ANTLR::Runtime::Token->EOF_TOKEN;
}

no Moose;
__PACKAGE__->meta->make_immutable(inline_constructor => 0);
1;
