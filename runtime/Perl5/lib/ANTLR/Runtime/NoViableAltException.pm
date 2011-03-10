package ANTLR::Runtime::NoViableAltException;

use Moose;

extends 'ANTLR::Runtime::RecognitionException';

has 'grammar_decision_description' => (
    is  => 'ro',
    isa => 'Str',
    required => 1,
);

has 'decision_number' => (
    is  => 'ro',
    isa => 'Int',
    required => 1,
);

has 'state_number' => (
    is  => 'ro',
    isa => 'Int',
    required => 1,
);

no Moose;
__PACKAGE__->meta->make_immutable();
1;
