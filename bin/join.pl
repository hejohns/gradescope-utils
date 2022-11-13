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
    use feature 'try';
    no warnings 'experimental::try';

    our $VERSION = version->declare('v2022.11.13');
# end prelude

my %options;
GetOptions(\%options, 'help|h|?', 'fun|lambda|f|λ=s', 'token2uniqname|t2u=s') or pod2usage(-exitval => 1, -verbose => 2);
pod2usage(-exitval => 0, -verbose => 2) if $options{help} || @ARGV < 1;

$options{fun} //= 'cat.pl';
my ($submissions_zip) = @ARGV;
assert(defined($submissions_zip));
$submissions_zip = abs_path($submissions_zip);
my $tmpdir = File::Temp->newdir();
capture_stdout {
    system('cp', $submissions_zip, $tmpdir)
}, $? >> 8 && confess;
capture_stdout {
    system('unzip', '-d', $tmpdir, File::Spec->catfile($tmpdir, basename($submissions_zip)))
}, $? >> 8 && confess;
my $assignment_export = glob File::Spec->catfile($tmpdir, 'assignment*export');
my %md_yaml = %{(YAML::XS::LoadFile(File::Spec->catfile($assignment_export, 'submission_metadata.yml')))[0]};
my %output; # uniqname ↦ submission perl hash accumulator
for my $submission_id (keys %md_yaml){
    use Email::Address::XS (); # use an actual email address parser instead of regex
    # NOTE: I think submitters/email isn't actually who submitted, but the name/email associated w/ the submission's student
    # (that is, if I upload for a student, the email is still the student's email)
    my $email = $md_yaml{$submission_id}->{':submitters'}->[0]->{':email'};
    my $uniqname = Email::Address::XS->new(address => $email)->user();
    my $submission_dir = File::Spec->catdir($assignment_export, $submission_id);
    my ($submission) = capture_stdout {
        system($options{fun}, $submission_dir);
    };
    $? >> 8 && carp "[error] problem with $submission_id; skipping…";
    $output{$uniqname} = $submission;
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
    out => *STDOUT,
    encoding => ':utf8',
}) or confess Text::CSV->error_diag;
if (defined $options{token2uniqname}){
    $options{token2uniqname} = abs_path($options{token2uniqname});
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
        out => $options{token2uniqname},
        encoding => ':utf8',
    }) or confess Text::CSV->error_diag;
}

=pod

=encoding utf8

=head1 NAME

join.pl - Gradescope submission script component

=head1 SYNOPSIS

join.pl [options] gradescope_export_submissions_zip

=head1 DESCRIPTION

=head1 OPTIONS

=head2 help|h|?

=head2 fun|lambda|f|λ

=head2 token2uniqname|t2u=s

=cut
