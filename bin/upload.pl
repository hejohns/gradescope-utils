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
    use builtin;
    no warnings 'experimental::builtin';
    use feature 'try';
    no warnings 'experimental::try';

    our $VERSION = version->declare('v2022.11.13');
# end prelude
use Gradescope::Translate qw(token2uniqname);
use Gradescope::Curl qw(:config baseurl https://www.gradescope.com);

my %options;
GetOptions(\%options, 'help|h|?') or pod2usage(-exitval => 1, -verbose => 2);
pod2usage(-exitval => 0, -verbose => 2) if $options{help} || @ARGV < 1;
# force user to fill out config
my %config = (
    'output dir path' => undef,
    'class id' => undef,
    'assignment id' => undef,
);
# from original python script:
#   You can get course and assignment IDs from the URL, e.g.:
#     https://www.gradescope.com/courses/1234/assignments/5678
#     course_id = 1234, assignment_id = 5678

my %token2uniqname = token2uniqname();
my $auth_token = CurlGradescope::login();
for my $t (keys %token2uniqname){
    say `curl -s -H 'access-token: $auth_token' -F 'owner_email=$token2uniqname{$t}\@umich.edu' -F 'files[]=\@$config{'output dir path'}/$t.csv' $CurlGradescope::baseurl/api/v1/courses/$config{'class id'}/assignments/$config{'assignment id'}/submissions`;
    carp "[warning] curl return code on $t: ${\($? >> 8)}" if $? >> 8;
    carp "[warning] does $config{'output dir path'}/$t.csv actually exist?" if $? >> 8;
}

=pod

=encoding utf8

=head1 NAME

upload - Gradescope submission script component

=head1 SYNOPSIS

upload.pl

Does not take arguments

=head1 DESCRIPTION

(`perldoc THIS_FILE` to see this documentation)

=head2 config

'output dir path' := path to directory of submissions created by ./gen_submissions.pl

'class id' := gradescope class id

'assignment id' := gradescope assignment id

=head1 SEE ALSO

./gen_submissions.pl

./Translate.pm

=cut
