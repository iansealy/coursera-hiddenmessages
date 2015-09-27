#!/usr/bin/env perl

# PODNAME: distance-between-pattern-and-strings.pl
# ABSTRACT: Distance Between Pattern And Strings

## Author     : Ian Sealy
## Maintainer : Ian Sealy
## Created    : 2015-09-27

use warnings;
use strict;
use autodie;
use Getopt::Long;
use Pod::Usage;
use Carp;
use Path::Tiny;
use version; our $VERSION = qv('v0.1.0');

# Default options
my $input_file = 'distance-between-pattern-and-strings-sample-input.txt';
my ( $debug, $help, $man );

# Get and check command line options
get_and_check_options();

my ( $pattern, $dna ) = path($input_file)->lines( { chomp => 1 } );
my @dna = split /\s+/xms, $dna;

printf "%d\n", distance_between_pattern_and_strings( $pattern, \@dna );

sub distance_between_pattern_and_strings {
    my ( $pattern, $dna ) = @_;    ## no critic (ProhibitReusedNames)

    my $k        = length $pattern;
    my $distance = 0;
    foreach my $text ( @{$dna} ) {
        my $min_hamming_distance = $k;
        foreach my $i ( 0 .. ( length $text ) - $k ) {
            my $hamming_distance =
              hamming_distance( $pattern, ( substr $text, $i, $k ) );
            if ( $hamming_distance < $min_hamming_distance ) {
                $min_hamming_distance = $hamming_distance;
            }
        }
        $distance += $min_hamming_distance;
    }

    return $distance;
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

distance-between-pattern-and-strings.pl

Distance Between Pattern And Strings

=head1 VERSION

version 0.1.0

=head1 DESCRIPTION

This script implements Distance Between Pattern And Strings.

Input: A string I<Pattern> followed by a collection of strings I<Dna>.

Output: I<d>(I<Pattern>, I<Dna>).

=head1 EXAMPLES

    perl distance-between-pattern-and-strings.pl

    diff <(perl distance-between-pattern-and-strings.pl) \
        distance-between-pattern-and-strings-sample-output.txt

    perl distance-between-pattern-and-strings.pl \
        --input_file dataset_5164_1.txt \
        > dataset_5164_1_output.txt

=head1 USAGE

    distance-between-pattern-and-strings.pl
        [--input_file FILE]
        [--debug]
        [--help]
        [--man]

=head1 OPTIONS

=over 8

=item B<--input_file FILE>

The input file containing "A string I<Pattern> followed by a collection of
strings I<Dna>".

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
