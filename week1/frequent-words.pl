#!/usr/bin/env perl

# PODNAME: frequent-words.pl
# ABSTRACT: Frequent Words

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

use List::Util qw(max);
use List::MoreUtils qw(uniq);

# Default options
my $input_file = 'frequent-words-sample-input.txt';
my ( $debug, $help, $man );

# Get and check command line options
get_and_check_options();

my ( $text, $k ) = path($input_file)->lines( { chomp => 1 } );

printf "%s\n", join q{ }, frequent_words( $text, $k );

sub frequent_words {
    my ( $text, $k ) = @_;    ## no critic (ProhibitReusedNames)

    my @frequent_patterns;
    my @count;

    foreach my $i ( 0 .. ( length $text ) - $k ) {
        my $pattern = substr $text, $i, $k;
        $count[$i] = pattern_count( $text, $pattern );
    }
    my $max_count = max(@count);

    foreach my $i ( 0 .. ( length $text ) - $k ) {
        if ( $count[$i] == $max_count ) {
            push @frequent_patterns, substr $text, $i, $k;
        }
    }

    return uniq( sort @frequent_patterns );
}

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

frequent-words.pl

Frequent Words

=head1 VERSION

version 0.1.0

=head1 DESCRIPTION

This script solves the Frequent Words Problem.

Input: A string I<Text> and an integer I<k>.

Output: All most frequent I<k>-mers in I<Text>.

=head1 EXAMPLES

    perl frequent-words.pl

    perl frequent-words.pl --input_file frequent-words-extra-input.txt

    diff <(perl frequent-words.pl) frequent-words-sample-output.txt

    diff \
        <(perl frequent-words.pl --input_file frequent-words-extra-input.txt) \
        frequent-words-extra-output.txt

    perl frequent-words.pl --input_file dataset_2_9.txt > dataset_2_9_output.txt

    perl frequent-words.pl \
        --input_file <(echo -e "CGCCTAAATAGCCTCGCGGAGCCTTATGTCATACTCGTCCT\n3")

=head1 USAGE

    frequent-words.pl
        [--input_file FILE]
        [--debug]
        [--help]
        [--man]

=head1 OPTIONS

=over 8

=item B<--input_file FILE>

The input file containing "A string I<Text> and an integer I<k>".

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
