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

use Cwd qw(abs_path);
use File::Basename qw(dirname);
use File::Spec;
# use local modules
    use lib (
        File::Spec->catdir(dirname(abs_path($0)), 'lib'),
        ); # https://stackoverflow.com/a/46550384
use Gradescope::Translate;

BEGIN{
    if($^V lt v5.36){
        require Scalar::Util;
        Scalar::Util->import(qw(reftype));
    }
    else{
        require builtin;
        warnings->import('-experimental::builtin');
        builtin->import(qw(reftype));
    }
}

pod2usage(-exitval => 0, -verbose => 2) if @ARGV;


#$config{'map submission'} = sub :prototype(\%){
#    my %submission = %{$_[0]};
#    say "[debug] submission keys: ${\(join(', ', keys %submission))}";
#    my @tests = @{JSON::from_json $submission{AG}};
#    my $gradescope_tests = [];
#    for my $t (@tests){
#        my %gradescope_test = (
#            name => $t->{name},
#            max_score => $t->{report}->{overall}->[1],
#            score => $t->{report}->{overall}->[0],
#        );
#        $gradescope_test{output} = 'see gradescope interface, not using this output right now';
#        #$gradescope_test{output} = <<~"__EOF"
#        #test_validation:
#        #    max: $t->{report}->{test_validation}->{max}
#        #    percentage: $t->{report}->{test_validation}->{percentage}
#        #    src:
#        #    $t->{report}->{test_validation}->{src}
#        #mutation_testing:
#        #    max: $t->{report}->{mutation_testing}->{max}
#        #    percentage: $t->{report}->{mutation_testing}->{percentage}
#        #    src:
#        #    $t->{report}->{mutation_testing}->{src}
#        #impl_grading:
#        #    max: $t->{report}->{impl_grading}->{max}
#        #    percentage: $t->{report}->{impl_grading}->{percentage}
#        #    src:
#        #    $t->{report}->{impl_grading}->{src}
#        #__EOF
#        ;
#        $gradescope_tests = [(@$gradescope_tests), \%gradescope_test];
#    }
#    return $gradescope_tests;
#};
my %output; # gradescope expects JSON test output
#my $s = &{$config{'map submission'}}(\%submission);
#if(!defined reftype $s){
#    say '[debug] Using top level (total) score grading';
#    $output{score} = $s;
#}
#elsif(reftype $s eq 'ARRAY'){
#    say '[debug] Using individual tests grading';
#    $output{tests} = $s;
#}
#else{
#    confess "[error] `perldoc $0` to see how 'map submission' is supposed to be used";
#}
$output{'stdout_visibility'} = 'visible'; # we shouldn't need to hide any output from this script
#$output{'output'} = '';
# test output
open(my $output_fh,
    '>:utf8',
    '/autograder/results/results.json') or confess '[error] writing output failed!';
print $output_fh JSON::to_json(\%output);

=pod

=encoding utf8

=head1 NAME

A8 multiple choice gradescope autograder

=head1 SYNOPSIS

run_test.pl

Does not take arguments

=cut
