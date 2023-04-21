#!/usr/bin/env perl

my $date = $ARGV[0] // '2023-04-20'; # last manually updated time
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
(the perl scripts will use POD, which can be read with C<perldoc>, or C<./script-name --help>)

See OVERVIEW and EXAMPLES

originally a port of
L<https://github.com/eecs490/Assignment-8-Gradescope>
during W22

=head1 GETTING STARTED

First, to address a common concern:
Yes, most of the scripts are written in Perl.
But Gradescope-Utils (hereafter GU) was written with Perl-averseness and modularity in mind.
GU does I<not> presuppose Perl knowledge,
any more than most scripts out there presuppose knowledge of their implementation details.
The extensional behavior of each script should be clear enough that--
barring straight up bugs-- 
you should never need to read the source,
like how you wouldn't notice if C<cat> or C<grep> were replaced with a Perl or Haskell implementation.

So new scripts can be written however one pleases-- I (hejohns) just happen to like Perl for text scripting.
Just make the behavior obvious, and the C<--help> message sufficient.

Second, I realize that this all seems rather complicated for what should be a simple task.
But as you might expect, GU arose from a need.
That is, GU I<is> designed for a simple task.
Most scripts are a few lines-- the job is just split over so many files
so you can see how the data looks at each step,
and so you can plug in your own scripts when the need arises.

=head1 OVERVIEW

=head2 bin

The main scripts, in approximate pipeline order:

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
