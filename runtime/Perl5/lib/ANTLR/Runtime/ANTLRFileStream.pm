package ANTLR::Runtime::ANTLRFileStream;

use Carp;
use Readonly;

use Moose;

extends 'ANTLR::Runtime::ANTLRStringStream';

has 'file_name' => (
    is  => 'ro',
    isa => 'Str',
    required => 1,
);

sub BUILDARGS {
    my ($class, @args) = @_;
    my $args = $class->SUPER::BUILDARGS(@args);

    my $file_name = $args->{file_name};
    if (!defined $file_name) {
        return;
    }

    my $fh;
    my $encoding = $args->{encoding};
    if (defined $encoding) {
        open $fh, "<:encoding($encoding)", $file_name
            or croak "Can't open $file_name: $!";
    }
    else {
        open $fh, '<', $file_name
            or croak "Can't open $file_name: $!";
    }

    my $content;
    {
        local $/;
        $content = <$fh>;
    }
    close $fh or carp "Can't close $fh: $!";

    $args->{input} = $content;

    return $args;
}

sub load {
    my ($self, $file_name, $encoding) = @_;

    if (!defined $file_name) {
        return;
    }

    my $fh;
    if (defined $encoding) {
        open $fh, "<:encoding($encoding)", $file_name
            or croak "Can't open $file_name: $!";
    }
    else {
        open $fh, '<', $file_name
            or croak "Can't open $file_name: $!";
    }

    my $content;
    {
        local $/;
        $content = <$fh>;
    }
    close $fh or carp "Can't close $fh: $!";

    $self->input($content);
    return;
}

sub get_source_name {
    my ($self) = @_;
    return $self->file_name;
}

no Moose;
__PACKAGE__->meta->make_immutable();
1;
__END__
