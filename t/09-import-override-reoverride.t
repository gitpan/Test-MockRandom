#!/usr/bin/perl
use strict;
use warnings;
use blib;  

# Test::MockRandom  

use Test::More tests => 7 ;
use Test::Exception;

#--------------------------------------------------------------------------#
# Test package overriding via import
#--------------------------------------------------------------------------#

use Test::MockRandom;
use lib qw( . ./t );
use SomeRandPackage; 

# SomeRandPackage has its own rand(), so we have to re-override
BEGIN { Test::MockRandom::export_rand_to('SomeRandPackage') }

for (qw ( rand srand oneish export_rand_to )) {
    can_ok( __PACKAGE__, $_ );
}

my $obj = SomeRandPackage->new;
isa_ok ( $obj, 'SomeRandPackage');
can_ok ( $obj, qw ( rand ));
srand(.5);
is ($obj->rand(), .5, 'testing $obj->rand == .5');



