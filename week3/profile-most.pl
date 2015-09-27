#!/usr/bin/env perl

# PODNAME: profile-most.pl
# ABSTRACT: Profile-most Probable k-mer

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
my $input_file = 'profile-most-sample-input.txt';
my ( $debug, $help, $man );

# Get and check command line options
get_and_check_options();

my ( $text, $k, @profile ) = path($input_file)->lines( { chomp => 1 } );
my %profile;
my @nucleotides = qw(A C G T);
foreach my $i ( 0 .. 3 ) {    ## no critic (ProhibitMagicNumbers)
    $profile{ $nucleotides[$i] } = [ split /\s+/xms, $profile[$i] ];
}

printf "%s\n", profile_most( $text, $k, \%profile );

sub profile_most {
    my ( $text, $k, $profile ) = @_;    ## no critic (ProhibitReusedNames)

    my $kmer;
    my $max_prob = 0;
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

profile-most.pl

Profile-most Probable k-mer

=head1 VERSION

version 0.1.0

=head1 DESCRIPTION

This script solves the Profile-most Probable k-mer Problem.

Input: A string I<Text>, an integer I<k>, and a 4 × I<k> matrix I<Profile>.

Output: A I<Profile>-most probable I<k>-mer in I<Text>.

=head1 EXAMPLES

    perl profile-most.pl

    perl profile-most.pl --input_file profile-most-extra-input.txt

    diff <(perl profile-most.pl) profile-most-sample-output.txt

    diff \
        <(perl profile-most.pl --input_file profile-most-extra-input.txt) \
       profile-most-extra-output.txt

    perl profile-most.pl --input_file dataset_159_3.txt \
        > dataset_159_3_output.txt

=head1 USAGE

    profile-most.pl
        [--input_file FILE]
        [--debug]
        [--help]
        [--man]

=head1 OPTIONS

=over 8

=item B<--input_file FILE>

The input file containing "A string I<Text>, an integer I<k>, and a 4 × I<k>
matrix I<Profile>".

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
