#!/usr/bin/env perl

# PODNAME: pattern-to-number.pl
# ABSTRACT: Pattern To Number

## Author     : Ian Sealy
## Maintainer : Ian Sealy
## Created    : 2015-09-06

use warnings;
use strict;
use autodie;
use Getopt::Long;
use Pod::Usage;
use Carp;
use Path::Tiny;
use version; our $VERSION = qv('v0.1.0');

# Default options
my $input_file = 'pattern-to-number-sample-input.txt';
my ( $debug, $help, $man );

# Get and check command line options
get_and_check_options();

my ($pattern) = path($input_file)->lines( { chomp => 1 } );

printf "%d\n", pattern_to_number($pattern);

sub pattern_to_number {
    my ($pattern) = @_;    ## no critic (ProhibitReusedNames)

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

pattern-to-number.pl

Pattern To Number

=head1 VERSION

version 0.1.0

=head1 DESCRIPTION

This script implements Pattern To Number.

Input: A DNA string I<Pattern>.

Output: The integer I<PatternToNumber>(I<Pattern>).

=head1 EXAMPLES

    perl pattern-to-number.pl

    perl pattern-to-number.pl --input_file pattern-to-number-extra-input.txt

    diff <(perl pattern-to-number.pl) pattern-to-number-sample-output.txt

    diff \
        <(perl pattern-to-number.pl \
            --input_file pattern-to-number-extra-input.txt) \
        pattern-to-number-extra-output.txt

    perl pattern-to-number.pl --input_file dataset_3010_2.txt \
        > dataset_3010_2_output.txt

=head1 USAGE

    pattern-to-number.pl
        [--input_file FILE]
        [--debug]
        [--help]
        [--man]

=head1 OPTIONS

=over 8

=item B<--input_file FILE>

The input file containing "A DNA string I<Pattern>".

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
