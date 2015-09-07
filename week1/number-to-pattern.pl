#!/usr/bin/env perl

# PODNAME: number-to-pattern.pl
# ABSTRACT: Number To Pattern

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
my $input_file = 'number-to-pattern-sample-input.txt';
my ( $debug, $help, $man );

# Get and check command line options
get_and_check_options();

my ( $index, $k ) = path($input_file)->lines( { chomp => 1 } );

printf "%s\n", number_to_pattern( $index, $k );

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

number-to-pattern.pl

Number To Pattern

=head1 VERSION

version 0.1.0

=head1 DESCRIPTION

This script implements Number To Pattern.

Input: Integers I<index> and I<k>.

Output: The string I<NumberToPattern>(I<index>, I<k>).

=head1 EXAMPLES

    perl number-to-pattern.pl

    perl number-to-pattern.pl --input_file number-to-pattern-extra-input.txt

    diff <(perl number-to-pattern.pl) number-to-pattern-sample-output.txt

    diff \
        <(perl number-to-pattern.pl \
            --input_file number-to-pattern-extra-input.txt) \
        number-to-pattern-extra-output.txt

    perl number-to-pattern.pl --input_file dataset_3010_4.txt \
        > dataset_3010_4_output.txt

=head1 USAGE

    number-to-pattern.pl
        [--input_file FILE]
        [--debug]
        [--help]
        [--man]

=head1 OPTIONS

=over 8

=item B<--input_file FILE>

The input file containing "Integers I<index> and I<k>".

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
