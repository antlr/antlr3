package ANTLR::Runtime::Stream;

use Moose::Role;

requires 'consume';

requires 'LA';

requires 'mark';

requires 'index';

requires 'rewind';

requires 'release';

requires 'seek';

requires 'size';

no Moose::Role;
1;
__END__
