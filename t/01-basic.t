#!/usr/bin/perl
use strict;
use warnings;
use blib;  

# Test::MockRandom  

use Test::More tests =>  46 ;
use Test::Exception;

BEGIN { use_ok( 'Test::MockRandom' ); }

#--------------------------------------------------------------------------#
# Test non-object functionality
#--------------------------------------------------------------------------#

can_ok ('Test::MockRandom', 'srand', 'rand', 'oneish');

is (oneish(), (2**32 - 1)/(2**32), 'is oneish nearly one');
is (rand(), 0, 'is uninitialized call to rand() equal to zero');

dies_ok { srand(1) } 'does srand die if argument is equal to one';
dies_ok { srand(1.1) } 'does srand die if argument is greater than one';
dies_ok { srand(-0.1) } 'does srand die if argument is less than zero';
lives_ok { srand(0) } 'does srand(0) live';
lives_ok { srand(oneish) } 'does srand(oneish) live';

srand();
is (rand(), 0, 'testing srand() gives rand() == 0');

srand(oneish);
is (rand(), oneish, 'testing srand(oneish) gives rand == oneish');

srand(.5);
is (rand(), .5, 'testing srand(.5) gives rand == .5');

srand(0);
is (rand(), 0, 'testing srand(0) gives rand == 0');

srand(oneish,.3, .2, .1);
ok ( 1, 'setting srand(oneish,.3, .2, .1)' );
is (rand(), oneish, 'testing rand == oneish');
is (rand(), .3, 'testing rand == .3');
is (rand(), .2, 'testing rand == .2');
is (rand(), .1, 'testing rand == .1');
is (rand(), 0, 'testing rand == 0 (nothing left in srand array');

#--------------------------------------------------------------------------#
# Test object oriented functionality
#--------------------------------------------------------------------------#

#Test::MockRandom::srand(0);
my $obj = Test::MockRandom->new ();
isa_ok ($obj, 'Test::MockRandom');

is ($obj->rand(), 0, 'is uninitialized call to $obj->rand() equal to zero');

dies_ok { Test::MockRandom->new(1) } 'does Test::MockRandom->new die if argument is equal to one';
dies_ok { Test::MockRandom->new(1.1) } 'does Test::MockRandom->new die if argument is greater than one';
dies_ok { Test::MockRandom->new(-0.1) } 'does Test::MockRandom->new die if argument is less than zero';
lives_ok { Test::MockRandom->new(0) } 'does Test::MockRandom->new(0) live';
lives_ok { Test::MockRandom->new(oneish) } 'does Test::MockRandom->new(oneish) live';

dies_ok { $obj->srand(1) } 'does $obj->srand die if argument is equal to one';
dies_ok { $obj->srand(1.1) } 'does $obj->srand die if argument is greater than one';
dies_ok { $obj->srand(-0.1) } 'does $obj->srand die if argument is less than zero';
lives_ok { $obj->srand(0) } 'does $obj->srand(0) live';
lives_ok { $obj->srand(oneish) } 'does $obj->srand(oneish) live';

$obj->srand();
is ($obj->rand(), 0, 'testing $obj->srand() gives $obj->rand() == 0');

$obj->srand(oneish);
is ($obj->rand(), oneish, 'testing $obj->srand(oneish) gives $obj->rand == oneish');

$obj->srand(.5);
is ($obj->rand(), .5, 'testing $obj->srand(.5) gives $obj->rand == .5');

$obj->srand(0);
is ($obj->rand(), 0, 'testing $obj->srand(0) gives $obj->rand == 0');

$obj->srand(oneish,.3, .2, .1);
ok ( 1, 'setting $obj->srand(oneish,.3, .2, .1)' );
is ($obj->rand(), oneish, 'testing $obj->rand == oneish');
is ($obj->rand(), .3, 'testing $obj->rand == .3');
is ($obj->rand(), .2, 'testing $obj->rand == .2');
is ($obj->rand(), .1, 'testing $obj->rand == .1');
is ($obj->rand(), 0, 'testing $obj->rand == 0 (nothing left in $obj->srand array');

#--------------------------------------------------------------------------#
# Test rand(N) functionality
#--------------------------------------------------------------------------#

srand( 0.5, 0.25, .1, 0.6 );
ok( 1, 'setting srand( 0.5, 0.25 )' );
is (rand(2), 1, 'testing rand(2) == 1');
is (rand(0), 0.25, 'testing rand(0) == 0.25');
is (rand(-1), -0.1, 'testing rand(-1) == -0.1');
is (rand('a'), 0.6, 'testing rand("a") == 0.6');

