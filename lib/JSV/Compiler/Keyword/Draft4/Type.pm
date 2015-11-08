package JSV::Compiler::Keyword::Draft4::Type;
use strict;
use warnings;
use parent 'JSV::Compiler::Keyword';

use Carp qw(croak);
use JSV::Compiler::Keyword qw(:constants);

sub instance_type() { INSTANCE_TYPE_ANY(); }
sub keyword() { "type" }
sub keyword_priority() { 10; }

sub generate_code {
    my ($class, $compiler_context, $schema) = @_;

    my $keyword_value = $class->keyword_value($schema);

    # TODO: 型の判定は Keywords 共通なので先にまとめてやる

    my $pred = do {
        if ($keyword_value eq 'array') {
            q{ ref($instance) eq 'ARRAY' };
        } elsif ($keyword_value eq 'boolean') {
            q{ JSON::is_bool($instance) };
        } elsif ($keyword_value eq 'integer') {
            q{ (B::svref_2object(\$instance)->FLAGS & B::SVp_IOK) == B::SVp_IOK };
        } elsif ($keyword_value eq 'number') {
            q{ (B::svref_2object(\$instance)->FLAGS & B::SVp_NOK) == B::SVp_NOK };
        } elsif ($keyword_value eq 'null') {
            q{ ! defined($instance) };
        } elsif ($keyword_value eq 'object') {
            q{ ref($instance) eq 'HASH' };
        } elsif ($keyword_value eq 'string') {
            q{ (B::svref_2object(\$instance)->FLAGS & B::SVp_POK) == B::SVp_POK };
        } else {
            croak "unknown type: $keyword_value";
        }
    };

    return qq{
        unless ($pred) {
            \$context->log_error("instance type doesn't match schema type");
        }
    };
}

1;
