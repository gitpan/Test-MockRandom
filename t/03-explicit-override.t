#!/usr/bin/perl
use strict;
use warnings;
use blib;  

# Test::MockRandom  

use Test::More 'no_plan' ;
use Test::Exception;

#--------------------------------------------------------------------------#
# Test package overriding
#--------------------------------------------------------------------------#

BEGIN { use_ok('Test::MockRandom') }

BEGIN {
    use lib '.';
    use lib 't';
    Test::MockRandom::export_rand_to( 'SomePackage' );
}
use SomePackage; 

my $obj = SomePackage->new;
isa_ok ( $obj, 'SomePackage');
can_ok ( $obj, qw ( rand ));
srand(.5);
is ($obj->next_random(), .5, 'testing $obj->next_random == .5');



