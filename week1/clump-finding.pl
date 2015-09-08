#!/usr/bin/env perl

# PODNAME: clump-finding.pl
# ABSTRACT: Clump Finding

## Author     : Ian Sealy
## Maintainer : Ian Sealy
## Created    : 2015-09-08

use warnings;
use strict;
use autodie;
use Getopt::Long;
use Pod::Usage;
use Carp;
use Path::Tiny;
use version; our $VERSION = qv('v0.1.0');

# Default options
my $input_file = 'clump-finding-sample-input.txt';
my ( $debug, $help, $man );

# Get and check command line options
get_and_check_options();

my ( $genome, $integers ) = path($input_file)->lines( { chomp => 1 } );
my ( $k, $l, $t ) = split /\s+/xms, $integers;

printf "%s\n", join q{ }, clump_finding( $genome, $k, $t, $l );

sub clump_finding {
    my ( $genome, $k, $t, $l ) = @_;    ## no critic (ProhibitReusedNames)

    my @frequent_patterns;

    my @clump;
    foreach my $i ( 0 .. 4**$k - 1 ) {    ## no critic (ProhibitMagicNumbers)
        $clump[$i] = 0;
    }

    my $text = substr $genome, 0, $l;
    my @frequency_array = computing_frequencies( $text, $k );

    foreach my $i ( 0 .. 4**$k - 1 ) {    ## no critic (ProhibitMagicNumbers)
        if ( $frequency_array[$i] >= $t ) {
            $clump[$i] = 1;
        }
    }

    foreach my $i ( 1 .. ( length $genome ) - $l ) {
        my $first_pattern = substr $genome, $i - 1, $k;
        my $index = pattern_to_number($first_pattern);
        $frequency_array[$index]--;
        my $last_pattern = substr $genome, $i + $l - $k, $k;
        $index = pattern_to_number($last_pattern);
        $frequency_array[$index]++;
        if ( $frequency_array[$index] >= $t ) {
            $clump[$index] = 1;
        }
    }

    foreach my $i ( 0 .. 4**$k - 1 ) {    ## no critic (ProhibitMagicNumbers)
        if ( $clump[$i] == 1 ) {
            my $pattern = number_to_pattern( $i, $k );
            push @frequent_patterns, $pattern;
        }
    }

    return @frequent_patterns;
}

sub computing_frequencies {
    my ( $text, $k ) = @_;                ## no critic (ProhibitReusedNames)

    my @frequency_array;
    foreach my $i ( 0 .. 4**$k - 1 ) {    ## no critic (ProhibitMagicNumbers)
        $frequency_array[$i] = 0;
    }

    foreach my $i ( 0 .. ( length $text ) - $k ) {
        my $pattern = substr $text, $i, $k;
        my $j = pattern_to_number($pattern);
        $frequency_array[$j]++;
    }

    return @frequency_array;
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

clump-finding.pl

Clump Finding

=head1 VERSION

version 0.1.0

=head1 DESCRIPTION

This script solves the Clump Finding Problem.

Input: A string Genome, and integers I<k>, I<L>, and I<t>.

Output: All distinct I<k>-mers forming (I<L>, I<t>)-clumps in I<Genome>.

=head1 EXAMPLES

    perl clump-finding.pl

    perl clump-finding.pl --input_file clump-finding-extra-input.txt

    diff <(perl clump-finding.pl) clump-finding-sample-output.txt

    diff \
        <(perl clump-finding.pl --input_file clump-finding-extra-input.txt) \
        clump-finding-extra-output.txt

    perl clump-finding.pl --input_file dataset_4_5.txt > dataset_4_5_output.txt

    perl clump-finding.pl \
        --input_file <(cat E-coli.txt && echo && echo "9 500 3") \
        | sed -e 's/ /\n/g' | wc -l > E-coli_output.txt

=head1 USAGE

    clump-finding.pl
        [--input_file FILE]
        [--debug]
        [--help]
        [--man]

=head1 OPTIONS

=over 8

=item B<--input_file FILE>

The input file containing "A string Genome, and integers I<k>, I<L>, and I<t>".

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
