package ANTLR::Runtime::Exception;

use Exception::Class;

use Moose;

extends 'Moose::Object', 'Exception::Class::Base';

sub BUILD {
    my ($self, $args) = @_;

    my %exception_args;
    if (exists $args->{message}) {
        $exception_args{message} = $args->{message};
    }

    $self->_initialize(%exception_args);
    return;
}

no Moose;
__PACKAGE__->meta->make_immutable();
1;
