#!/opt/local/bin/perl -W
use strict;
use warnings;
use Data::Dump qw(dump);
use JSON;
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
# sub generic_curl(is_get, query, header, body) {
#       #do_magic
#       return response_body;
# }
#
# #set_like_curl and get_forty both use generic_curl
#
exit 0;
