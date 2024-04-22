# Parses and evaluates tests in the JSONPath Compliance Test Suite

package CTSParser;
$CTSParser::VERSION = '1.0';
use strict;
use warnings;

use JSON::MaybeXS qw/decode_json/;

my $CTS;

sub load_cts {


