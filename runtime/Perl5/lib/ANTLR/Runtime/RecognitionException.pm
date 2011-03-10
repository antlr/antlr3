package ANTLR::Runtime::RecognitionException;

use Carp;
use Readonly;

use Moose;
use Moose::Util::TypeConstraints;

extends 'ANTLR::Runtime::Exception';

has 'input' => (
    is   => 'ro',
    does => 'ANTLR::Runtime::IntStream',
    required => 1,
);

has 'index' => (
    is  => 'ro',
    isa => 'Int',
    default => 0,
);

has 'token' => (
    is   => 'ro',
    does => 'ANTLR::Runtime::Token',
);

has 'node' => (
    is  => 'ro',
    isa => 'Any',
);

subtype 'Char'
    => as 'Str'
    => where { $_ eq '-1' || length == 1 };

has 'c' => (
    is  => 'ro',
    isa => 'Maybe[Char]',
);

has 'line' => (
    is  => 'ro',
    isa => 'Int',
    default => 0,
);

has 'char_position_in_line' => (
    is  => 'ro',
    isa => 'Int',
    default => 0,
);

has 'approximate_line_info' => (
    is  => 'rw',
    isa => 'Bool',
);

sub BUILDARGS {
    my ($class, @args) = @_;
    my $args = $class->SUPER::BUILDARGS(@args);

    my $new_args = { %$args };
    my $input = $args->{input};
    $new_args->{input} = $input;
    $new_args->{index} = $input->index();

    if ($input->does('ANTLR::Runtime::TokenStream')) {
        my $token = $input->LT(1);
        $new_args->{token} = $token;
        $new_args->{line} = $token->get_line();
        $new_args->{char_position_in_line} = $token->get_char_position_in_line();
    }

    if ($input->does('ANTLR::Runtime::TreeNodeStream')) {
        # extract_information_from_tree_node_stream($input);
    }
    elsif ($input->does('ANTLR::Runtime::CharStream')) {
        $new_args->{c} = $input->LA(1);
        $new_args->{line} = $input->get_line();
        $new_args->{char_position_in_line} = $input->get_char_position_in_line();
    }
    else {
        $new_args->{c} = $input->LA(1);
    }

    return $new_args;
}

sub get_unexpected_type {
    my ($self) = @_;

    if ($self->input->isa('ANTLR::Runtime::TokenStream')) {
        return $self->token->get_type();
    } else {
        return $self->c;
    }
}

sub get_c {
    my ($self) = @_;
    return $self->c;
}

sub get_line {
    my ($self) = @_;
    return $self->line;
}

sub get_char_position_in_line {
    my ($self) = @_;
    return $self->char_position_in_line;
}

sub get_token {
    my ($self) = @_;
    return $self->token;
}

no Moose;
__PACKAGE__->meta->make_immutable();
1;
