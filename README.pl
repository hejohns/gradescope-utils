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

=head3 download.pl

Contrary to the name, doesn't actually download anything

Takes a zip of submissions from Gradescope and formats the data so gen_submissions.pl can work on it

(for non-A8 workflows)

=head3 gen_submissions.pl

Takes a single csv of all student data and parcels it up into individual student submissions for ./upload.pl

The single csv is from A8-- a sqlite dump

=head3 upload.pl

uploads all submissions output by gen_submissions.pl
(or in the correct format, since gen_submissions.pl is fairly A8 specific)

=head2 lib

=head3 Translate.pm

Handles token/uid ↦ uniqname translation

A carryover from the scripts' origins w/ A8

Just make uid = uniqname if you don't actually need uid handling

=head3 CurlGradescope.pm

Common curl stuff between scripts

=head1 SEE ALSO

json_pp(1)

=cut
