#!/usr/bin/env perl

use v5.32;
use utf8;
use strict;
use warnings FATAL => 'all';
use open qw(:utf8) ;
BEGIN{$diagnostics::PRETTY = 1}
use diagnostics -verbose;

use Cwd qw(abs_path);
use File::Basename qw(dirname);
use File::Spec;
use lib (
    dirname(abs_path($0)),
    abs_path(File::Spec->rel2abs('../lib/', dirname(abs_path($0)))),
    ); # https://stackoverflow.com/a/46550384
use Carp;
use Carp::Assert;
use Pod::Usage;
use File::Slurp;
use Text::CSV;
use JSON;

use Translate qw(token2uniqname);

pod2usage(0) if @ARGV;
# force user to fill out config
my %config = (
    'output dir path' => undef,
    'class id' => undef,
    'assignment id' => undef,
);
my @required_fields = keys %config;
# NOTE: actually set fields
$config{'output dir path'} = 'output';
# from original python script:
#   You can get course and assignment IDs from the URL, e.g.:
#     https://www.gradescope.com/courses/1234/assignments/5678
#     course_id = 1234, assignment_id = 5678
$config{'class id'} = 447138;
$config{'assignment id'} = 2274401;
grep {!defined} @config{@required_fields} and confess 'Fill out %config!';

my %token2uniqname = token2uniqname();
# hacked together from the python script and a lot of netcat (thanks 489)
# aka the curl snippets took a lot of trial and error
my $baseurl = 'https://www.gradescope.com';
my $email = IO::Prompter::prompt('Enter your email: ');
my $password = IO::Prompter::prompt('Enter your password: ', -echo => '');
my %response = %{JSON::from_json(`curl -s --data 'email=$email&password=$password' $baseurl/api/v1/user_session`)};
say STDERR '[warning] ???' if $? >> 8;
if(!defined $response{token}){
    confess "[error] Your login credentials are probably wrong";
}
for my $t (keys %token2uniqname){
    say `curl -s -H 'access-token: $response{token}' -F 'owner_email=$token2uniqname{$t}\@umich.edu' -F 'files[]=\@$config{'output dir path'}/$t.csv' $baseurl/api/v1/courses/$config{'class id'}/assignments/$config{'assignment id'}/submissions`;
    say STDERR "[warning] curl return code on $t: ${\($? >> 8)}" if $? >> 8;
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
