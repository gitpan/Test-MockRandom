package Test::MockRandom;
use strict;
use warnings;
use vars qw ($VERSION);
$VERSION = "0.92";

# Required modules
use Carp;

# Exporter
use Exporter;
use vars qw(@EXPORT @ISA);
@EXPORT = qw( srand rand oneish export_rand_to );
@ISA = qw( Exporter );

#--------------------------------------------------------------------------#
# main pod documentation #####
#--------------------------------------------------------------------------#

=head1 NAME

Test::MockRandom -  Replaces random number generation with non-random number
generation

=head1 SYNOPSIS

  # functional
  use Test::MockRandom;
  srand(0.5);
  if ( rand() == 0.5 ) { print "good guess!" };
  
  # object-oriented
  use Test::MockRandom ();
  my $nrng = Test::MockRandom->new(0.42);
  $nrng->rand(); # returns 0.42
  
  # override rand in another package
  use Test::MockRandom 'Some::Other::Package';
  use Some::Other::Package; # contains sub foo { return rand }
  srand(0.13);
  Some::Other::Package::foo; # returns 0.13
  
  # using a seed list and "oneish"
  srand(0.23, 0.34, oneish() );
  rand(); # returns 0.23
  rand(); # returns 0.34
  rand(); # returns a number just barely less than one
  rand(); # returns 0, as the seed array is empty
  
=head1 DESCRIPTION

This perhaps ridiculous-seeming module was created to test routines that
manipulate random numbers by providing a known output from C<rand>.  Given a
list of seeds with C<srand>, it will return each in turn.  After seeded random
numbers are exhausted, it will always return 0.  Seed numbers must be of a form
that meets the expected output from C<rand> as called with no arguments -- i.e.
they must be between 0 (inclusive) and 1 (exclusive).  In order to facilitate
generating and testing a nearly-one number, this module exports the function
C<oneish>, which returns a number just fractionally less than one.  

Depending on how this module is called with C<use>, it will export C<rand>
either to the current package or to another specified package (e.g. a class
being tested) or even globally.  This module also includes the function
C<export_rand_to> which can be used to explictly override rand in another
package after C<use> has been called.  See L</USAGE> for details.

Alternatively, this module can be used to generate objects, with each object
maintaining its own distinct seed array.

=head1 USAGE

=head2 Overriding C<rand> in the current package

To override C<rand> in the current package, simply C<use> the module
as normal. 

 use Test::MockRandom;

This imports C<rand> and C<srand> into the current namespace, masking any such
calls from reaching the built-in functions.  It also imports C<oneish>, and
C<export_rand_to>.

=head2 Overriding C<rand> in a different package with C<use>

There are two ways to override C<rand> in different package.  The simplest is
to provide the name(s) of the package to be overridden in the C<use> statement.
This will export C<rand> to the listed packages and will export C<srand>,
C<oneish>, and C<export_rand_to> to the current package.  You must C<use>
Test::MockRandom before you C<use> the target package.  This is a typical case
for testing a module that uses random numbers:

 use Test::More;
 use Test::MockRandom qw( Some::Package );
 BEGIN { use_ok( Some::Package ) }
 
 srand(0.5)
 # assume sub foo { return rand } in Some::Package
 Some::Package::foo() # returns 0.5

If you wish to export C<rand> to both another package and the current package,
simply include the current package in the list provided to C<use>.  All of the
following idioms work.

 use Test::MockRandom qw( main Some::Package );
 use Test::MockRandom __PACKAGE__, 'Some::Package';

 # The following doesn't interpolate __PACKAGE__ as above, but 
 # Test::MockRandom will still DWIM and handle it correctly

 use Test::MockRandom qw( __PACKAGE__ Some::Package );
 
=head2 Overriding C<rand> in a different package explicitly with
C<export_rand_to>

In order to override the built-in C<rand> in another package, 
Test::MockRandom must export its own C<rand> function B<before> the 
target package is compiled.  The simple approach (described above) of
providing the target package in the C<use Test::MockRandom> statement
accomplishes this because C<use> is equivalent to a C<require> and C<import>
within a C<BEGIN> block.  To explicitly override C<rand> in another
package, you can also call C<export_rand_to>, but it must be enclosed in
a C<BEGIN> block of its own:

 use Test::MockRandom;
 BEGIN { Test::MockRandom::export_rand_to( 'AnotherPackage' ); }
 use AnotherPackage;
 
This C<BEGIN> block must not include a C<use> statement for the package to be
overridden, or perl will compile the package to be overridden before the
C<export_rand_to> function has a chance to execute and override the system
C<rand>.  This is very important in testing.  The C<export_rand_to> call must
be in a separate C<BEGIN> block from a C<use_ok> test, which should be enclosed
in a C<BEGIN> block of its own: 
 
 use Test::MockRandom;
 BEGIN { Test::MockRandom::export_rand_to( 'AnotherPackage' ); }
 BEGIN { use_ok( 'AnotherPackage' ); }

Given these cautions, it's probably best to use the simple approach with
C<use>, which does the right thing in most circumstances.

=head2 Overriding C<rand> globally

This is just like overriding C<rand> in a package, except that you
override it in C<CORE::GLOBAL>. 

 use Test::MockRandom 'CORE::GLOBAL';
 
 # or

 BEGIN { Test::MockRandom::export_rand_to('CORE::GLOBAL') }

You can always access the real built-in C<rand> by calling it explicitly as
C<CORE::rand>.

=head2 Overriding C<rand> in a package that also contains a C<rand> function

This is tricky as the order in which the symbol table is manipulated will lead
to very different results.  This can be done safely (maybe) if the module uses
the same rand syntax/prototype as the system call.  In this case, you will need
to do an explicit override (as above) but do it B<after> importing the package.
I.e.:

 use Test::MockRandom;
 use SomeRandPackage;
 BEGIN { Test::MockRandom::export_rand_to('SomeRandPackage');

The first line is mostly to get the right exporting of auxilliary function to
the current package.  The second line will define a C<sub rand> in 
C<SomeRandPackage>, overriding the results of the first line.  The third
line then re-overrides the C<rand>.  You may see warnings about C<rand> 
being redefined.

Depending on how your C<rand> is written and used, there is a good likelihood
that this isn't going to do what you're expecting, no matter what.  If your
package that defines C<rand> relies upon the system C<CORE::GLOBAL::rand>, then
you may be best off overriding that instead.

=head1 FUNCTIONS

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
    if (ref ($_[0]) eq __PACKAGE__) { # we're a MockRandom object
        $mult = $_[1];
        $val = shift @{$_[0]} || 0;
    } else {
        # we might be called as a method of some other class
        # so we need to ignore that and get the right multiplier
        $mult = $_[ ref($_[0]) ? 1 : 0];
        $val =  shift @data || 0;
    }
    # default to 1 for undef, 0, or strings
    eval { use warnings FATAL => 'all'; $mult += 0; die unless $mult; };
    $mult = 1 if $@;    
    return $val * $mult;
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

#--------------------------------------------------------------------------#
# export_rand_to()
#--------------------------------------------------------------------------#

=head2 C<export_rand_to>

 export_rand_to( 'Some::Other::Package' );

This function exports C<rand> into another package 
namespace.  This is useful in testing object which call C<rand>.  E.g.,

 package Some::Class;
 sub foo { print rand(); }

 package main;
 use Test::MockRandom;
 export_rand_to( 'Some::Class' );
 srand(0.5);
 Some::Class::foo();   # prints "0.5"
 
Note that this uses the Test::MockRandom package globals, not class objects.
So a call to C<srand> in the main package still affects the results of C<rand>
called in C<Some::Class>.

The effect of this function is highly dependent on when it is called in the 
compile cycle.  See L</USAGE> for important details and warnings.

=cut

sub export_rand_to {
    my $target = $_[ ref($_[0]) ? 1 : 0 ]
        or croak("export_rand_to requires a package name");
    {
        no strict 'refs';
        *{"${target}::rand"} = \&Test::MockRandom::rand;
    }
    return;
}

#--------------------------------------------------------------------------#
# import()
#--------------------------------------------------------------------------#

sub import {
    my $class = shift;
    
    # if no arguments
    unless (@_) {
        for (@EXPORT) {
            $class->export_to_level(1, undef, $_);
        }
        return;
    }

    # otherwise, export rand to the specified package and
    # the other functions to the caller
    for ( @_ ) {
        /^__PACKAGE__$/ and do { export_rand_to(caller(0))};
        export_rand_to($_);
    }
    $class->export_to_level(1, undef, $_) 
        for ( qw( srand oneish export_rand_to ) );
	
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
