package JSV::Compiler::Keyword::Draft4::Type;
use strict;
use warnings;
use parent 'JSV::Compiler::Keyword';

use Carp qw(croak);
use JSV::Compiler::Keyword qw(:constants);

sub instance_type() { INSTANCE_TYPE_ANY(); }
sub keyword() { 'type' }
sub keyword_priority() { 10; }

sub generate_code {
    my ($class, $compiler_context, $schema) = @_;

    my $keyword_value = $class->keyword_value($schema);

    if (ref($keyword_value) eq 'ARRAY') {
        my $pred = join '||', map {
            '(' . $class->generate_singular_type_pred($compiler_context, $_) . ')'
        } @$keyword_value;
        return qq{
            unless ($pred) {
                \$context->log_error("instance type doesn't match schema type list");
            }
        };
    } else {
        my $pred = $class->generate_singular_type_pred($compiler_context, $keyword_value);
        return qq{
            unless ($pred) {
                \$context->log_error("instance type doesn't match schema type");
            }
        };
    }
}

# TODO: 型の判定は Keywords 共通なので先にまとめてやる
sub generate_singular_type_pred {
    my ($class, $compiler_context, $schema_type) = @_;

    return do {
        if ($schema_type eq 'array') {
            q{ ref($instance) eq 'ARRAY' };
        } elsif ($schema_type eq 'boolean') {
            q{ JSON::is_bool($instance) };
        } elsif ($schema_type eq 'integer') {
            q{ (B::svref_2object(\$instance)->FLAGS & B::SVp_IOK) == B::SVp_IOK };
        } elsif ($schema_type eq 'number') {
            q{ ((B::svref_2object(\$instance)->FLAGS & B::SVp_NOK) == B::SVp_NOK ||
                (B::svref_2object(\$instance)->FLAGS & B::SVp_IOK) == B::SVp_IOK) };
        } elsif ($schema_type eq 'null') {
            q{ ! defined($instance) };
        } elsif ($schema_type eq 'object') {
            q{ ref($instance) eq 'HASH' };
        } elsif ($schema_type eq 'string') {
            q{ (B::svref_2object(\$instance)->FLAGS & B::SVp_POK) == B::SVp_POK };
        } else {
            croak "unknown type: $schema_type";
        }
    };
}

1;
