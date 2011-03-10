package My::Test::Class;

use Test::More;

use Moose;

BEGIN { extends 'Test::Class' }

has 'class' => (
    is  => 'rw',
    isa => 'Str',
);

sub new {
    my ($class, @args) = @_;
    my $self = $class->SUPER::new(@args);
    return $class->meta->new_object(
        __INSTANCE__ => $self, @args
    );
}

sub startup : Tests(startup => 1) {
    my ($test) = @_;
    (my $class = ref $test) =~ s/^Test:://xms;
    use_ok $class or die;
    $test->class($class);
    return;
}

no Moose;
__PACKAGE__->meta->make_immutable(inline_constructor => 0);
1;
