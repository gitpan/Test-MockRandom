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

use Test::MockRandom qw( SomePackage );
use lib qw( . ./t );
use SomePackage; 

is( UNIVERSAL::can( __PACKAGE__, 'rand'), undef,
        "rand should not have been imported into " . __PACKAGE__ );

for (qw ( srand oneish export_rand_to )) {
    can_ok( __PACKAGE__, $_ );
}

my $obj = SomePackage->new;
isa_ok ( $obj, 'SomePackage');
can_ok ( $obj, qw ( rand ));
srand(.5);
is ($obj->next_random(), .5, 'testing $obj->next_random == .5');



