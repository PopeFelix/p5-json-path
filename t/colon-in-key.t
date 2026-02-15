use Test2::V1 -ipP;
use JSON::Path              qw/jpath/;
use JSON::MaybeXS           qw/decode_json/;
use Test2::Tools::Exception qw/lives try_ok/;

subtest simple => sub {
    my $json_string = q(
        {
            "key:one": "value1",
            "key:2": "value2",
            ":keythree": "value3"
        }
    );
    my $data_ref = decode_json($json_string);
    for my $key ( keys %{$data_ref} ) {
        my $expr = sprintf q($['%s']), $key;
        try_ok {
            my $expected = $data_ref->{$key};
            my ($got) = jpath( $data_ref, $expr, debug => $ENV{'DEBUG_TOKENIZER'} ); 
            is($got, $expected, qq("$expr") );
        };
    }
};

subtest 'not so simple' => sub {
    my $json_string = q(
        {
          "key1": [
            {
              ":key2:test": {
                "parameters": "desired_value"
              }
            }
          ]
        }
    );

    my $data_ref = decode_json($json_string);
    my $expr = q($['key1'][0][':key2:test']); 
    my $got = jpath($data_ref,  $expr);
    my $expected = $data_ref->{'key1'}[0]{':key2:test'};
    is($got, $expected, qq("$expr"));
    done_testing;
};
done_testing;