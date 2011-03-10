package My::Test::Class::Load;

use strict;
use warnings;

use base 'Test::Class::Load';

sub is_test_class {
    my ($class, $file, $dir) = @_;

    return if !$class->SUPER::is_test_class($file, $dir);

    if (exists $ENV{TEST_CLASS}) {
        my $pattern = $ENV{TEST_CLASS};

        (my $class = $file) =~ s!^\Q$dir\E/!!xms;
        $class =~ s/\.pm$//xms;
        $class =~ s!/!::!gxms;

        return if $class !~ /$pattern/xms;
    }

    return 1;
}

1;
__END__
