#!/usr/bin/env perl

# PODNAME: motif-enumeration.pl
# ABSTRACT: Motif Enumeration

## Author     : Ian Sealy
## Maintainer : Ian Sealy
## Created    : 2015-09-25

use warnings;
use strict;
use autodie;
use Getopt::Long;
use Pod::Usage;
use Carp;
use Path::Tiny;
use version; our $VERSION = qv('v0.1.0');

use List::MoreUtils qw(uniq);

# Default options
my $input_file = 'motif-enumeration-sample-input.txt';
my ( $debug, $help, $man );

# Get and check command line options
get_and_check_options();

my ( $integers, @dna ) = path($input_file)->lines( { chomp => 1 } );
my ( $k, $d ) = split /\s+/xms, $integers;

printf "%s\n", join q{ }, motif_enumeration( \@dna, $k, $d );

sub motif_enumeration {
    my ( $dna, $k, $d ) = @_;    ## no critic (ProhibitReusedNames)

    my @patterns;

    foreach my $dna_string1 ( @{$dna} ) {
        foreach my $i ( 0 .. ( length $dna_string1 ) - $k ) {
          PATTERN:
            foreach
              my $pattern ( neighbors( ( substr $dna_string1, $i, $k ), $d ) )
            {
                foreach my $dna_string2 ( @{$dna} ) {
                    next PATTERN
                      if !approximate_pattern_count( $dna_string2, $pattern,
                        $d );
                }
                push @patterns, $pattern;
            }
        }
    }

    return uniq( sort @patterns );
}

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

motif-enumeration.pl

Motif Enumeration

=head1 VERSION

version 0.1.0

=head1 DESCRIPTION

This script implements Motif Enumeration.

Input: Integers I<k> and I<d>, followed by a collection of strings I<Dna>.

Output: All (I<k>, I<d>)-motifs in I<Dna>.

=head1 EXAMPLES

    perl motif-enumeration.pl

    perl motif-enumeration.pl --input_file motif-enumeration-extra-input.txt

    diff <(perl motif-enumeration.pl) motif-enumeration-sample-output.txt

    diff \
        <(perl motif-enumeration.pl \
            --input_file motif-enumeration-extra-input.txt) \
       motif-enumeration-extra-output.txt

    perl motif-enumeration.pl --input_file dataset_156_7.txt \
        > dataset_156_7_output.txt

=head1 USAGE

    motif-enumeration.pl
        [--input_file FILE]
        [--debug]
        [--help]
        [--man]

=head1 OPTIONS

=over 8

=item B<--input_file FILE>

The input file containing "Integers I<k> and I<d>, followed by a collection of
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
