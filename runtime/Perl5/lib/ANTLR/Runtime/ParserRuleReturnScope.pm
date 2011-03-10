package ANTLR::Runtime::ParserRuleReturnScope;

use Moose;

extends 'ANTLR::Runtime::RuleReturnScope';

has 'start' => (
    is   => 'rw',
    does => 'ANTLR::Runtime::Token',
);

has 'stop' => (
    is   => 'rw',
    does => 'ANTLR::Runtime::Token',
);

sub get_start {
    my ($self) = @_;
    return $self->start;
}

sub get_stop {
    my ($self) = @_;
    return $self->stop;
}

no Moose;
__PACKAGE__->meta->make_immutable();
1;
__END__
