package ANTLR::Runtime::MismatchedTokenException;

use ANTLR::Runtime::Token;

use Moose;

use overload
    '""' => \&to_string,
    'bool' => sub { 1 },
    fallback => 1
    ;

extends 'ANTLR::Runtime::RecognitionException';

has 'expecting' => (
    is  => 'ro',
    isa => 'Int',
    default => ANTLR::Runtime::Token->INVALID_TOKEN_TYPE,
);

sub get_expecting {
    my ($self) = @_;
    return $self->expecting;
}

sub to_string {
    my ($self) = @_;
    return "MismatchedTokenException(" . $self->get_unexpected_type() . "!=" . $self->expecting . ")";
}

no Moose;
__PACKAGE__->meta->make_immutable();
1;
