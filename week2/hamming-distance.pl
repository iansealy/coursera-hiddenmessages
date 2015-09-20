#!/usr/bin/env perl

# PODNAME: hamming-distance.pl
# ABSTRACT: Hamming Distance

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
my $input_file = 'hamming-distance-sample-input.txt';
my ( $debug, $help, $man );

# Get and check command line options
get_and_check_options();

my ( $string1, $string2 ) = path($input_file)->lines( { chomp => 1 } );

printf "%d\n", hamming_distance( $string1, $string2 );

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

hamming-distance.pl

Hamming Distance

=head1 VERSION

version 0.1.0

=head1 DESCRIPTION

This script solves the Hamming Distance Problem.

Input: Two strings of equal length.

Output: The Hamming distance between these strings.

=head1 EXAMPLES

    perl hamming-distance.pl

    perl hamming-distance.pl --input_file hamming-distance-extra-input.txt

    diff <(perl hamming-distance.pl) hamming-distance-sample-output.txt

    diff \
        <(perl hamming-distance.pl \
            --input_file hamming-distance-extra-input.txt) \
        hamming-distance-extra-output.txt

    perl hamming-distance.pl --input_file dataset_9_3.txt > dataset_9_3_output.txt

    perl hamming-distance.pl \
        --input_file <(echo -e "TGACCCGTTATGCTCGAGTTCGGTCAGAGCGTCATTGCGAGTAGTCGTTTGCTTTCTCAAACTCC\nGAGCGATTAAGCGTGACAGCCCCAGGGAACCCACAAAACGTGATCGCAGTCCATCCGATCATACA")

=head1 USAGE

    hamming-distance.pl
        [--input_file FILE]
        [--debug]
        [--help]
        [--man]

=head1 OPTIONS

=over 8

=item B<--input_file FILE>

The input file containing "Two strings of equal length".

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
