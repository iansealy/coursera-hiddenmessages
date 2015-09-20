#!/usr/bin/env perl

# PODNAME: approximate-pattern-count.pl
# ABSTRACT: Approximate Pattern Count

## Author     : Ian Sealy
## Maintainer : Ian Sealy
## Created    : 2015-09-20

use warnings;
use strict;
use autodie;
use Getopt::Long;
use Pod::Usage;
use Carp;
use Path::Tiny;
use version; our $VERSION = qv('v0.1.0');

# Default options
my $input_file = 'approximate-pattern-count-sample-input.txt';
my ( $debug, $help, $man );

# Get and check command line options
get_and_check_options();

my ( $pattern, $text, $d ) = path($input_file)->lines( { chomp => 1 } );

printf "%d\n", approximate_pattern_count( $text, $pattern, $d );

sub approximate_pattern_count {
    my ( $text, $pattern, $d ) = @_;    ## no critic (ProhibitReusedNames)

    my $count = 0;

    foreach my $i ( 0 .. ( ( length $text ) - length $pattern ) ) {
        if ( hamming_distance( $pattern, substr $text, $i, length $pattern ) <=
            $d )
        {
            $count++;
        }
    }

    return $count;
}

sub hamming_distance {
    my ( $str1, $str2 ) = @_;

    my $diff = $str1 ^ $str2;
    my $num_mismatches = $diff =~ tr/\0//c;

    return $num_mismatches;
}

# Get and check command line options
sub get_and_check_options {

    # Get options
    GetOptions(
        'input_file=s' => \$input_file,
        'debug'        => \$debug,
        'help'         => \$help,
        'man'          => \$man,
    ) or pod2usage(2);

    # Documentation
    if ($help) {
        pod2usage(1);
    }
    elsif ($man) {
        pod2usage( -verbose => 2 );
    }

    return;
}

__END__
=pod

=encoding UTF-8

=head1 NAME

approximate-pattern-count.pl

Approximate Pattern Count

=head1 VERSION

version 0.1.0

=head1 DESCRIPTION

This script implements Approximate Pattern Count.

Input: Strings I<Pattern> and I<Text> as well as an integer I<d>.

Output: I<Countd>(I<Text>, I<Pattern>).

=head1 EXAMPLES

    perl approximate-pattern-count.pl

    perl approximate-pattern-count.pl \
        --input_file approximate-pattern-count-extra-input.txt

    diff <(perl approximate-pattern-count.pl) \
        approximate-pattern-count-sample-output.txt

    diff \
        <(perl approximate-pattern-count.pl \
            --input_file approximate-pattern-count-extra-input.txt) \
        approximate-pattern-count-extra-output.txt

    perl approximate-pattern-count.pl --input_file dataset_9_6.txt \
        > dataset_9_6_output.txt

=head1 USAGE

    approximate-pattern-count.pl
        [--input_file FILE]
        [--debug]
        [--help]
        [--man]

=head1 OPTIONS

=over 8

=item B<--input_file FILE>

The input file containing "Strings I<Pattern> and I<Text> as well as an integer
I<d>".

=item B<--debug>

Print debugging information.

=item B<--help>

Print a brief help message and exit.

=item B<--man>

Print this script's manual page and exit.

=back

=head1 DEPENDENCIES

None

=head1 AUTHOR

=over 4

=item *

Ian Sealy

=back

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2015 by Ian Sealy.

This is free software, licensed under:

  The GNU General Public License, Version 3, June 2007

=cut
