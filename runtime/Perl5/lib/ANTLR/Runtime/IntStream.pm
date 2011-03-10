package ANTLR::Runtime::IntStream;

use Moose::Role;

requires 'consume';

requires 'LA';

requires 'mark';

requires 'index';

requires 'rewind';

requires 'release';

requires 'seek';

requires 'size';

requires 'get_source_name';

no Moose::Role;
1;
__END__
