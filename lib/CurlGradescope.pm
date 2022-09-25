package CurlGradescope v0.0.0{
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
    use IO::Prompter;
    use JSON;

    our @EXPORT = qw();
    my $EXPORT_OK = <<~'__EOF'
    token2uniqname
    __EOF
    ;
    our @EXPORT_OK = split /\n+/, $EXPORT_OK,

# force user to fill out config
    my %config = (
        'gradescope url' => undef,
    );
    my @required_fields = keys %config;
# NOTE: actually set fields
    $config{'gradescope url'} = 'https://www.gradescope.com';
    grep {!defined} @config{@required_fields} and confess 'Fill out %config!';

# hacked together from the python script and a lot of netcat (thanks 489)
# aka the curl snippets took a lot of trial and error
    our $baseurl = $config{'gradescope url'};
    my $email = IO::Prompter::prompt('Enter your email: ');
    my $password = IO::Prompter::prompt('Enter your password: ', -echo => '');

    sub login : prototype(){
        my %response = %{JSON::from_json(`curl -s --data 'email=$email&password=$password' $baseurl/api/v1/user_session`)};
        carp '[warning] curl returned error code on gradescope auth' if $? >> 8;
        if(!defined $response{token}){
            confess "[error] Your login credentials are probably wrong";
        }
        carp "[debug] token_expiration_time: $response{token_expiration_time}";
        return $response{token};
    }
}
