#!/usr/bin/env perl

# PODNAME: frequent-words-mismatch.pl
# ABSTRACT: Frequent Words with Mismatches

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

use List::Util qw(max);

# Default options
my $input_file = 'frequent-words-mismatch-sample-input.txt';
my ( $debug, $help, $man );

# Get and check command line options
get_and_check_options();

my ( $text, $integers ) = path($input_file)->lines( { chomp => 1 } );
my ( $k, $d ) = split /\s+/xms, $integers;

printf "%s\n", join q{ }, frequent_words_mismatch( $text, $k, $d );

sub frequent_words_mismatch {
    my ( $text, $k, $d ) = @_;    ## no critic (ProhibitReusedNames)

    my @frequent_patterns;
    my @near;
    my @frequency_array;
    foreach my $i ( 0 .. 4**$k - 1 ) {    ## no critic (ProhibitMagicNumbers)
        $near[$i]            = 0;
        $frequency_array[$i] = 0;
    }

    foreach my $i ( 0 .. ( length $text ) - $k ) {
        my @neighborhood = neighbors( ( substr $text, $i, $k ), $d );
        foreach my $pattern (@neighborhood) {
            $near[ pattern_to_number($pattern) ] = 1;
        }
    }

    foreach my $i ( 0 .. 4**$k - 1 ) {    ## no critic (ProhibitMagicNumbers)
        if ( $near[$i] ) {
            my $pattern = number_to_pattern( $i, $k );
            $frequency_array[$i] =
              approximate_pattern_count( $text, $pattern, $d );
        }
    }
    my $max_count = max(@frequency_array);

    foreach my $i ( 0 .. 4**$k - 1 ) {    ## no critic (ProhibitMagicNumbers)
        if ( $frequency_array[$i] == $max_count ) {
            my $pattern = number_to_pattern( $i, $k );
            push @frequent_patterns, $pattern;
        }
    }

    return @frequent_patterns;
}

sub neighbors {
    my ( $pattern, $d ) = @_;             ## no critic (ProhibitReusedNames)

    return $pattern if $d == 0;
    return qw(A C G T) if length $pattern == 1;

    my @neighborhood;
    my $suffix_pattern = substr $pattern, 1;
    my @suffix_neighbors = neighbors( $suffix_pattern, $d );
    foreach my $text (@suffix_neighbors) {
        if ( hamming_distance( $suffix_pattern, $text ) < $d ) {
            foreach my $x (qw(A C G T)) {
                push @neighborhood, $x . $text;
            }
        }
        else {
            push @neighborhood, ( substr $pattern, 0, 1 ) . $text;
        }
    }

    return @neighborhood;
}

sub pattern_to_number {
    my ($pattern) = @_;

    return 0 if !$pattern;

    my ( $prefix, $symbol ) = $pattern =~ m/\A (.*) (.) \z/xms;

    ## no critic (ProhibitMagicNumbers)
    return 4 * pattern_to_number($prefix) + symbol_to_number($symbol);
    ## use critic
}

sub symbol_to_number {
    my ($symbol) = @_;

    my $number = $symbol;
    $number =~ tr/ACGT/0123/;

    return $number;
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

frequent-words-mismatch.pl

Frequent Words with Mismatches

=head1 VERSION

version 0.1.0

=head1 DESCRIPTION

This script solves the Frequent Words with Mismatches Problem.

Input: A string I<Text> as well as integers I<k> and I<d>. (You may assume I<k>
≤ 12 and I<d> ≤ 3.)

Output: All most frequent I<k>-mers with up to I<d> mismatches in I<Text>.

=head1 EXAMPLES

    perl frequent-words-mismatch.pl

    perl frequent-words-mismatch.pl \
        --input_file frequent-words-mismatch-extra-input.txt

    diff <(perl frequent-words-mismatch.pl | sed -e 's/ /\n/g' | sort) \
        <(sed -e 's/ /\n/g' frequent-words-mismatch-sample-output.txt | sort)

    diff \
        <(perl frequent-words-mismatch.pl \
            --input_file frequent-words-mismatch-extra-input.txt \
            | sed -e 's/ /\n/g' | sort) \
        <(sed -e 's/ /\n/g' frequent-words-mismatch-extra-output.txt | sort)

    perl frequent-words-mismatch.pl --input_file dataset_9_7.txt \
        > dataset_9_7_output.txt

=head1 USAGE

    frequent-words-mismatch.pl
        [--input_file FILE]
        [--debug]
        [--help]
        [--man]

=head1 OPTIONS

=over 8

=item B<--input_file FILE>

The input file containing "A string I<Text> as well as integers I<k> and I<d>".

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
