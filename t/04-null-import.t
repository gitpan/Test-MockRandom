#!/usr/bin/perl
use strict;
use warnings;
use blib;  

# Test::MockRandom  

use Test::More tests => 4 ;
use Test::Exception;

#--------------------------------------------------------------------------#
# Test package import -- empty string
#--------------------------------------------------------------------------#

use Test::MockRandom qw();

for (qw( rand srand oneish export_rand_to )) {
    is ( UNIVERSAL::can( __PACKAGE__, $_), undef, "$_ should not have been imported" );
}

