#!/usr/bin/env perl

my $date = $ARGV[0] // '2023-02-14'; # last manually updated time
my $version = $ARGV[1];
my @args = (
    "--name='README'",
    "--date='$date'",
    "--center='EECS 490 Gradescope Utilities'",
    "--release='$version'",
);
exec 'bash', '-c', "pod2man @args $0 | man -l -" or print STDERR "Is bash installed?: $!\n";

=pod

=encoding utf8

=head1 NAME

EECS 490 Gradescope Utilities

=head1 DESCRIPTION

Collection of scripts for gradescope stuff

Each file should contain its own documentation
(the perl scripts will use POD, which can be read with I<perldoc>, or C<./script-name --help>)

Below is just an overview

originally a port of
L<https://github.com/eecs490/Assignment-8-Gradescope>
during W22

=head2 bin

The main scripts, in pipeline order:

=over 4

=item join.pl : zip -> (json, json)

I<csv> is single csv of all submissions

returns a I<json> pair, (token2uniqname, submissions),
where submissions is keyed by token

Intended for converting a Gradescope submissions export into I<json>

=item csv2json : csv -> json

C<Text::CSV> wrapper that converts csv to key-value

Intended for converting a I<csv> token2uniqname into I<json>,
as an initial step for F<split.pl>

=item split.pl : (json, csv) -> json

Takes token2uniqname I<json> and splits I<csv> into I<json> key-value,
keyed by token

Intended for processing a I<csv> database dump

=item map.pl : json -> json

This is where ``the real" processing is hooked in

=item upload.pl : (json, json) -> ()

Takes a I<json> pair, (token2uniqname, submissions),
and uploads to Gradescope

=item proj.pl : json -> json

0-indexed json array projection

=back

=head3 bundled lambdas

=over 4

=item field-n-eq?.pl : TODO

split.pl

=back

=head3 misc utilities

=over 4

=item grep.pl : (json kv, regex) -> json kv

=back

=head2 lib

Perl modules

=head2 git submodules

related scripts in other git repositories

=head3 gradescope-late-days

=head1 DEPENDENCIES

non-exhaustive list of external programs

=head2 runtime

unzip(1), curl(1), bat(1)

=head2 build

dzil(1)

=head1 SEE ALSO

json_pp(1)

=cut
