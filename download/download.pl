#!/usr/bin/env perl

use v5.32;
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
use JSON;
use YAML::XS;
use File::Temp;

#use Translate qw(token2uniqname);
#use CurlGradescope;

pod2usage(0) if @ARGV;
# force user to fill out config
my %config = (
    'map submission' => sub :prototype($){
        confess 'need to set this';
    },
);
my @required_fields = keys %config;
# NOTE: actually set fields
$config{'map submission'} = sub :prototype($){
    return `cat $_[0]/*`;
};
grep {!defined} @config{@required_fields} and confess 'Fill out %config!';

#my $auth_token = CurlGradescope::login();
# need to download submissions zip from 'Review Graders' -> 'Export Submissions'
my $zip = './submissions.zip';
my $tmpdir = File::Temp->newdir();
`cp $zip $tmpdir && unzip -d $tmpdir ${\(File::Spec->catfile($tmpdir, basename($zip)))}`;
my $assignment_export = glob File::Spec->catfile($tmpdir, '*export');
my ($md_yaml) = YAML::XS::LoadFile(File::Spec->catfile($assignment_export, 'submission_metadata.yml'));
#say ${$md_yaml->{submission_134933508}->{':submitters'}}[0]->{':email'};
my %output;
for my $submission_id (keys %$md_yaml){
    my $email = $md_yaml->{$submission_id}->{':submitters'}->[0]->{':email'};
    $email =~ m/(\S+)\@umich\.edu/;
    my $uniqname = $1;
    my $submission_dir = File::Spec->catdir($assignment_export, $submission_id);
    $output{$uniqname} = $config{'map submission'}($submission_dir);
}
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
    out => 'file.csv',
    encoding => 'UTF-8',
}) or confess Text::CSV->error_diag;

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
