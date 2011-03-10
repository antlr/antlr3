package ANTLR::Runtime::MismatchedSetException;

use Moose;

extends 'ANTLR::Runtime::Exception';

no Moose;
__PACKAGE__->meta->make_immutable();
1;
