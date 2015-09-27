#!/usr/bin/env perl

# PODNAME: median-string.pl
# ABSTRACT: Median String

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
my $input_file = 'median-string-sample-input.txt';
my ( $debug, $help, $man );

# Get and check command line options
get_and_check_options();

my ( $k, @dna ) = path($input_file)->lines( { chomp => 1 } );

printf "%s\n", median_string( \@dna, $k );

sub median_string {
    my ( $dna, $k ) = @_;    ## no critic (ProhibitReusedNames)

    my $min_distance = $k + 1;
    my $median;
    foreach my $i ( 0 .. 4**$k - 1 ) {    ## no critic (ProhibitMagicNumbers)
        my $pattern = number_to_pattern( $i, $k );
        my $distance = distance_between_pattern_and_strings( $pattern, $dna );
        if ( $distance < $min_distance ) {
            $min_distance = $distance;
            $median       = $pattern;
        }
    }

    return $median;
}

sub number_to_pattern {
    my ( $index, $k ) = @_;    ## no critic (ProhibitReusedNames)

    return number_to_symbol($index) if $k == 1;

    ## no critic (ProhibitMagicNumbers)
    my $prefix_index = int( $index / 4 );
    my $r            = $index % 4;
    ## use critic

    my $symbol = number_to_symbol($r);
    my $prefix_pattern = number_to_pattern( $prefix_index, $k - 1 );

    return $prefix_pattern . $symbol;
}

sub number_to_symbol {
    my ($number) = @_;

    my $symbol = $number;
    $symbol =~ tr/0123/ACGT/;

    return $symbol;
}

sub distance_between_pattern_and_strings {
    my ( $pattern, $dna ) = @_;

    my $k        = length $pattern;    ## no critic (ProhibitReusedNames)
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

median-string.pl

Median String

=head1 VERSION

version 0.1.0

=head1 DESCRIPTION

This script implements Median String.

Input: An integer I<k>, followed by a collection of strings I<Dna>.

Output: A I<k>-mer I<Pattern> that minimizes I<d>(I<Pattern>, I<Dna>) among all
I<k>-mers I<Pattern>. (If there are multiple such strings I<Pattern>, then you
may return any one.)

=head1 EXAMPLES

    perl median-string.pl

    perl median-string.pl --input_file median-string-extra-input.txt

    diff <(perl median-string.pl) median-string-sample-output.txt

    diff \
        <(perl median-string.pl --input_file median-string-extra-input.txt) \
       median-string-extra-output.txt

    perl median-string.pl --input_file dataset_158_9.txt \
        > dataset_158_9_output.txt

    perl median-string.pl \
        --input_file <(echo -e "7\nCTCGATGAGTAGGAAAGTAGTTTCACTGGGCGAACCACCCCGGCGCTAATCCTAGTGCCC\nGCAATCCTACCCGAGGCCACATATCAGTAGGAACTAGAACCACCACGGGTGGCTAGTTTC\nGGTGTTGAACCACGGGGTTAGTTTCATCTATTGTAGGAATCGGCTTCAAATCCTACACAG")

=head1 USAGE

    median-string.pl
        [--input_file FILE]
        [--debug]
        [--help]
        [--man]

=head1 OPTIONS

=over 8

=item B<--input_file FILE>

The input file containing "An integer I<k>, followed by a collection of strings
I<Dna>".

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
