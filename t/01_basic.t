use strict;
use warnings;

use JSON;
use Test::More;
use JSV::Compiler;

subtest "basic" => sub {
    my $compiler = JSV::Compiler->new();
    my $validator = $compiler->compile(+{
        type       => "object",
        properties => {
            "foo" => {
                type => "number",
                enum => [1, 2],
            },
        },
        required   => ['foo'],
    });
    note 'compiled code: ', $validator->{validator_code};
    my $ret = $validator->validate(+{ foo => 1 });
    ok $ret or note explain $ret;
};

subtest "reference" => sub {
    my $compiler = JSV::Compiler->new();
    $compiler->register_schema('http://example.com/sample.json', +{
        definitions => +{
            foo => +{
                type => "number",
                enum => [1, 2],
            },
        },
    });
    my $validator = $compiler->compile(+{
        type       => "object",
        properties => {
            "foo" => {
                '$ref' => 'http://example.com/sample.json#/definitions/foo',
            },
        },
        required   => ['foo'],
    });
    note 'compiled code: ', $validator->{validator_code};
    my $ret = $validator->validate(+{ foo => 1 });
    ok $ret or note explain $ret;
};

done_testing;

