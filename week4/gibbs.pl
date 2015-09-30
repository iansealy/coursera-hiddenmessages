#!/usr/bin/env perl

# PODNAME: gibbs.pl
# ABSTRACT: Gibbs Sampler

## Author     : Ian Sealy
## Maintainer : Ian Sealy
## Created    : 2015-09-30

use warnings;
use strict;
use autodie;
use Getopt::Long;
use Pod::Usage;
use Carp;
use Path::Tiny;
use version; our $VERSION = qv('v0.1.0');

use List::Util qw(sum);

# Default options
my $input_file = 'gibbs-sample-input.txt';
my ( $debug, $help, $man );

# Get and check command line options
get_and_check_options();

my ( $integers, @dna ) = path($input_file)->lines( { chomp => 1 } );
my ( $k, $t, $n ) = split /\s+/xms, $integers;

printf "%s\n", join "\n", repeat_gibbs_sampler( \@dna, $k, $t, $n );

sub repeat_gibbs_sampler {
    my ( $dna, $k, $t, $n ) = @_;    ## no critic (ProhibitReusedNames)

    my @best_motifs = gibbs_sampler( $dna, $k, $t, $n );

    foreach ( 1 .. 19 ) {            ## no critic (ProhibitMagicNumbers)
        my @motifs = gibbs_sampler( $dna, $k, $t, $n );
        if ( score( \@motifs, $k, $t ) < score( \@best_motifs, $k, $t ) ) {
            @best_motifs = @motifs;
        }
    }

    return @best_motifs;
}

sub gibbs_sampler {
    my ( $dna, $k, $t, $n ) = @_;    ## no critic (ProhibitReusedNames)

    my @motifs = map { substr $_, int rand( ( length $_ ) - $k ), $k } @{$dna};
    my @best_motifs = @motifs;
    foreach my $j ( 1 .. $n ) {
        my $i = rand $t;
        splice @motifs, $i, 1;
        my $profile = profile_pseudo( \@motifs, $k, $t - 1 );
        splice @motifs, $i, 0, profile_random( $dna->[$i], $k, $profile );
        if ( score( \@motifs, $k, $t ) < score( \@best_motifs, $k, $t ) ) {
            @best_motifs = @motifs;
        }
    }

    return @best_motifs;
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

sub profile_random {
    my ( $text, $k, $profile ) = @_;    ## no critic (ProhibitReusedNames)

    my @dist;
    foreach my $i ( 0 .. ( ( length $text ) - $k ) ) {
        push @dist, profile_prob( ( substr $text, $i, $k ), $profile );
    }

    return substr $text, random(@dist), $k;
}

sub profile_prob {
    my ( $kmer, $profile ) = @_;

    my $prob = 1;
    foreach my $i ( 0 .. ( length $kmer ) - 1 ) {
        $prob *= $profile->{ substr $kmer, $i, 1 }[$i];
    }

    return $prob;
}

sub random {
    my @dist = @_;

    my $rand       = rand sum(@dist);
    my $cumul_prob = 0;
    foreach my $i ( 0 .. ( scalar @dist ) - 1 ) {
        $cumul_prob += $dist[$i];
        return $i if $rand < $cumul_prob;
    }

    return;
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

gibbs.pl

Gibbs Sampler

=head1 VERSION

version 0.1.0

=head1 DESCRIPTION

This script implements Gibbs Sampler.

Input: Integers I<k>, I<t>, and I<N>, followed by a collection of strings
I<Dna>.

Output: The strings I<BestMotifs> resulting from running
B<GibbsSampler>(I<Dna>, I<k>, I<t>, I<N>) with 20 random starts.

=head1 EXAMPLES

    perl gibbs.pl

    perl gibbs.pl --input_file gibbs-extra-input.txt

    diff <(perl gibbs.pl) gibbs-sample-output.txt

    diff \
        <(perl gibbs.pl --input_file gibbs-extra-input.txt) \
        gibbs-extra-output.txt

    perl gibbs.pl --input_file dataset_163_4.txt > dataset_163_4_output.txt

=head1 USAGE

    gibbs.pl
        [--input_file FILE]
        [--debug]
        [--help]
        [--man]

=head1 OPTIONS

=over 8

=item B<--input_file FILE>

The input file containing "Integers I<k>, I<t>, and I<N>, followed by a
collection of strings I<Dna>".

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
