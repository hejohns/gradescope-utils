#!/usr/bin/env perl

use v5.34;
use utf8;
use strict;
use warnings FATAL => 'all';
use open qw(:utf8) ;
BEGIN{$diagnostics::PRETTY = 1}
use diagnostics -verbose;

use Cwd qw(abs_path);
use File::Basename qw(basename dirname);
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
use YAML::XS;
use File::Temp;
use JSON;

pod2usage(-exitval => 0, -verbose => 2) if @ARGV;
# force user to fill out config
my %config = (
    'submissions zip path' => undef,
    'map submission' => sub :prototype($){
        confess 'need to set this';
    },
    'submission csv path' => undef,
    'token2uniqname csv path' => undef,
);
my @required_fields = keys %config;
# NOTE: actually set fields
$config{'submissions zip path'} = "$ENV{HOME}/Downloads/a1-submissions.zip";
$config{'map submission'} = sub :prototype($){
    #return `cat $_[0]/*`;
    my $cat = `cat $_[0]/*`;
    #return JSON::to_json { one => $cat, two => 'foobar'};
    # check json is valid
    return JSON::to_json (JSON::from_json $cat);
};
$config{'submission csv path'} = "$ENV{HOME}/Downloads/data.csv";
$config{'token2uniqname csv path'} = "$ENV{HOME}/Downloads/token2uniqname.csv";
grep {!defined} @config{@required_fields} and confess 'Fill out %config!';

if(-e $config{'submission csv path'}){
    confess 'submission csv path already exists!';
}
if(-e $config{'token2uniqname csv path'}){
    confess 'token2uniqname csv path already exists!';
}
my $zip = $config{'submissions zip path'};
my $tmpdir = File::Temp->newdir();
`cp $zip $tmpdir && unzip -d $tmpdir ${\(File::Spec->catfile($tmpdir, basename($zip)))}`;
my $assignment_export = glob File::Spec->catfile($tmpdir, '*export');
my ($md_yaml) = YAML::XS::LoadFile(File::Spec->catfile($assignment_export, 'submission_metadata.yml'));
my %output; # uniqname ↦ submission perl hash accumulator
for my $submission_id (keys %$md_yaml){
    my $email = $md_yaml->{$submission_id}->{':submitters'}->[0]->{':email'};
    $email =~ m/(\S+)\@umich\.edu/;
    my $uniqname = $1;
    my $submission_dir = File::Spec->catdir($assignment_export, $submission_id);
    $output{$uniqname} = $config{'map submission'}($submission_dir);
}
# dump %output to csv
my @aoa = (['uniqname', 'submission']);
for my $k (keys %output){
    @aoa = (@aoa, [$k, $output{$k}]);
}
Text::CSV::csv({
    # attributes (OO interface)
    binary => 0,
    decode_utf8 => 0,
    strict => 1,
    # `csv` arguments
    in => \@aoa,
    out => $config{'submission csv path'},
    encoding => ':utf8',
}) or confess Text::CSV->error_diag;
# generate trivial token2uniqname
@aoa = (['token', 'uniqname']);
for my $k (keys %output){
    @aoa = (@aoa, [$k, $k]);
}
Text::CSV::csv({
    # attributes (OO interface)
    binary => 0,
    decode_utf8 => 0,
    strict => 1,
    # `csv` arguments
    in => \@aoa,
    out => $config{'token2uniqname csv path'},
    encoding => ':utf8',
}) or confess Text::CSV->error_diag;

=pod

=encoding utf8

=head1 NAME

download - Gradescope submission script component

=head1 SYNOPSIS

download.pl

Does not take arguments

=head1 DESCRIPTION

(`perldoc THIS_FILE` to see this documentation)

This script actually doesn't download anything-- you have to do that through the gradescope web interface

It only collates the zip for gen_submissions.pl and the other scripts

=head2 config

'submissions zip path' := path to submissions zip, from 'Review Graders' -> 'Export Submissions'

TODO: what return types does this script/Text::CSV::csv actually support?

'map submission' := takes path to dir of student's submission, returns a scalar for the "real" data

'submission csv path' := output path for csv of submissions

'token2uniqname csv path' := output path for csv for Translate.pm

=head1 SEE ALSO

./gen_submissions.pl

./upload.pl

=cut
