#!/usr/bin/env perl

# PODNAME: pattern-count.pl
# ABSTRACT: Pattern Count

## Author     : Ian Sealy
## Maintainer : Ian Sealy
## Created    : 2015-09-02

use warnings;
use strict;
use autodie;
use Getopt::Long;
use Pod::Usage;
use Carp;
use Path::Tiny;
use version; our $VERSION = qv('v0.1.0');

# Default options
my $input_file = 'pattern-count-sample-input.txt';
my ( $debug, $help, $man );

# Get and check command line options
get_and_check_options();

my ( $text, $pattern ) = path($input_file)->lines( { chomp => 1 } );

printf "%d\n", pattern_count( $text, $pattern );

sub pattern_count {
    my ( $text, $pattern ) = @_;    ## no critic (ProhibitReusedNames)

    my $count = 0;

    foreach my $i ( 0 .. ( ( length $text ) - length $pattern ) ) {
        if ( ( substr $text, $i, length $pattern ) eq $pattern ) {
            $count++;
        }
    }

    return $count;
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

pattern-count.pl

Pattern Count

=head1 VERSION

version 0.1.0

=head1 DESCRIPTION

This script implements Pattern Count.

Input: Strings I<Text> and I<Pattern>.

Output: I<Count>(I<Text>, I<Pattern>).

=head1 EXAMPLES

    perl pattern-count.pl

    perl pattern-count.pl --input_file pattern-count-extra-input.txt

    diff <(perl pattern-count.pl) pattern-count-sample-output.txt

    diff \
        <(perl pattern-count.pl --input_file pattern-count-extra-input.txt) \
        pattern-count-extra-output.txt

    perl pattern-count.pl --input_file dataset_2_6.txt > dataset_2_6_output.txt

=head1 USAGE

    pattern-count.pl
        [--input_file FILE]
        [--debug]
        [--help]
        [--man]

=head1 OPTIONS

=over 8

=item B<--input_file FILE>

The input file containing "Strings I<Text> and I<Pattern>".

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
