use strict;
use warnings;

use JSON;
use Test::More;
use JSV::Compiler;

subtest "basic" => sub {
    my $compiler = JSV::Compiler->new();
    my $validator = $compiler->compile(+{ type => "object" });
    note 'compiled code: ', $validator->{validator_code};
    my $ret = $validator->validate(+{ foo => 1 });
    ok $ret or note explain $ret;
};

done_testing;

