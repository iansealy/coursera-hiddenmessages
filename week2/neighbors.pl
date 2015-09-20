#!/usr/bin/env perl

# PODNAME: neighbors.pl
# ABSTRACT: Neighbors

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
my $input_file = 'neighbors-sample-input.txt';
my ( $debug, $help, $man );

# Get and check command line options
get_and_check_options();

my ( $pattern, $d ) = path($input_file)->lines( { chomp => 1 } );

printf "%s\n", join "\n", neighbors( $pattern, $d );

sub neighbors {
    my ( $pattern, $d ) = @_;    ## no critic (ProhibitReusedNames)

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

neighbors.pl

Neighbors

=head1 VERSION

version 0.1.0

=head1 DESCRIPTION

This script implements Neighbors.

Input: A string I<Pattern> and an integer I<d>.

Output: The collection of strings I<Neighbors>(I<Pattern>, I<d>).

=head1 EXAMPLES

    perl neighbors.pl

    perl neighbors.pl --input_file neighbors-extra-input.txt

    diff <(perl neighbors.pl | sort) <(sort neighbors-sample-output.txt)

    diff \
        <(perl neighbors.pl --input_file neighbors-extra-input.txt | sort) \
        <(sort neighbors-extra-output.txt)

    perl neighbors.pl --input_file dataset_3014_3.txt \
        > dataset_3014_3_output.txt

=head1 USAGE

    neighbors.pl
        [--input_file FILE]
        [--debug]
        [--help]
        [--man]

=head1 OPTIONS

=over 8

=item B<--input_file FILE>

The input file containing "A string I<Pattern> and an integer I<d>".

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
