#!/usr/bin/env perl

use v5.34; # gradescope currently uses ubuntu 22.04
use utf8;
use strict;
use warnings FATAL => 'all';
use open qw(:utf8) ;
BEGIN{$diagnostics::PRETTY = 1}
use diagnostics -verbose;

use Carp;
use Carp::Assert;
use Pod::Usage;
use Text::CSV;
use JSON;

BEGIN{
    if($^V lt v5.36){
        require Scalar::Util;
        Scalar::Util->import(qw(reftype));
    }
    else{
        require builtin;
        builtin->import(qw(reftype));
    }
}

pod2usage(-exitval => 0, -verbose => 2) if @ARGV;
# force user to fill out config
my %config = (
    'submission dir path' => '/autograder/submission/',
    'submission path' => sub :prototype($){
        confess 'Need to fill this out!';
    },
    'map submission' => sub :prototype(\%){
        confess 'Need to fill this out!';
    },
    'output path' => '/autograder/results/results.json',
    'key header(s)' => undef,
    'value header(s)' => undef,
    'assignemnt name' => undef,
);
my @required_fields = keys %config;
# NOTE: actually set fields
$config{'submission path'} = sub :prototype($){
    my @files = glob "$_[0]/*.csv";
    should(@files, 1) if DEBUG;
    return $files[0];
};
$config{'map submission'} => sub :prototype(\%){
    my %submission = %{$_[0]};
    say "[debug] submission keys: ${\(join(', ', keys %submission))}";
    my @tests = @{JSON::from_json $submission{AG}};
    my $gradescope_tests = [];
    for my $t (@tests){
        my %gradescope_test = {
            name => $t->{name},
            max_score => $t->{report}->{overall}->[1],
            score => $t->{report}->{overall}->[0],
        };
        my $gradescope_test{output} = <<~"__EOF"
        test_validation:
            max: $t->{report}->{test_validation}->{max}
            percentage: $t->{report}->{test_validation}->{percentage}
            src:
            $t->{report}->{test_validation}->{src}
        mutation_testing:
            max: $t->{report}->{mutation_testing}->{max}
            percentage: $t->{report}->{mutation_testing}->{percentage}
            src:
            $t->{report}->{mutation_testing}->{src}
        impl_grading:
            max: $t->{report}->{impl_grading}->{max}
            percentage: $t->{report}->{impl_grading}->{percentage}
            src:
            $t->{report}->{impl_grading}->{src}
        __EOF
        ;
        $gradescope_tests = [(@$gradescope_tests), \%gradescope_test];
    }
};
$config{'key header(s)'} = 'uniqname';
$config{'value header(s)'} = 'submission';
$config{'assignemnt name'} => 'A1-2';
grep {!defined} @config{@required_fields} and confess 'Fill out %config!';

my %submission = %{Text::CSV::csv ({
    # attributes (OO interface)
    binary => 0,
    decode_utf8 => 0,
    strict => 1,
    # `Text::CSV::csv` arguments
    in => &{$config{'submission path'}}($config{'submission dir path'}),
    encoding => ':utf8',
    key => $config{'key header(s)'},
    value => $config{'value header(s)'},
}) or confess Text::CSV->error_diag};
my @answers = (0, 3, 1, 2, 3, 0);
#should(keys %submission, @answers) if DEBUG;

my %output; # gradescope expects JSON test output
my $s = &{$config{'map submission'}}(\%output);
if(reftype $s eq 'ARRAY'){
    say '[debug] Using individual tests grading';
    $output{tests} = $s;
}
elsif(!defined reftype $s){
    say '[debug] Using top level (total) score grading';
    $output{score} = $s;
}
else{
    confess "[error] `perldoc $0` to see how 'map submission' is supposed to be used";
}
#$output{'score'} = 0;
#for my $i (0..@answers-1){
#    my @interested = grep {m/:$i/} keys %submission;
#    #should(@interested, 1) if DEBUG;
#    if(@interested == 1 && $submission{$interested[0]} == $answers[$i]){
#        $output{'score'} += 2;
#    }
#}
$output{'stdout_visibility'} = 'visible'; # we shouldn't need to hide any output from this script
$output{'output'} = $config{'assignment name'};
# test output
open(my $output_fh,
    '>:utf8',
    $config{'output path'}) or confess 'writing output failed!';
print $output_fh JSON::to_json(\%output);

=pod

=encoding utf8

=head1 NAME

A8 multiple choice gradescope autograder

=head1 SYNOPSIS

run_test.pl

Does not take arguments

=cut
