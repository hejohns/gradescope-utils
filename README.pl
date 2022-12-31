#!/usr/bin/env perl

my @args = (
    "--date=2022-09-24",
    "--center='EECS 490 Gradescope Utilities'",
    "--release='Fall 2022'",
);
exec 'bash', '-c', "pod2man @args $0 | man -l -" or print STDERR "Is bash installed?: $!\n";

=pod

=encoding utf8

=head1 NAME

EECS 490 Gradescope Utilities

=head1 DESCRIPTION

Collection of scripts for gradescope stuff

Each file should contain its own documentation

Below is just a overview

originally a port of
L<https://github.com/eecs490/Assignment-8-Gradescope>
during W22

=head2 bin

The main scripts, in pipeline order:

=over 4

=item join.pl : gradescope submissions zip → json

I<csv> is single csv of all submissions

=item split : csv → json

=item csv2json : (json, csv) → json

=item split.pl : csv → several csv s

takes csv of all submissions and splits it per student,
with processing hooks

=item upload.pl : several csv s → (on gradescope)

uploads a directory of submissions (actually not necessarily csv)

=back

normal workflows go through all three,
but eg workflows with student submissions from non-gradescope
can start at F<split.pl>

=head2 lib

Perl modules

=head1 SEE ALSO

json_pp(1)

=cut
