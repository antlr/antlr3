package ANTLR::Runtime::BitSet;

use Carp;
use Readonly;
use List::Util qw( max );

use Moose;
use Moose::Util::TypeConstraints;

use overload
    '|=' => \&or_in_place,
    '""' => \&str;

# number of bits / long
Readonly my $BITS => 64;
sub BITS { return $BITS }

# 2^6 == 64
Readonly my $LOG_BITS => 6;
sub LOG_BITS { return $LOG_BITS }

# We will often need to do a mod operator (i mod nbits).  Its
# turns out that, for powers of two, this mod operation is
# same as (i & (nbits-1)).  Since mod is slow, we use a
# precomputed mod mask to do the mod instead.
Readonly my $MOD_MASK => BITS - 1;
sub MOD_MASK { return $MOD_MASK }

# The actual data bit
has 'bits' => (
    is  => 'rw',
    isa => subtype 'Str' => where { /^(?:0|1)*$/xms },
);

sub trim_hex {
    my ($number) = @_;

    $number =~ s/^0x//xms;

    return $number;
}

sub BUILD {
    my ($self, $args) = @_;

    my $bits;
    if (!%$args) {  ## no critic (ControlStructures::ProhibitCascadingIfElse)
        # Construct a bitset of size one word (64 bits)
        $bits = '0' x BITS;
    }
    elsif (exists $args->{bits}) {
        $bits = $args->{bits};
    }
    elsif (exists $args->{number}) {
        $bits = reverse unpack('B*', pack('N', $args->{number}));
    }
    elsif (exists $args->{words64}) {
        # Construction from a static array of longs
        my $words64 = $args->{words64};

        # $number is in hex format
        my $number = join '',
            map { trim_hex($_) }
            reverse @$words64;

        $bits = '';
        foreach my $h (split //xms, reverse $number) {
            $bits .= reverse substr(unpack('B*', pack('h', hex $h)), 4);
        }
    }
    elsif (exists $args->{''}) {
       # Construction from a list of integers
    }
    elsif (exists $args->{size}) {
        # Construct a bitset given the size
        $bits = '0' x $args->{size};
    }
    else {
        croak 'Invalid argument';
    }

    $self->bits($bits);
    return;
}

sub of {
    my ($class, $el) = @_;

    my $bs = ANTLR::Runtime::BitSet->new({ size => $el + 1 });
    $bs->add($el);

    return $bs;
}

sub or : method {  ## no critic (Subroutines::ProhibitBuiltinHomonyms)
    my ($self, $a) = @_;

    if (!defined $a) {
        return $self;
    }

    my $s = $self->clone();
    $s->or_in_place($a);
    return $s;
}

sub add : method {
    my ($self, $el) = @_;

    $self->grow_to_include($el);
    my $bits = $self->bits;
    substr($bits, $el, 1, '1');
    $self->bits($bits);

    return;
}

sub grow_to_include : method {
    my ($self, $bit) = @_;

    if ($bit > length $self->bits) {
        $self->bits .= '0' x ($bit - (length $self->bits) + 1);
    }

    return;
}

sub or_in_place : method {
    my ($self, $a) = @_;

    my $i = 0;
    foreach my $b (split //xms, $a->bits) {
        if ($b) {
            $self->add($i);
        }
    } continue {
        ++$i;
    }

    return $self;
}

sub clone : method {
    my ($self) = @_;

    return ANTLR::Runtime::BitSet->new(bits => $self->bits);
}

sub size : method {
    my ($self) = @_;

    return scalar $self->bits =~ /1/xms;
}

sub equals : method {
    my ($self, $other) = @_;

    return $self->bits eq $other->bits;
}

sub member : method {
    my ($self, $el) = @_;

    return (substr $self->bits, $el, 1) eq '1';
}

sub remove : method {
    my ($self, $el) = @_;

    my $bits = $self->bits;
    substr($bits, $el, 1, '0');
    $self->bits($bits);

    return;
}

sub is_nil : method {
    my ($self) = @_;

    return $self->bits =~ /1/xms ? 1 : 0;
}

sub num_bits : method {
    my ($self) = @_;
    return length $self->bits;
}

sub length_in_long_words : method {
    my ($self) = @_;
    return $self->num_bits() / $self->BITS;
}

sub to_array : method {
    my ($self) = @_;

    my $elems = [];

    while ($self->bits =~ /1/gxms) {
        push @$elems, $-[0];
    }

    return $elems;
}

sub to_packed_array : method {
    my ($self) = @_;

    return [
        $self->bits =~ /.{BITS}/gxms
    ];
}

sub str : method {
    my ($self) = @_;

    return $self->to_string();
}

sub to_string : method {
    my ($self, $args) = @_;

    my $token_names;
    if (defined $args && exists $args->{token_names}) {
        $token_names = $args->{token_names};
    }

    my @str;
    my $i = 0;
    foreach my $b (split //xms, $self->bits) {
        if ($b) {
            if (defined $token_names) {
                push @str, $token_names->[$i];
            } else {
                push @str, $i;
            }
        }
    } continue {
        ++$i;
    }

    return '{' . (join ',', @str) . '}';
}

no Moose;
__PACKAGE__->meta->make_immutable();
1;
__END__


=head1 NAME

ANTLR::Runtime::BitSet - A bit set


=head1 SYNOPSIS

    use <Module::Name>;
    # Brief but working code example(s) here showing the most common usage(s)

    # This section will be as far as many users bother reading
    # so make it as educational and exemplary as possible.


=head1 DESCRIPTION

A stripped-down version of org.antlr.misc.BitSet that is just good enough to
handle runtime requirements such as FOLLOW sets for automatic error recovery.


=head1 SUBROUTINES/METHODS

=over

=item C<of>

...

=item C<or>

Return this | a in a new set.

=item C<add>

Or this element into this set (grow as necessary to accommodate).

=item C<grow_to_include>

Grows the set to a larger number of bits.

=item C<set_size>

Sets the size of a set.

=item C<remove>

Remove this element from this set.

=item C<length_in_long_words>

Return how much space is being used by the bits array not how many actually
have member bits on.

=back

A separate section listing the public components of the module's interface.
These normally consist of either subroutines that may be exported, or methods
that may be called on objects belonging to the classes that the module provides.
Name the section accordingly.

In an object-oriented module, this section should begin with a sentence of the
form "An object of this class represents...", to give the reader a high-level
context to help them understand the methods that are subsequently described.


=head1 DIAGNOSTICS

A list of every error and warning message that the module can generate
(even the ones that will "never happen"), with a full explanation of each
problem, one or more likely causes, and any suggested remedies.
(See also "Documenting Errors" in Chapter 13.)


=head1 CONFIGURATION AND ENVIRONMENT

A full explanation of any configuration system(s) used by the module,
including the names and locations of any configuration files, and the
meaning of any environment variables or properties that can be set. These
descriptions must also include details of any configuration language used.
(See also "Configuration Files" in Chapter 19.)


=head1 DEPENDENCIES

A list of all the other modules that this module relies upon, including any
restrictions on versions, and an indication whether these required modules are
part of the standard Perl distribution, part of the module's distribution,
or must be installed separately.


=head1 INCOMPATIBILITIES

A list of any modules that this module cannot be used in conjunction with.
This may be due to name conflicts in the interface, or competition for
system or program resources, or due to internal limitations of Perl
(for example, many modules that use source code filters are mutually
incompatible).
