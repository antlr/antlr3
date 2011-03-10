package Test::ANTLR::Runtime::ANTLRStringStream;

use ANTLR::Runtime::ANTLRStringStream;
use Test::More;

use Moose;

BEGIN { extends 'My::Test::Class' }

sub consume : Test(2) {
    my ($self) = @_;

    my $s = $self->class->new({ input => 'ABC' });
    is $s->LA(1), 'A';
    $s->consume();
    is $s->LA(1), 'B';
}

sub LA : Test(5) {
    my ($self) = @_;

    my $s = $self->class->new({ input => 'ABC' });
    is $s->LA(0), undef;
    is $s->LA(1), 'A';
    is $s->LA(2), 'B';
    is $s->LA(3), 'C';
    is $s->LA(4), ANTLR::Runtime::ANTLRStringStream->EOF;
}

no Moose;
__PACKAGE__->meta->make_immutable(inline_constructor => 0);
1;
