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
use Data::Dumper;

use Gradescope::Translate qw(token2uniqname);

my %options;
GetOptions(\%options,
    'help|h|?',
    'delimiter|d=s',
    'keyheader|k=s@',
    'valueheader|v=s@',
    'tokenfilter=s@',
    'filtered2json=s@',
    'sortkeys=s@',
    'output|o=s',
    'timeout|t=s', # uses `timeout(1)` values
    'debug',
    ) or pod2usage(-exitval => 1, -verbose => 2);
pod2usage(-exitval => 0, -verbose => 2) if $options{help} || @ARGV < 2;

$options{delimiter} //= ':';
$options{keyheader} //= ['token'];
$options{valueheader} //= ['submission'];
$options{tokenfilter} //= ['./grep.sh'];
$options{filtered2json} //= ['tee'];
$options{sortkeys} //= ['./sort.pl'];
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
carp Data::Dumper::Dumper(\%submissions) if $options{debug};
my %token2uniqname = token2uniqname($token2uniqname);
for my $token (keys %token2uniqname){
    carp "[debug] token = $token" if $options{debug};
    try{
        my ($filtered) = capture_stdout {
            IPC::Run::run [@{$options{tokenfilter}}, $token], '<', \(JSON::to_json(\%submissions))
        };
        my %filtered = %{JSON::from_json $filtered}; # error checking
        carp '[debug] %filtered = ' if $options{debug};
        carp Data::Dumper::Dumper(\%filtered) if $options{debug};
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
        carp Data::Dumper::Dumper(\%simple_json) if $options{debug};
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

split.pl [options] submissions

does B<not> support -

=head1 DESCRIPTION

=cut
