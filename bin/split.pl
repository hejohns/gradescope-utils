#!/usr/bin/env perl

use v5.36;
use utf8;
use strictures 2; # nice `use strict`, `use warnings` defaults
use open qw(:utf8); # try to use Perl's internal Unicode encoding for everything
BEGIN{$diagnostics::PRETTY = 1} # a bit noisy, but somewhat informative
use diagnostics -verbose;

# Carp
    use Carp;
    use Carp::Assert;
# filepath functions
    use Cwd qw(abs_path);
    use File::Basename qw(basename dirname);
    use File::Spec;
# misc file utilities
    use File::Temp;
    use File::Slurp;
    use Text::CSV;
    use JSON;
    use YAML::XS;
# misc scripting IO utilities
    use IO::Prompter;
    # `capture_stdout` for backticks w/o shell (escaping issues)
    use Capture::Tiny qw(:all);
    # for more complicated stuff
    # eg timeout, redirection
    use IPC::Run;
# option/arg handling
    use Getopt::Long qw(:config gnu_getopt auto_version); # auto_help not the greatest
    use Pod::Usage;
# use local modules
    use lib (
        dirname(abs_path($0)),
        abs_path(File::Spec->rel2abs('../lib/', dirname(abs_path($0)))),
        ); # https://stackoverflow.com/a/46550384

# turn on features
    use builtin qw(true false is_bool reftype);
    no warnings 'experimental::builtin';
    use feature 'try';
    no warnings 'experimental::try';

    our $VERSION = version->declare('v2022.11.13');
# end prelude
use Data::Printer;

use Gradescope::Translate qw(token2uniqname);

my %options;
GetOptions(\%options,
    'help|h|?',
    'delimiter|d=s',
    'keyheader|k=s@',
    'valueheader|v=s@',
    'tokenfilter|t=s@',
    'filtered2json|f=s@',
    'sortkeys|s=s@',
    'output|o=s',
    'timeout=s', # uses `timeout(1)` values
    'debug',
    'tokenheader=s',
    'uniqnameheader=s',
    ) or pod2usage(-exitval => 1, -verbose => 2);
pod2usage(-exitval => 0, -verbose => 2) if $options{help} || @ARGV < 2;

$options{delimiter} //= ':';
$options{keyheader} //= ['token'];
$options{valueheader} //= ['submission'];
$options{tokenfilter} //= ['cat'];
$options{filtered2json} //= ['cat'];
$options{sortkeys} //= ['true'];
$options{output} //= File::Temp->newdir(CLEANUP => 0);
$options{timeout} //= '30s';
$options{keyheader} = [$options{delimiter}, @{$options{keyheader}}];

my ($submissions, $token2uniqname) = @ARGV;
$submissions = *STDIN if $submissions eq '-';
if(-e $options{output}){
    if(-d _){
        confess 'nonempty dir!' if @{File::Slurp::read_dir($options{output})};
    }
    else{
        confess 'something else already there!';
    }
}
else{
    mkdir $options{output} or confess "couldn't create output dir!";
}
my %submissions = Gradescope::Translate::read_csv($submissions,
    $options{keyheader}, $options{valueheader});
carp '[debug] %submissions = ' if $options{debug};
p %submissions if $options{debug};
my %token2uniqname = token2uniqname($token2uniqname, $options{tokenheader}, $options{uniqnameheader});
for my $token (keys %token2uniqname){
    carp "[debug] token = $token" if $options{debug};
    try{
        my ($filtered) = capture_stdout {
            IPC::Run::run [@{$options{tokenfilter}}, $token], '<', \(JSON::to_json(\%submissions))
        };
        my %filtered = %{JSON::from_json $filtered}; # error checking
        carp '[debug] %filtered = ' if $options{debug};
        p %filtered if $options{debug};
        next if keys %filtered == 0; # some students may not have submissions
        my ($simple_json) = capture_stdout { # use `timeout(1)` for portability
            # properly escape headers in case they contain delimiters
            my $keyheader;
            my $valueheader;
            Gradescope::Translate::print_csv(
                [[@{$options{keyheader}}[1 .. $#{$options{keyheader}}]]],
                \$keyheader);
            Gradescope::Translate::print_csv(
                [$options{valueheader}],
                \$valueheader);
            # chomp, but CLRF
            # https://stackoverflow.com/a/15735143
            $keyheader =~ s/\r?\n\z//;
            $valueheader =~ s/\r?\n\z//;
            IPC::Run::run [('timeout',
                    '--kill-after',
                    $options{timeout} =~ s/(\d+)/$1 + 5/er, # TODO: idk how long to wait
                    $options{timeout}),
                (@{$options{filtered2json}},
                    $token,
                    $keyheader,
                    $valueheader)
            ], '<', \(JSON::to_json \%filtered);
            $? >> 8 && die;
        };
        my %simple_json = %{JSON::from_json $simple_json};
        carp '[debug] %simple_json = ' if $options{debug};
        p %simple_json if $options{debug};
        # TODO: use sortkeys
        my @sorted_keys = sort {
            capture_stdout {
                system(@{$options{sortkeys}}, $a, $b)
            };
            confess "`@{$options{sortkeys}}` failed to exec" if $? == -1;
            $? >> 8 ? -1 : 1
        } keys %simple_json;
        my @aoa = (['key', 'value']);
        @aoa = (@aoa, [$_, $simple_json{$_}]) for @sorted_keys;
        Gradescope::Translate::print_csv(\@aoa,
            File::Spec->catfile($options{output}, "$token.json"));
    }
    catch($e){
        carp "[warning] problem with $token: $e; skipping…"
    }
}

say $options{output};

=pod

=encoding utf8

=head1 NAME

split.pl - Gradescope submission script component

=head1 SYNOPSIS

split.pl [options] I<submissions> I<token2uniqname>

split.pl [-d ':' -k token -k problem_id -v score] [-t ./grep.pl -f ./simple.pl] submissions.csv token2uniqname.csv

=head1 DESCRIPTION

splits up the I<submissions> csv
into individual chunks for upload

can also be used without first using join,
eg when the submissions are dumped from a sqlite database

note: this is the most complicated script component

=head1 OPTIONS

all commands follow the format of F<./join.pl>
(from perl's Getopt::Long, like C<cc -I>)

see C<perldoc ./join.pl> for details

=head2 help|h|?

=head2 debug

will be helpful for figuring out exactly what
tokenfilter and filtered2json need to do

various stages are dumped with perl's Data::Printer

see B<internal details> below

=head2 delimiter|d

=head2 keyheader|k

=head2 valueheader|v

keyheader and valueheader will be passed to perl's Text::CSV
to convert I<submissions> to a key-value

this may require joining multiple csv columns for the key,
so a delimiter may be specified.
the specific delimiter shouldn't matter-- see filtered2json

=head2 tokenfilter|t

command will be
fed I<submissions> as json through stdin,
and passed an additional argument:
a student's token

command is expected to output the filtered subset of I<submissions>
for the student,
as key-value, as json

see filtered2json for an example

=head3 bundled lambdas

=over 4

=item F<./grep.pl>

greps the keys for those that match C</token/>
(ie that contain the token)

=back

=head2 filtered2json|f

command will be
fed the filtered submission key-value as json through stdin,
and passed three additional arguments:
the student's token,
the key headers-- joined, but properly escaped so they can be reparsed as a csv line if needed--,
and the value headers-- ditto

command is expected to output the data for upload, as key-value, as json

eg C<./split.pl -f ./simple.pl …>
will effectively do C<cat filtered_submission.json | ./simple.pl token keyheader valueheader>
and expect json stdout

command will be called with a timeout,
so no need to have the command time itself out

=head3 bundled lambdas

=over 4

=item F<./simple.pl>

assumes valueheader is a single column header
and just reprints the filtered submission
for valueheader

=item F<./hazel.pl>

TODO: the dune exec stuff that Yuchen wrote

=back

=head1 relevant internal details

the pipeline looks like this:

[keyheader valueheader] : csv → json

tokenfilter : json → json

filtered2json : json → simple json

[unnamed] : simple json → csv

"csv" uses perl's Text::CSV,
and represents the sheet as an array of arrays (aoa)--
but we usually directly parse to a perl hash (of hash)

"json" uses perl's JSON,
and fairly faithfully encodes perl's hash

"simple json" refers to the fact that the output of filtered2json
needs to be key-value with plain string values (hash of plain values)

if more complex perl data structures leak through,
like a hash of hash,
you'll see HASH(0x*) (or ARRAY(0x*) for hash of array) in the final csv output

=cut
