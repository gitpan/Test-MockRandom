package Test::MockRandom;
use strict;
use warnings;
use vars qw ($VERSION);
$VERSION = "0.91";

# Required modules
use Carp;

# ISA
use base qw( Exporter );

use vars qw(@EXPORT);
@EXPORT = qw( srand rand oneish export_rand_to );

#--------------------------------------------------------------------------#
# main pod documentation #####
#--------------------------------------------------------------------------#

=head1 NAME

Test::MockRandom -  Replaces random number generation with non-random number
generation

=head1 SYNOPSIS

  use Test::MockRandom;
  
  # functional
  srand(0.5);
  if ( rand() == 0.5 ) { print "good guess!" };
  
  # object-oriented
  my $nrng = Test::MockRandom->new(0.42);
  $nrng->rand(); # returns 0.42
  
  # using a seed-array
  $nrng->srand(0.23, 0.34, oneish() );
  $nrng->rand(); # returns 0.23
  $nrng->rand(); # returns 0.34
  $nrng->rand(); # returns a number just barely less than one
  $nrng->rand(); # returns 0, as the seed array is empty
  
  # mask rand in another package
  export_rand_to( 'Some::Other::Package' );
  
=head1 DESCRIPTION

This perhaps ridiculous-seeming module was created to test routines that
manipulate random numbers by providing a known output from C<rand>.  It exports
C<srand> and C<rand>, hijacking the system function calls.   Given an array of
seeds, it will return each in turn.  After seeded random numbers are exhausted,
it will always return 0.  It can also be used to generate objects, with each
object maintaining its own distinct seed array.

Seed numbers must follow the expected output from C<rand> with no arguments --
they must be between 0 (inclusive) and 1 (exclusive).  In order to facilitate
generating a nearly-one number, this module exports the function C<oneish>,
which returns a number just fractionally less than one.  This module also
exports the function C<export_rand_to> which can be used to hijack rand in
another namespace (e.g., a class being tested).

If for some reason you want to use this module without hijacking the built-in
functions (i.e. objects only), you can use the module without any imported
functions with C<use Test::MockRandom qw();>.

=head1 USAGE

=cut

#--------------------------------------------------------------------------#
# Class data
#--------------------------------------------------------------------------#

my @data = (0);

#--------------------------------------------------------------------------#
# new()
#--------------------------------------------------------------------------#

=head2 C<new>

 $obj = new( LIST OF SEEDS );

Returns a new Test::MockRandom object with the specified list of seeds.

=cut

sub new {
    my ($class, @data) = @_;
    my $self = bless ([], ref ($class) || $class);
    $self->srand(@data);
    return $self;
}


#--------------------------------------------------------------------------#
# srand()
#--------------------------------------------------------------------------#

=head2 C<srand>

 srand( LIST OF SEEDS );
 $obj->srand( LIST OF SEEDS);

If called as a bare function call or package method, sets the seed list
for bare/package calls to C<rand>.  If called as an object method,
sets the seed list for that object.

=cut

sub srand {
    if (ref ($_[0]) eq __PACKAGE__) {
        my $self = shift;
        @$self = $self->_test_srand(@_);
        return;
    } else {
        @data = Test::MockRandom->_test_srand(@_);
        return;
    }
}

sub _test_srand {
    my ($self, @data) = @_;
    my $error = "Seeds for " . __PACKAGE__ . 
                " must be between 0 (inclusive) and 1 (exclusive)";
    croak $error if grep { $_ < 0 or $_ >= 1 } @data;    
    return @data ? @data : ( 0 );
}

#--------------------------------------------------------------------------#
# rand()
#--------------------------------------------------------------------------#

=head2 C<rand>

 $rv = rand();
 $rv = $obj->rand();
 $rv = rand(3);

If called as a bare or package function, returns the next value from the
package seed list.  If called as an object method, returns the next value from
the object seed list. 

If C<rand> is called with a numeric argument, it follows the same behavior as
the built-in function -- it multiplies the argument with the next value from
the seed array (resulting in a random fractional value between 0 and the
argument, just like the built-in).  If the argument is 0, undef, or
non-numeric, it is treated as if the argument is 1.

Using this with an argument in testing may be complicated, as limits in
floating point precision mean that direct numeric comparisons are not reliable.
E.g.

 srand(1/3);
 rand(3);       # does this return 1.0 or .999999999 etc.

=cut

sub rand {
    my ($mult,$val);
    if (ref ($_[0]) eq __PACKAGE__) {
        $mult = $_[1];
        $val = shift @{$_[0]} || 0;
    } else {
        $mult = $_[0];
        $val =  shift @data || 0;
    }
    # default to 1 for undef, 0, or strings
    $mult = 1 unless eval { no warnings; $mult * 1 };
    return $val * $mult;
}

=cut


#--------------------------------------------------------------------------#
# export_rand_to()
#--------------------------------------------------------------------------#

=head2 C<export_rand_to>

 export_rand_to( 'Some::Other::Package' );

As the name implies, this function exports C<rand> into another package 
namespace.  This is useful in testing object which call C<rand>.  E.g.,

 package Some::Class;
 sub foo { print rand(); }

 package main;
 use Test::MockRandom;
 export_rand_to( 'Some::Class' );
 srand(0.5);
 Some::Class::foo();   # prints "0.5"
 
Note that this uses the Test::MockRandom package globals, not class objects.
So a call to C<srand> in this package still affects the results of C<rand>
called in C<Some::Class>.

Using this on an object oriented package that also defines a C<rand> method
will likely cause major errors.

=cut

sub export_rand_to {
    my $self;
    if (ref ($_[0]) eq __PACKAGE__) {
        $self = shift;
    } 
    my $target = shift or croak("export_rand_to requires a package name");
    {
        no strict 'refs';
        *{$target."::rand"} = *{__PACKAGE__."::rand"};
    }
    return;
}

#--------------------------------------------------------------------------#
# oneish()
#--------------------------------------------------------------------------#

=head2 C<oneish>

 srand( oneish() );
 if ( rand() == oneish() ) { print "It's almost one." };

A utility function to return a nearly-one value.  Equal to ( 2^32 - 1 ) / 2^32.
Useful in C<srand> and test functions.

=cut

sub oneish {
    return (2**32-1)/(2**32);	
}

1; #this line is important and will help the module return a true value
__END__

=head1 BUGS

Please report bugs using the CPAN Request Tracker at 
http://rt.cpan.org/NoAuth/Bugs.html?Dist=Test-MockRandom

=head1 AUTHOR

 David A. Golden (DAGOLDEN)
 dagolden@dagolden.com
 http://dagolden.com/

=head1 COPYRIGHT

Copyright (c) 2004 by David A. Golden

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.


=head1 SEE ALSO

=over

=item L<Test::MockObject>

=item L<Test::MockModule>

=back

=cut
