package ANTLR::Runtime::CommonTokenStream;

use Carp;
use Readonly;
use UNIVERSAL qw( isa );

use ANTLR::Runtime::CharStream;
use ANTLR::Runtime::Token;
use ANTLR::Runtime::TokenSource;

use Moose;

use overload
    '""' => \&str
    ;

with 'ANTLR::Runtime::IntStream',
     'ANTLR::Runtime::TokenStream';

has 'token_source' => (
    is  => 'rw',
    does => 'ANTLR::Runtime::TokenSource',
);

has 'tokens' => (
    is  => 'rw',
    isa => 'ArrayRef[ANTLR::Runtime::Token]',
    default => sub { [] },
);

has 'channel_override_map' => (
    is  => 'rw',
    isa => 'HashRef[Int]',
);

has 'discard_set' => (
    is  => 'rw',
    isa => 'HashRef[Int]',
);

has 'channel' => (
    is  => 'rw',
    isa => 'Int',
    default => ANTLR::Runtime::Token->DEFAULT_CHANNEL,
);

has 'discard_off_channel_tokens' => (
    is  => 'rw',
    isa => 'Bool',
    default => 0,
);

has 'last_marker' => (
    is  => 'rw',
    isa => 'Int',
    default => 0,
);

has 'p' => (
    is  => 'rw',
    isa => 'Int',
    default => -1,
);

sub set_token_source {
    my ($self, $token_source) = @_;

    $self->token_source($token_source);
    $self->tokens([]);
    $self->p(-1);
    $self->channel(ANTLR::Runtime::Token->DEFAULT_CHANNEL);
}

sub fill_buffer {
    my ($self) = @_;

    my $index = 0;
    my $t = $self->token_source->next_token();
    while (defined $t && $t->get_type() != ANTLR::Runtime::CharStream->EOF) {
        my $discard = 0;
	# is there a channel override for token type?
        if (defined $self->channel_override_map) {
            my $channel = $self->channel_override_map->{$t->get_type()};
            if (defined $channel) {
                $t->set_channel($channel);
            }
        }

        if (defined $self->discard_set && $self->discard_set->contains($t->get_type())) {
            $discard = 1;
        } elsif ($self->discard_off_channel_tokens && $t->get_channel() != $self->channel) {
            $discard = 1;
        }

        if (!$discard) {
            $t->set_token_index($index);
            push @{$self->tokens}, $t;
            ++$index;
        }
    } continue {
        $t = $self->token_source->next_token();
    }

    # leave p pointing at first token on channel
    $self->p(0);
    $self->skip_off_token_channels($self->p);
}

sub consume {
    my ($self) = @_;

    if ($self->p < @{$self->tokens}) {
        $self->p($self->p + 1);
        $self->p($self->skip_off_token_channels($self->p));  # leave p on valid token
    }
}

sub skip_off_token_channels {
    my ($self, $i) = @_;

    my $n = @{$self->tokens};
    while ($i < $n && $self->tokens->[$i]->get_channel() != $self->channel) {
        ++$i;
    }

    return $i;
}

sub skip_off_token_channels_reverse {
    my ($self, $i) = @_;

    while ($i >= 0 && $self->tokens->[$i]->get_channel() != $self->channel) {
        --$i;
    }

    return $i;
}

sub set_token_type_channel {
    my ($self, $ttype, $channel) = @_;

    if (!defined $self->channel_override_map) {
        $self->channel_override_map({});
    }

    $self->channel_override_map->{$ttype} = $channel;
}

sub discard_token_type {
    my ($self, $ttype) = @_;

    if (!defined $self->discard_set) {
        $self->discard_set({});
    }

    $self->discard_set->{$ttype} = 1;
}

sub get_tokens {
    my ($self, $args) = @_;

    if ($self->p == -1) {
        $self->fill_buffer();
    }
    if (!defined $args) {
        return $self->tokens;
    }

    my $start = $args->{start};
    my $stop = $args->{stop};

    my $types;
    if (exists $args->{types}) {
        if (ref $args->{types} eq 'ARRAY') {
            $types = ANTLR::Runtime::BitSet->new($args->{types});
        } else {
            $types = $args->{types};
        }
    } else {
        my $ttype = $args->{ttype};
        $types = ANTLR::Runtime::BitSet->of($ttype);
    }


    if ($stop >= @{$self->tokens}) {
        $stop = $#{$self->tokens};
    }
    if ($start < 0) {
        $start = 0;
    }

    if ($start > $stop) {
        return undef;
    }

    my $filtered_tokens = [];
    foreach my $t (@{$self->tokens}[$start..$stop]) {
        if (!defined $types || $types->member($t->get_type())) {
            push @$filtered_tokens, $t;
        }
    }

    if (!@{$filtered_tokens}) {
        $filtered_tokens = undef;
    }

    return $filtered_tokens;
}

sub LT {
    my ($self, $k) = @_;

    if ($self->p == -1) {
        $self->fill_buffer();
    }
    if ($k == 0) {
        return undef;
    }
    if ($k < 0) {
        return $self->LB(-$k);
    }

    if ($self->p + $k - 1 >= @{$self->tokens}) {
        return ANTLR::Runtime::Token->EOF_TOKEN;
    }

    my $i = $self->p;
    my $n = 1;

    while ($n < $k) {
        $i = $self->skip_off_token_channels($i+1);
        ++$n;
    }

    if ($i >= @{$self->tokens}) {
        return ANTLR::Runtime::Token->EOF_TOKEN;
    }

    return $self->tokens->[$i];
}

sub LB {
    my ($self, $k) = @_;

    if ($self->p == -1) {
        $self->fill_buffer();
    }
    if ($k == 0) {
        return undef;
    }
    if ($self->p - $k < 0) {
        return undef;
    }

    my $i = $self->p;
    my $n = 1;
    while ($n <= $k) {
        $k = $self->skip_off_token_channels_reverse($i - 1);
        ++$n;
    }

    if ($i < 0) {
        return undef;
    }

    return $self->tokens->[$i];
}

sub get {
    my ($self, $i) = @_;

    return $self->tokens->[$i];
}

sub LA {
    my ($self, $i) = @_;

    return $self->LT($i)->get_type();
}

sub mark {
    my ($self) = @_;

    if ($self->p == -1) {
        $self->fill_buffer();
    }
    $self->last_marker($self->index());
    return $self->last_marker;
}

sub release {
    my ($self, $marker) = @_;

    # no resources to release
}

sub size {
    my ($self) = @_;

    return scalar @{$self->tokens};
}

sub index {
    my ($self) = @_;

    return $self->p;
}

sub rewind {
    Readonly my $usage => 'void rewind(int marker) | void rewind()';
    croak $usage if @_ != 1 && @_ != 2;

    if (@_ == 1) {
        my ($self) = @_;
        $self->seek($self->last_marker);
    } else {
        my ($self, $marker) = @_;
        $self->seek($marker);
    }
}

sub seek {
    my ($self, $index) = @_;

    $self->p($index);
}

sub get_token_source {
    my ($self) = @_;

    return $self->token_source;
}

sub get_source_name {
    my ($self) = @_;
    return $self->get_token_source()->get_source_name();
}

sub str {
    my ($self) = @_;
    return $self->to_string();
}

sub to_string {
    Readonly my $usage => 'String to_string() | String to_string(int start, int stop | String to_string(Token start, Token stop)';
    croak $usage if @_ != 1 && @_ != 3;

    if (@_ == 1) {
        my ($self) = @_;

        if ($self->p == -1) {
            $self->fill_buffer();
        }
        return $self->to_string(0, $#{$self->tokens});
    } else {
        my ($self, $start, $stop) = @_;

        if (defined $start && defined $stop) {
            if (ref($start) && $start->isa('ANTLR::Runtime::Token')) {
                $start = $start->get_token_index();
            }

            if (ref($start) && $stop->isa('ANTLR::Runtime::Token')) {
                $stop = $stop->get_token_index();
            }

            if ($start < 0 || $stop < 0) {
                return undef;
            }
            if ($self->p == -1) {
                $self->fill_buffer();
            }
            if ($stop >= @{$self->tokens}) {
                $stop = $#{$self->tokens};
            }

            my $buf = '';
            foreach my $t (@{$self->tokens}[$start..$stop]) {
                $buf .= $t->get_text();
            }

            return $buf;
        } else {
            return undef;
        }
    }
}

no Moose;
__PACKAGE__->meta->make_immutable();
1;
__END__
