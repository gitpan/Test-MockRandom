#!/usr/bin/perl
use strict;
use warnings;
use blib;  

# Test::MockRandom  

use Test::More tests =>  4 ;
use Test::Exception;

BEGIN { use_ok( 'Test::MockRandom'); }

#--------------------------------------------------------------------------#
# Test package overriding
#--------------------------------------------------------------------------#


can_ok ('Test::MockRandom', 'export_srand_to');

Test::MockRandom::export_rand_to( 'OverrideTest' );
Test::MockRandom::export_srand_to( 'OverrideTest' );
can_ok ('OverrideTest', qw ( srand ));
OverrideTest::srand(.5);
is (OverrideTest::rand(), .5, 
        'testing OverrideTest::srand(.5) gives OverrideTest::rand == .5');


