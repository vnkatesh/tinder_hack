#!/opt/local/bin/perl -W
use strict;
use warnings;
use Data::Dump qw(dump);
use JSON;
use LWP::UserAgent;
use Time::HiRes qw(usleep);
#use POSIX qw(strftime);
#use Getopt::Long;
#

my $TINDER_TOKEN = "x";
my $XAUTHTOKEN = "x";
my $TINDER_ID = "x";

my $LAST_ETAG = "x";
my $LAST_MODIFIED_SINCE = "x";

die if !$TINDER_ID || !$XAUTHTOKEN || !$TINDER_TOKEN;

print "Hello all\n";

#my $json_response;
#{
#    local $/; #Enable 'slurp' mode
#    open my $fh, "<", "response.json";
#    $json_response = <$fh>;
#    close $fh;
#}

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
while (1) {
    my $json_response = &get_forty();
    print "Response\n\n".$json_response."\n\n\n\n";
    my @match_ids = &strip_json($json_response);
    print $match_ids[1]."\n";
# like_all(@match_ids);
    print "Sleeping 10 seconds\n";
    sleep 10;
    exit;
}
#
sub like_all() {
    my @match_ids = shift;
    my $match_id;
    foreach $match_id (@match_ids) {
        #set_like_curl($match_id);
        usleep(750);
    }
}

sub generic_curl() {
    my $is_get = shift;
    my $query = shift;
    my $request_header = shift;
    my $request_body = shift;
    my $ua = LWP::UserAgent->new;
    $ua->timeout(30);

    my %response_headers = ();

    print ref($request_header)."\n";
    print dump($request_header)."\n";

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

sub get_forty() {
    my %request_header = ();
    $request_header{'app_version'} = "632";
    $request_header{'platform'} = "android";
    $request_header{'User-Agent'} = "Tinder Android Version 2.2.2";
    $request_header{'os_version'} = "19";
    $request_header{'Content-Type'} = "application/json; charset=utf-8";
    $request_header{'Host'} = "api.gotinder.com";
    $request_header{'Connection'} = "Keep-Alive";
    $request_header{'Accept-Encoding'} = "gzip";
    $request_header{'Content-Length'} = "12";
    #check below TBD
    $request_header{'X-Auth-Token'} = "3680d5b4-9c7b-4b52-baef-05053b743d61";
    $request_header{'If-None-Match'} = "-1300089360";
    $request_header{'If-Modified-Since'} = "Sat, 19 Apr 2014 22:54:17 GMT+00:00";
    my %example_get_call = %{&generic_curl("0", "https://api.gotinder.com/user/recs",\%request_header,"{\"limit\":40}")};

    if($example_get_call{'code'} eq "0") {
        return $example_get_call{'response_body'};
    } else {
        die "get_forty() failed\n";
    }
}
#
# #set_like_curl and get_forty both use generic_curl
#
exit 0;
