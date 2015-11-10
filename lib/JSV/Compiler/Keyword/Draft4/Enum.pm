package JSV::Compiler::Keyword::Draft4::Enum;
use strict;
use warnings;
use parent 'JSV::Compiler::Keyword';

use Carp qw(croak);
use JSV::Compiler::Keyword qw(:constants);
use JSV::Compiler::Util qw(to_perl_literal);

sub instance_type() { INSTANCE_TYPE_ANY(); }
sub keyword() { 'enum' }
sub keyword_priority() { 10; }

sub generate_code {
    my ($class, $compiler_context, $schema) = @_;

    my $enum = $class->keyword_value($schema);
    my $enum_literal = join ',', map { to_perl_literal($compiler_context->json->encode($_)) } @$enum;

    return qq[
        my \$instance_as_json = \$context->{json}->encode(\$instance);
        my \$matched_idx = firstidx { \$instance_as_json eq \$_ } ($enum_literal);
        if (\$matched_idx == -1) {
            \$context->log_error("The instance value does not be included in the enum list");
        }
    ];
}

1;
