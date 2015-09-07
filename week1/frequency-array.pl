#!/usr/bin/env perl

# PODNAME: frequency-array.pl
# ABSTRACT: Computing Frequencies

## Author     : Ian Sealy
## Maintainer : Ian Sealy
## Created    : 2015-09-07

use warnings;
use strict;
use autodie;
use Getopt::Long;
use Pod::Usage;
use Carp;
use Path::Tiny;
use version; our $VERSION = qv('v0.1.0');

# Default options
my $input_file = 'frequency-array-sample-input.txt';
my ( $debug, $help, $man );

# Get and check command line options
get_and_check_options();

my ( $text, $k ) = path($input_file)->lines( { chomp => 1 } );

printf "%s\n", join q{ }, computing_frequencies( $text, $k );

sub computing_frequencies {
    my ( $text, $k ) = @_;    ## no critic (ProhibitReusedNames)

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

frequency-array.pl

Computing Frequencies

=head1 VERSION

version 0.1.0

=head1 DESCRIPTION

This script implements Computing Frequencies.

Input: A DNA string I<Text> followed by an integer I<k>.

Output: The string I<NumberToPattern>(I<index>, I<k>).

=head1 EXAMPLES

    perl frequency-array.pl

    perl frequency-array.pl --input_file frequency-array-extra-input.txt

    diff <(perl frequency-array.pl) frequency-array-sample-output.txt

    diff \
        <(perl frequency-array.pl \
            --input_file frequency-array-extra-input.txt) \
        frequency-array-extra-output.txt

    perl frequency-array.pl --input_file dataset_2994_5.txt \
        > dataset_2994_5_output.txt

=head1 USAGE

    frequency-array.pl
        [--input_file FILE]
        [--debug]
        [--help]
        [--man]

=head1 OPTIONS

=over 8

=item B<--input_file FILE>

The input file containing "A DNA string I<Text> followed by an integer I<k>".

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
