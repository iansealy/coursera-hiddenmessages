#!/usr/bin/env perl

# PODNAME: randomized.pl
# ABSTRACT: Randomized Motif Search

## Author     : Ian Sealy
## Maintainer : Ian Sealy
## Created    : 2015-09-29

use warnings;
use strict;
use autodie;
use Getopt::Long;
use Pod::Usage;
use Carp;
use Path::Tiny;
use version; our $VERSION = qv('v0.1.0');

# Default options
my $input_file = 'randomized-sample-input.txt';
my ( $debug, $help, $man );

# Get and check command line options
get_and_check_options();

my ( $integers, @dna ) = path($input_file)->lines( { chomp => 1 } );
my ( $k, $t ) = split /\s+/xms, $integers;

printf "%s\n", join "\n", repeat_randomized_motif_search( \@dna, $k, $t );

sub repeat_randomized_motif_search {
    my ( $dna, $k, $t ) = @_;    ## no critic (ProhibitReusedNames)

    my @best_motifs = randomized_motif_search( $dna, $k, $t );

    foreach ( 1 .. 999 ) {       ## no critic (ProhibitMagicNumbers)
        my @motifs = randomized_motif_search( $dna, $k, $t );
        if ( score( \@motifs, $k, $t ) < score( \@best_motifs, $k, $t ) ) {
            @best_motifs = @motifs;
        }
    }

    return @best_motifs;
}

sub randomized_motif_search {
    my ( $dna, $k, $t ) = @_;    ## no critic (ProhibitReusedNames)

    my @motifs = map { substr $_, int rand( ( length $_ ) - $k ), $k } @{$dna};
    my @best_motifs = @motifs;
    while (1) {
        my $profile = profile_pseudo( \@motifs, $k, $t );
        @motifs = motifs( $profile, $dna, $k );
        if ( score( \@motifs, $k, $t ) < score( \@best_motifs, $k, $t ) ) {
            @best_motifs = @motifs;
        }
        else {
            return @best_motifs;
        }
    }

    return;
}

sub profile_pseudo {
    my ( $motifs, $k, $t ) = @_;    ## no critic (ProhibitReusedNames)

    my %profile;
    foreach my $i ( 0 .. $k - 1 ) {
        my %count = map { $_ => 1 } qw(A C G T);
        foreach my $motif ( @{$motifs} ) {
            $count{ substr $motif, $i, 1 }++;
        }
        foreach my $nucleotide (qw(A C G T)) {
            ## no critic (ProhibitMagicNumbers)
            push @{ $profile{$nucleotide} }, $count{$nucleotide} / ( $t + 4 );
            ## use critic
        }
    }

    return \%profile;
}

sub motifs {
    my ( $profile, $dna, $k ) = @_;    ## no critic (ProhibitReusedNames)

    return map { profile_most( $_, $k, $profile ) } @{$dna};
}

sub profile_most {
    my ( $text, $k, $profile ) = @_;    ## no critic (ProhibitReusedNames)

    my $kmer;
    my $max_prob = -1;                  ## no critic (ProhibitMagicNumbers)
    foreach my $i ( 0 .. ( ( length $text ) - $k ) ) {
        my $prob = profile_prob( ( substr $text, $i, $k ), $profile );
        if ( $prob > $max_prob ) {
            $max_prob = $prob;
            $kmer = substr $text, $i, $k;
        }
    }

    return $kmer;
}

sub profile_prob {
    my ( $kmer, $profile ) = @_;

    my $prob = 1;
    foreach my $i ( 0 .. ( length $kmer ) - 1 ) {
        $prob *= $profile->{ substr $kmer, $i, 1 }[$i];
    }

    return $prob;
}

sub score {
    my ( $motifs, $k, $t ) = @_;    ## no critic (ProhibitReusedNames)

    my $score = 0;

    foreach my $i ( 0 .. $k - 1 ) {
        my %count;
        foreach my $motif ( @{$motifs} ) {
            $count{ substr $motif, $i, 1 }++;
        }
        my $most_freq =
          ( reverse sort { $count{$a} <=> $count{$b} } keys %count )[0];
        $score += $t - $count{$most_freq};
    }

    return $score;
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

randomized.pl

Randomized Motif Search

=head1 VERSION

version 0.1.0

=head1 DESCRIPTION

This script implements Randomized Motif Search.

Input: Integers I<k> and I<t>, followed by a collection of strings I<Dna>.

Output: A collection I<BestMotifs> resulting from running
B<RandomizedMotifSearch>(I<Dna>, I<k>, I<t>) 1,000 times.

=head1 EXAMPLES

    perl randomized.pl

    perl randomized.pl --input_file randomized-extra-input.txt

    diff <(perl randomized.pl) randomized-sample-output.txt

    diff \
        <(perl randomized.pl --input_file randomized-extra-input.txt) \
       randomized-extra-output.txt

    perl randomized.pl --input_file dataset_161_5.txt > dataset_161_5_output.txt

=head1 USAGE

    randomized.pl
        [--input_file FILE]
        [--debug]
        [--help]
        [--man]

=head1 OPTIONS

=over 8

=item B<--input_file FILE>

The input file containing "Integers I<k> and I<t>, followed by a collection of
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
