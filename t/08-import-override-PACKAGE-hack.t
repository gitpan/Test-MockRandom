#!/usr/bin/perl
use strict;
use warnings;
use blib;  

# Test::MockRandom  

use Test::More tests => 8;
use Test::Exception;

#--------------------------------------------------------------------------#
# Test package overriding via import
#--------------------------------------------------------------------------#

use Test::MockRandom qw( __PACKAGE__ SomePackage );
use lib qw( . ./t );
use SomePackage; 

for (qw ( rand srand oneish export_rand_to )) {
    can_ok( __PACKAGE__, $_ );
}

my $obj = SomePackage->new;
isa_ok ( $obj, 'SomePackage');
can_ok ( $obj, qw ( rand ));
srand(.5,.6);
is ($obj->next_random(), .5, 'testing $obj->next_random == .5');
is (rand, .6, 'testing rand == .6 in current package');



