#!/usr/bin/env perl

# PODNAME: approximate-match.pl
# ABSTRACT: Approximate Pattern Matching

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
my $input_file = 'approximate-match-sample-input.txt';
my ( $debug, $help, $man );

# Get and check command line options
get_and_check_options();

my ( $pattern, $text, $d ) = path($input_file)->lines( { chomp => 1 } );

printf "%s\n", join q{ }, approximate_pattern_matching( $pattern, $text, $d );

sub approximate_pattern_matching {
    my ( $pattern, $text, $d ) = @_;    ## no critic (ProhibitReusedNames)

    my @pos;

    my $k = length $pattern;
    foreach my $i ( 0 .. ( length $text ) - $k ) {
        if ( hamming_distance( $pattern, substr $text, $i, $k ) <= $d ) {
            push @pos, $i;
        }
    }

    return @pos;
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

approximate-match.pl

Approximate Pattern Matching

=head1 VERSION

version 0.1.0

=head1 DESCRIPTION

This script solves the Approximate Pattern Matching Problem.

Input: Strings I<Pattern> and I<Text> along with an integer I<d>.

Output: All starting positions where I<Pattern> appears as a substring of
I<Text> with at most I<d> mismatches.

=head1 EXAMPLES

    perl approximate-match.pl

    perl approximate-match.pl --input_file approximate-match-extra-input.txt

    diff <(perl approximate-match.pl) approximate-match-sample-output.txt

    diff \
        <(perl approximate-match.pl \
            --input_file approximate-match-extra-input.txt) \
        approximate-match-extra-output.txt

    perl approximate-match.pl --input_file dataset_9_4.txt \
        > dataset_9_4_output.txt

=head1 USAGE

    approximate-match.pl
        [--input_file FILE]
        [--debug]
        [--help]
        [--man]

=head1 OPTIONS

=over 8

=item B<--input_file FILE>

The input file containing "Strings I<Pattern> and I<Text> along with an integer
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
