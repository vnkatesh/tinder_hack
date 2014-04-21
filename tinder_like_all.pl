#!/opt/local/bin/perl -W
use strict;
use warnings;
use Data::Dump qw(dump);
use JSON;
use LWP::UserAgent;
use Time::HiRes qw(usleep);
#use Getopt::Long;

my $XAUTHTOKEN = "xxxxxxxxxxxxxxxxxxxxxxxxxxxx"; #FILL IN YOUR VALUE HERE
my $LAST_ETAG = "-1022732152";
my $LAST_MODIFIED_SINCE = "Mon, 21 Apr 2014 04:48:31 GMT";

my $DEBUG = 1;

if($DEBUG) {
    open (DEBUGFILE, '>debug.txt');
}

#Somehow this is not being used.
my $FACEBOOK_AUTH_TOKEN = "";
my $FACEBOOK_AUTH_SECRET = "";

die if !$LAST_ETAG || !$XAUTHTOKEN || !$LAST_MODIFIED_SINCE;

#Use sigint trap to print out last set etag and if-modified-since. This should be updated in the code after every run.
$SIG{'INT'} = 'exit_handler';

#main function
while (1) {
    #Get Latest recommendations, limit by 40.
    my $json_response = &get_forty();
    if($DEBUG) {
        print DEBUGFILE "Json_response\n";
        print DEBUGFILE $json_response;
        print DEBUGFILE "\n\n";
    }
    if($json_response =~ /recs\ exhausted/ || $json_response =~ /recs\ timeout/) {
        print "Exhausted list of recommendations. Sleeping for 1800 seconds\n";
        sleep 1800;
    }
    #Strip response Json and Get array of Tinder_ids.
    my @match_ids = &strip_json($json_response);
    #Like Each of the Tinder_id, one by one
    &like_all(\@match_ids);
    #Sleep because you dont want to overwhelm the server - And is a good place to Ctrl-C
    print "Sleeping 5 seconds\n";
    sleep 5;
    undef $json_response;
    undef @match_ids;
}

sub like_all() {
    my $match_ids = shift;
    my $match_id;
    foreach $match_id (@$match_ids) {
        print "Liking tinder_id:$match_id..\n";
        &set_like_curl($match_id);
        usleep(750000);
    }
    undef $match_ids;
    undef $match_id;
}

sub set_like_curl() {
    my $match_id = shift;
    my %request_header = ();
    #Almost constant.
    $request_header{'app_version'} = "632";
    $request_header{'platform'} = "android";
    $request_header{'User-Agent'} = "Tinder Android Version 2.2.2";
    $request_header{'os_version'} = "19";
    $request_header{'Host'} = "api.gotinder.com";
    $request_header{'Connection'} = "Keep-Alive";
    $request_header{'Accept-Encoding'} = "gzip";
    $request_header{'X-Auth-Token'} = $XAUTHTOKEN;

    my %example_get_call = %{&generic_curl("1", "https://api.gotinder.com/like/$match_id",\%request_header,)};

    if($DEBUG) {
        print DEBUGFILE "set_like_curl $match_id\n";
        print DEBUGFILE $example_get_call{'response_body'};
        print DEBUGFILE "\n\n";
    }

    if(!($example_get_call{'code'} eq "0")) {
        die "set_like_curl() for $match_id failed.\n";
    }
    undef %example_get_call;
    undef %request_header;
}

sub strip_json {
    my $json_data = decode_json(shift);
    my @match_ids = ();
    my $result;
    foreach $result (@{$json_data->{'results'}}) {
        push(@match_ids, $result->{'_id'});
    }
    undef $json_data;
    undef $result;
    return @match_ids;
}

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
            undef $message;
        }
        else {
            print "HTTP GET error code: ", $resp->code, "\n";
            print "HTTP GET error message: ", $resp->message, "\n";
            $response_headers{'response_body'} = "";
            $response_headers{'code'} = "404";
        }
        undef $resp;
        undef $req;
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
            if(defined $resp->header('ETag')){
                $response_headers{'ETag'} = $resp->header('ETag');
            }
            if(defined $resp->header('Date')){
                $response_headers{'Date'} = $resp->header('Date');
            }
            undef $message;
        }
        else {
            print "HTTP POST error code: ", $resp->code, "\n";
            print "HTTP POST error message: ", $resp->message, "\n";
            $response_headers{'response_body'} = "";
            $response_headers{'code'} = "404";
        }
        undef $resp;
        undef $req;
    }
    undef $is_get;
    undef $query;
    undef $request_header;
    undef $request_body;
    undef $ua;
    return \%response_headers;
}

sub get_forty() {
    my %request_header = ();
    #Almost constant.
    $request_header{'app_version'} = "632";
    $request_header{'platform'} = "android";
    $request_header{'User-Agent'} = "Tinder Android Version 2.2.2";
    $request_header{'os_version'} = "19";
    $request_header{'Content-Type'} = "application/json; charset=utf-8";
    $request_header{'Host'} = "api.gotinder.com";
    $request_header{'Connection'} = "Keep-Alive";
    $request_header{'Accept-Encoding'} = "gzip";
    $request_header{'Content-Length'} = "12";
    $request_header{'If-None-Match'} = $LAST_ETAG;
    $request_header{'If-Modified-Since'} = $LAST_MODIFIED_SINCE;
    $request_header{'X-Auth-Token'} = $XAUTHTOKEN;

    my %example_get_call = %{&generic_curl("0", "https://api.gotinder.com/user/recs",\%request_header,"{\"limit\":40}")};

    if($example_get_call{'code'} eq "0") {
        if(defined($example_get_call{'ETag'}) && defined($example_get_call{'Date'})) {
            $LAST_ETAG = $example_get_call{'ETag'};
            $LAST_MODIFIED_SINCE = $example_get_call{'Date'};
            if($DEBUG) {
                print DEBUGFILE "Set new ETAG, LAST_MODIFIED_SINCE as $LAST_ETAG, $LAST_MODIFIED_SINCE\n";
            }
        }
        return $example_get_call{'response_body'};
    } else {
        die "get_forty() failed\n";
    }
    undef %example_get_call;
    undef %request_header;
}

sub indian_people_filter() {
    #TBD
    #Graph search 'Pages liked by women from India'
    #Graph search 'Pages liked by women from India who live in Ontario'
    #Get Page_id's of everything 'indian'
    #Filter from response.json and return specific tinder_id's
}

sub exit_handler {
    #Print final last_etag, last_modified_since. final xauthtoken
    print "\n";
    print "LAST_ETAG is $LAST_ETAG\n";
    print "LAST_MODIFIED_SINCE is $LAST_MODIFIED_SINCE\n";
    close(DEBUGFILE);
    exit 0;
}

exit 0;
