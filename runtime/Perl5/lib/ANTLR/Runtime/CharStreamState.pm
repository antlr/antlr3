package ANTLR::Runtime::CharStreamState;

use Moose;

# Index into the char stream of next lookahead char
has 'p' => (
    is  => 'rw',
    isa => 'Int',
    default => 0,
);

# What line number is the scanner at before processing buffer[p]?
has 'line' => (
    is  => 'rw',
    isa => 'Int',
    default => 0,
);

# What char position 0..n-1 in line is scanner before processing buffer[p]?
has 'char_position_in_line' => (
    is  => 'rw',
    isa => 'Int',
    default => 0,
);

no Moose;
__PACKAGE__->meta->make_immutable();
1;
