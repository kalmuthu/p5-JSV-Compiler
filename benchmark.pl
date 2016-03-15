use strict;
use warnings;

use Benchmark qw(:all);

use JSV::Validator;
use JSV::Compiler;

my $schema = +{
    type       => "object",
    required   => [ "jsonrpc", "method" ],
    properties => {
        jsonrpc => { "enum" => [ "2.0" ] },
        method  => { "type" => "string" },
        id      => {
            type => [ "string", "number", "null" ],
        },
        params  => {
            type => [ "array", "object" ],
        },
    },
};

my $instance = +{
    jsonrpc => "2.0",
    method  => "subtract",
    params  => [42, 23],
    id      => 1,
};

my $jsv  = JSV::Validator->new();
my $jsvc = JSV::Compiler->new()->compile($schema);
print $jsvc->{validator_code};

cmpthese(-5, +{
    'JSV' => sub {
        $jsv->validate($schema, $instance);
    },
    'JSV::Compiler' => sub {
        $jsvc->validate($instance);
    },
});
