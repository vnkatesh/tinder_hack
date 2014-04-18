#!/opt/local/bin/perl -W
use strict;
use warnings;
use Data::Dump qw(dump);
use JSON;
use LWP::UserAgent;
#use POSIX qw(strftime);
#use Getopt::Long;
#

my $TINDER_TOKEN = "x";
my $XAUTHTOKEN = "x";
my $TINDER_ID = "x";

die if !$TINDER_ID || !$XAUTHTOKEN || !$TINDER_ID;

print "Hello all\n";

my $json_response;
{
    local $/; #Enable 'slurp' mode
    open my $fh, "<", "response.json";
    $json_response = <$fh>;
    close $fh;
}
my @match_ids = &strip_json($json_response);
print $match_ids[1]. "\n";

my %example_get_call = %{&generic_curl("1", "http://venkatesh.ca/",,)};

if($example_get_call{'code'} eq "0") {
    print $example_get_call{'response_body'}."\n";
}

sub strip_json {
    my $json_data = decode_json(shift);
    my @match_ids = ();
    my $result;
    foreach $result (@{$json_data->{'results'}}) {
        push(@match_ids, $result->{'_id'});
    }
    return @match_ids;
}
##
# while (true) {
# $json_response = get_forty();
# @match_ids = strip_json($json_response);
# like_all(@match_id);
# print sleeping;
# sleeping 2 seconds
# }
#
# sub like_all(@match_ids) {
#   foreach($match_id in @match_ids) {
#       set_like_curl($match_id);
#       sleep 750ms;
#   }
# }
#
sub generic_curl() {
    my $is_get = shift;
    my $query = shift;
    my $request_header = shift;
    my $request_body = shift;
    my $ua = LWP::UserAgent->new;
    $ua->timeout(30);

    my %response_headers = ();

    if($is_get eq "1") {
        my $req = HTTP::Request->new(GET => $query);
        foreach (keys %{$request_header}) { 
            $req->header($_ => $request_header->{$_});
        }
        my $resp = $ua->request($req);
        if ($resp->is_success) {
            my $message = $resp->decoded_content;
            $response_headers{'response_body'} = $message;
            $response_headers{'code'} = "0";
            #print dump($resp->headers())."\n";
        }
        else {
            print "HTTP GET error code: ", $resp->code, "\n";
            print "HTTP GET error message: ", $resp->message, "\n";
            $response_headers{'response_body'} = "";
            $response_headers{'code'} = "404";
        }
    } else {
        #post
        my $req = HTTP::Request->new(POST => $query);
        foreach (keys %{$request_header}) { 
            $req->header($_ => $request_header->{$_});
        }
        $req->content($request_body);
        my $resp = $ua->request($req);
        if ($resp->is_success) {
            my $message = $resp->decoded_content;
            $response_headers{'response_body'} = $message;
            $response_headers{'code'} = "0";
        }
        else {
            print "HTTP POST error code: ", $resp->code, "\n";
            print "HTTP POST error message: ", $resp->message, "\n";
            $response_headers{'response_body'} = "";
            $response_headers{'code'} = "404";
        }
    }
    return \%response_headers;
}
#
# #set_like_curl and get_forty both use generic_curl
#
exit 0;
