package ANTLR::Runtime::ANTLRStringStream;

use Carp;
use Readonly;

use ANTLR::Runtime::CharStreamState;

use Moose;

with 'ANTLR::Runtime::IntStream', 'ANTLR::Runtime::CharStream';

has 'input' => (
    is  => 'ro',
    isa => 'Str',
    required => 1,
);

has 'p' => (
    is  => 'rw',
    isa => 'Int',
    default => 0,
);

has 'line' => (
    is  => 'rw',
    isa => 'Int',
    default => 1,
);

has 'char_position_in_line' => (
    is  => 'rw',
    isa => 'Int',
    default => 0,
);

has 'mark_depth' => (
    is  => 'rw',
    isa => 'Int',
    default => 0,
);

has 'markers' => (
    is  => 'rw',
    isa => 'ArrayRef[Maybe[ANTLR::Runtime::CharStreamState]]',
    default => sub { [ undef ] },
);

has 'last_marker' => (
    is  => 'rw',
    isa => 'Int',
    default => 0,
);

has 'name' => (
    is  => 'rw',
    isa => 'Str',
    default => q{},
);

sub get_line {
    my ($self) = @_;
    return $self->line;
}

sub set_line {
    my ($self, $value) = @_;
    $self->line($value);
    return;
}

sub get_char_position_in_line {
    my ($self) = @_;
    return $self->char_position_in_line;
}

sub set_char_position_in_line {
    my ($self, $value) = @_;
    $self->char_position_in_line($value);
    return;
}

sub reset {
    my ($self) = @_;

    $self->p(0);
    $self->line(1);
    $self->char_position_in_line(0);
    $self->mark_depth(0);
    return;
}

sub consume {
    my ($self) = @_;

    if ($self->p < length $self->input) {
        $self->char_position_in_line($self->char_position_in_line + 1);
        if (substr($self->input, $self->p, 1) eq "\n") {
            $self->line($self->line + 1);
            $self->char_position_in_line(0);
        }
        $self->p($self->p + 1);
    }
    return;
}

sub LA {
    my ($self, $i) = @_;

    if ($i == 0) {
        return undef;
    }

    if ($i < 0) {
        ++$i; # e.g., translate LA(-1) to use offset i=0; then input[p+0-1]
        if ($self->p + $i - 1 < 0) {
            return $self->EOF;
        }
    }

    if ($self->p + $i - 1 >= length $self->input) {
        return $self->EOF;
    }

    return substr $self->input, $self->p + $i - 1, 1;
}

sub LT {
    my ($self, $i) = @_;

    return $self->LA($i);
}

sub index {
    my ($self) = @_;

    return $self->p;
}

sub size {
    my ($self) = @_;

    return length $self->input;
}

sub mark {
    my ($self) = @_;

    $self->mark_depth($self->mark_depth + 1);
    my $state;
    if ($self->mark_depth >= @{$self->markers}) {
        $state = ANTLR::Runtime::CharStreamState->new();
        push @{$self->markers}, $state;
    } else {
        $state = $self->markers->[$self->mark_depth];
    }

    $state->set_p($self->p);
    $state->set_line($self->line);
    $state->set_char_position_in_line($self->char_position_in_line);
    $self->last_marker($self->mark_depth);

    return $self->mark_depth;
}

sub rewind {
    my $self = shift;
    my $m;
    if (@_ == 0) {
        $m = $self->last_marker;
    } else {
        $m = shift;
    }

    my $state = $self->markers->[$m];
    # restore stream state
    $self->seek($state->get_p);
    $self->line($state->get_line);
    $self->char_position_in_line($state->get_char_position_in_line);
    $self->release($m);
    return;
}

sub release {
    my ($self, $marker) = @_;

    # unwind any other markers made after m and release m
    $self->mark_depth($marker);
    # release this marker
    $self->mark_depth($self->mark_depth - 1);
    return;
}

# consume() ahead unit p == index; can't just set p = index as we must update
# line and char_position_in_line
sub seek {
    my ($self, $index) = @_;

    if ($index <= $self->p) {
        # just jump; don't update stream state (line, ...)
        $self->p($index);
        return;
    }

    # seek forward, consume until p hits index
    while ($self->p < $index) {
        $self->consume();
    }
    return;
}

sub substring {
    my ($self, $start, $stop) = @_;

    return substr $self->input, $start, $stop - $start + 1;
}

sub get_source_name {
    my ($self) = @_;
    return $self->name;
}

no Moose;
__PACKAGE__->meta->make_immutable();
1;
