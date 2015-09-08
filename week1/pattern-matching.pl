#!/usr/bin/env perl

# PODNAME: pattern-matching.pl
# ABSTRACT: Pattern Matching

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
my $input_file = 'pattern-matching-sample-input.txt';
my ( $debug, $help, $man );

# Get and check command line options
get_and_check_options();

my ( $pattern, $genome ) = path($input_file)->lines( { chomp => 1 } );

printf "%s\n", join q{ }, pattern_matching( $pattern, $genome );

sub pattern_matching {
    my ( $pattern, $genome ) = @_;    ## no critic (ProhibitReusedNames)

    my @pos;

    my $k = length $pattern;
    foreach my $i ( 0 .. ( length $genome ) - $k ) {
        if ( ( substr $genome, $i, $k ) eq $pattern ) {
            push @pos, $i;
        }
    }

    return @pos;
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

pattern-matching.pl

Pattern Matching

=head1 VERSION

version 0.1.0

=head1 DESCRIPTION

This script solves the Pattern Matching Problem.

Input: Two strings, I<Pattern> and I<Genome>.

Output: A collection of space-separated integers specifying all starting
positions where I<Pattern> appears as a substring of I<Genome>.

=head1 EXAMPLES

    perl pattern-matching.pl

    perl pattern-matching.pl --input_file pattern-matching-extra-input.txt

    diff <(perl pattern-matching.pl) pattern-matching-sample-output.txt

    diff \
        <(perl pattern-matching.pl \
            --input_file pattern-matching-extra-input.txt) \
        pattern-matching-extra-output.txt

    perl pattern-matching.pl --input_file dataset_3_5.txt \
        > dataset_3_5_output.txt

=head1 USAGE

    pattern-matching.pl
        [--input_file FILE]
        [--debug]
        [--help]
        [--man]

=head1 OPTIONS

=over 8

=item B<--input_file FILE>

The input file containing "Two strings, I<Pattern> and I<Genome>".

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
