package Gradescope::Translate v2022.12.30 {
    use v5.36;
    use utf8;
    use strictures 2; # nice `use strict`, `use warnings` defaults
    use open qw(:utf8); # try to use Perl's internal Unicode encoding for everything
    BEGIN{$diagnostics::PRETTY = 1} # a bit noisy, but somewhat informative
    use diagnostics -verbose;

    # turn on features
        use builtin qw(true false is_bool reftype);
        no warnings 'experimental::builtin';
        use feature 'try';
        no warnings 'experimental::try';
    # end prelude
    use Carp;
    use Carp::Assert;
    use Text::CSV;
    use JSON;
    use File::Slurp;

    use parent qw(Exporter);

    # default exports
    our @EXPORT = qw();
    # optional exports
    our @EXPORT_OK = qw(
        print_csv
        read_csv
    );

    sub print_csv {
        my ($in, $out) = @_;
        Text::CSV::csv({
            # attributes (OO interface)
            binary => 0,
            decode_utf8 => 0,
            strict => 1,
            # `csv` arguments
            in => $in,
            out => $out,
            encoding => ':utf8',
        }) or confess Text::CSV->error_diag;
    }

    sub read_csv {
        my ($csv_path, $key_header, $value_header, $filter) = @_;
        $filter //= sub {true};
        my %kv = %{Text::CSV::csv ({
            # attributes (OO interface)
            binary => 0,
            decode_utf8 => 0,
            strict => 1,
            # `csv` arguments
            in => $csv_path,
            filter => $filter,
            encoding => 'UTF-8',
            key => $key_header,
            value => $value_header,
        }) or confess Text::CSV->error_diag};
        return %kv;
    }

}

=pod

=encoding utf8

=head1 NAME

Translate - Gradescope submission script component

=head1 DESCRIPTION

(`perldoc THIS_FILE` to see this documentation)

Handles token ↦ uniqname translation
by just calling Text::CSV::csv basically

This script was originally written for the A8 rust assignment, which stored student submissions by a unique identifier token.
When submitting to gradescope, the identifier needed to be translated to the corresponding uniqname.

=head2 config

'token,uniqname path' := path to csv with header "token,uniqname"

'token header' := name of token header (was "token" on learnocaml)

'uniqname header' := name of uniqname header (was "nickname" on learnocaml)

=head1 SEE ALSO

./gen_submissions.pl

./upload.pl

=cut
