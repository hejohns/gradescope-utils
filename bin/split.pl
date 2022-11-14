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
    # `capture_stdout` for backticks w/o shell
    use Capture::Tiny qw(:all);
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

use Gradescope::Translate qw(token2uniqname parse_header convert_header);

my %options;
GetOptions(\%options,
    'help|h|?',
    'delimiter|d=s',
    'keyheader|k=s',
    'valueheader|v=s',
    'tokenfilter=s',
    'filtered2csv=s',
    'sortkeys=s',
    'output|o=s',
    ) or pod2usage(-exitval => 1, -verbose => 2);
pod2usage(-exitval => 0, -verbose => 2) if $options{help} || @ARGV < 1;

$options{delimiter} //= ':';
$options{keyheader} //= 'token';
$options{valueheader} //= 'submission';
$options{tokenfilter} //= './grep.sh';
$options{filtered2csv} //= 'cat';
$options{sortkeys} //= './sort.pl';
$options{output} //= File::Temp->newdir();
my ($submissions) = @ARGV;
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
    parse_header($options{delimiter}, $options{keyheader}),
    parse_header($options{delimiter}, $options{valueheader})
);
my %token2uniqname = token2uniqname();
for my $t (keys %token2uniqname){
    my %filtered = $config{'submission filter for student'}(\%submissions, $t);
    my %filtered =;
    @filtered_keys = capture_stdout {
        # TODO: use IPC::Run
        system($options{tokenfilter},$t)
    }
    next if keys %filtered == 0;
    try{
        Gradescope::Translate::print_csv(, File::Spec->catfile(, "$t.csv"));
    }
    catch($e){
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
