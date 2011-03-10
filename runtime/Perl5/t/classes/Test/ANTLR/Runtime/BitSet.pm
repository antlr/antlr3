package Test::ANTLR::Runtime::BitSet;

use Test::More;

use Moose;

BEGIN { extends 'My::Test::Class' }

sub constructor : Tests(3) {
    my ($self) = @_;
    my $class = $self->class;

    can_ok $class, 'new';
    ok my $bs = $class->new();
    isa_ok $bs, $class;
}

sub constructor_bits : Tests(5) {
    my ($self) = @_;
    my $bs = $self->class->new({ bits => '001' });
    ok !$bs->member(0);
    ok !$bs->member(1);
    ok $bs->member(2);
    ok !$bs->member(3);
    is "$bs", '{2}';
}

sub constructor_number : Tests(2) {
    my ($self) = @_;
    my $bs = $self->class->new({ number => 0x10 });
    ok $bs->member(4);
    is "$bs", '{4}';
}

sub constructor_words64 : Tests(2) {
    my ($self) = @_;
    my $bs = $self->class->new(
        { words64 => [ '0x0000004000000001', '0x1000000000800000' ] });
    is "$bs", '{0,38,87,124}';
}

sub of : Tests(2) {
    my ($self) = @_;
    my $bs = $self->class->of(0x10);
    ok $bs->member(16) ;
    is "$bs", '{16}' ;
}

sub operator_to_string : Tests(1) {
    my ($self) = @_;
    my $bs = $self->class->new();
    is "$bs", '{}';
}

sub add : Tests(1) {
    my ($self) = @_;
    my $bs = $self->class->new();
    $bs->add(2);
    $bs->add(7);
    is "$bs", '{2,7}';
}

sub remove : Tests(2) {
    my ($self) = @_;
    my $bs = $self->class->new();
    $bs->add(3);
    $bs->add(12);
    is "$bs", '{3,12}';
    $bs->remove(3);
    is "$bs", '{12}';
}

sub operator_or : Tests(1) {
    my ($self) = @_;
    my $bs = $self->class->of(4);
    $bs |= $self->class->of(5);
    is "$bs", '{4,5}';
}

no Moose;
__PACKAGE__->meta->make_immutable(inline_constructor => 0);
1;
