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
        ); # https://stackoverflow.com/a/46550384

# turn on features
    use builtin qw(true false is_bool reftype);
    no warnings 'experimental::builtin';
    use feature 'try';
    no warnings 'experimental::try';

    our $VERSION = version->declare('v2023.02.13');
# end prelude

my ($token) = @ARGV;
# `cat.pl` wraps the editor state json as a json string
my $in = do {
    local $/ = undef;
    JSON::from_json <STDIN>;
};
my %in = %{JSON::from_json $in};
#my %in = %{$in};
my $tmpfile = File::Temp->new();
print $tmpfile (JSON::to_json \%in);
chdir "$ENV{HOME}/documentsNoSync/hazel-490/";
say STDERR $token;
my $report = capture_stdout {
    system('dune', 'exec', 'src/haz3lschool/gradescope.exe', $tmpfile);
}, $? >> 8 && confess "something went wrong with '$token'";
# hack
my $flag = false;
my $flag2 = false;
my @report;
for (split /\n/, $report){
    $flag = false if !$flag2 && $flag && !m/\[/;
    $flag = true if m/Finished/;
    $flag2 = true if $flag && m/\[/;
    @report = (@report, $_) if $flag && $flag2;
}
#print JSON::to_json (JSON::from_json (join "\n", @report));
my $out = JSON::from_json (join "\n", @report);
my @out = @{$out};
for my $exercise (@out){
    $exercise->{report}->{'pretty-summary'} = [split /\n/, $exercise->{report}{summary}];
}
print JSON::to_json \@out;

# PODNAME:
# ABSTRACT: Gradescope submission script component
=pod

=encoding utf8

=head1 NAME

=head1 SYNOPSIS

=head1 DESCRIPTION

=cut
