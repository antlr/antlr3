package ANTLR::Runtime::UnwantedTokenException;

use Moose;

use overload
    '""' => \&to_string;

extends 'ANTLR::Runtime::MismatchedTokenException';

sub get_unexpected_token {
    my ($self) = @_;
    return $self->token;
}

sub to_string {
    my ($self) = @_;

    my $exp;
    if ($self->expecting == ANTLR::Runtime::Token->INVALID_TOKEN_TYPE) {
        $exp = '';
    }
    else {
        $exp = ", expected " . $self->expecting;
    }

    if (defined $self->token) {
        return "UnwantedTokenException(found=" . $self->token->get_text() . "$exp)";
    }
    else {
        return "UnwantedTokenException(found=undef$exp)";
    }
}

no Moose;
__PACKAGE__->meta->make_immutable();
1;
__END__
