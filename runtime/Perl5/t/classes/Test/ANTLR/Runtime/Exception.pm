package Test::ANTLR::Runtime::Exception;

use Test::More;

use Moose;

BEGIN { extends 'My::Test::Class' }

sub constructor : Test(1) {
    my ($self) = @_;
    my $ex = $self->class->new();
    is $ex->message, '';
}

sub constructor_message : Test(1) {
    my ($self) = @_;
    my $ex = $self->class->new({ message => 'test error message' });
    is $ex->message, 'test error message';
}

sub throw : Test(1) {
    my ($self) = @_;
    eval {
        $self->class->throw(message => 'test error message');
    };
    my $ex = $self->class->caught();
    is $ex->message, 'test error message';
}

no Moose;
__PACKAGE__->meta->make_immutable(inline_constructor => 0);
1;
