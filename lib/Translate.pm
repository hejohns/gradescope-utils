package Translate v0.0.0{
    use v5.32;
    use utf8;
    use strict;
    use warnings FATAL => 'all';
    use open qw(:utf8) ;
    BEGIN{$diagnostics::PRETTY = 1}
    use diagnostics -verbose;
    use parent qw(Exporter);

    use Carp;
    use Carp::Assert;
    use Text::CSV;

    our @EXPORT = qw();
    my $EXPORT_OK = <<~'__EOF'
    token2uniqname
    __EOF
    ;
    our @EXPORT_OK = split /\n+/, $EXPORT_OK,

# force user to fill out config
    my %config = (
        'token,uniqname path' => undef,
        'token header' => undef,
        'uniqname header' => undef,
    );
    my @required_fields = keys %config;
# NOTE: actually set fields
    $config{'token,uniqname path'} = '../bin/token2uniqname.csv';
    $config{'token header'} = 'token';
    $config{'uniqname header'} = 'uniqname';
    grep {!defined} @config{@required_fields} and confess 'Fill out %config!';

    my %token2uniqname = %{Text::CSV::csv ({
        # attributes (OO interface)
        binary => 0,
        decode_utf8 => 0,
        strict => 1,
        # `csv` arguments
        in => $config{'token,uniqname path'},
        encoding => 'UTF-8',
        key => $config{'token header'},
        value => $config{'uniqname header'},
    }) or confess Text::CSV->error_diag};

    sub token2uniqname : prototype(){
        return %token2uniqname;
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
