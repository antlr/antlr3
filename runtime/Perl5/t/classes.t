#!/usr/bin/perl

use strict;
use warnings;

use lib 't/lib';
use My::Test::Class::Load 't/classes';

Test::Class->runtests();
