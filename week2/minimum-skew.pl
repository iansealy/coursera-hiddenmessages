#!/usr/bin/env perl

# PODNAME: minimum-skew.pl
# ABSTRACT: Minimum Skew

## Author     : Ian Sealy
## Maintainer : Ian Sealy
## Created    : 2015-09-19

use warnings;
use strict;
use autodie;
use Getopt::Long;
use Pod::Usage;
use Carp;
use Path::Tiny;
use version; our $VERSION = qv('v0.1.0');

# Default options
my $input_file = 'minimum-skew-sample-input.txt';
my ( $debug, $help, $man );

# Get and check command line options
get_and_check_options();

my ($genome) = path($input_file)->lines( { chomp => 1 } );

printf "%s\n", join q{ }, minimum_skew($genome);

sub minimum_skew {
    my ($genome) = @_;    ## no critic (ProhibitReusedNames)

    my $skew     = 0;
    my $min_skew = 0;
    my @is       = (0);
    foreach my $i ( 1 .. length $genome ) {
        my $base = substr $genome, $i - 1, 1;
        if ( $base eq q{C} ) {
            $skew--;
            if ( $skew < $min_skew ) {
                $min_skew = $skew;
                @is       = ();
            }
        }
        elsif ( $base eq q{G} ) {
            $skew++;
        }
        if ( $skew == $min_skew ) {
            push @is, $i;
        }
    }

    return @is;
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

minimum-skew.pl

Minimum Skew

=head1 VERSION

version 0.1.0

=head1 DESCRIPTION

This script solves the Minimum Skew Problem.

Input: A DNA string I<Genome>.

Output: All integer(s) I<i> minimizing I<Skewi> (I<Genome>) among all values of
I<i> (from 0 to |I<Genome>|).

=head1 EXAMPLES

    perl minimum-skew.pl

    perl minimum-skew.pl --input_file minimum-skew-extra-input.txt

    diff <(perl minimum-skew.pl) minimum-skew-sample-output.txt

    diff \
        <(perl minimum-skew.pl --input_file minimum-skew-extra-input.txt) \
        minimum-skew-extra-output.txt

    perl minimum-skew.pl --input_file dataset_7_6.txt > dataset_7_6_output.txt

    perl minimum-skew.pl --input_file <(echo "GATACACTTCCCGAGTAGGTACTG")

    perl minimum-skew.pl \
        --input_file <(grep -v '^>' Salmonella_enterica.txt | tr -d '\r\n')

=head1 USAGE

    minimum-skew.pl
        [--input_file FILE]
        [--debug]
        [--help]
        [--man]

=head1 OPTIONS

=over 8

=item B<--input_file FILE>

The input file containing "A DNA string I<Genome>".

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
