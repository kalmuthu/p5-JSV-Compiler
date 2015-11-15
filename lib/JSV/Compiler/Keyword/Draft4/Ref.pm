package JSV::Compiler::Keyword::Draft4::Ref;
use strict;
use warnings;
use parent 'JSV::Compiler::Keyword';

use Carp;
use URI;
use JSV::Compiler::Keyword qw(:constants);
use JSV::Compiler::Util qw(to_perl_literal);

sub instance_type() { INSTANCE_TYPE_ANY(); }
sub keyword() { '$ref' }
sub keyword_priority() { 5; }

sub generate_code {
    my ($class, $compiler_context, $schema) = @_;

    my $ref_uri = URI->new($class->keyword_value($schema));

    my $base_uri = $compiler_context->original_schema->{id};
    my $root     = $compiler_context->original_schema;

    unless ($ref_uri->scheme) {
        $ref_uri = $ref_uri->abs($base_uri);
    }

    unless ($compiler_context->is_registered_code($ref_uri)) {
        my $ref_schema = eval {
            $compiler_context->reference->get_schema(
                URI->new($ref_uri),
                +{
                    base_uri => $base_uri,
                    root     => $root,
                }
            );
        };
        if (my $e = $@) {
            croak $e;
        }

        my $code = $compiler_context->generate_code($ref_schema);
        $compiler_context->register_code($ref_uri, $code);
    }

    return sprintf(q{
        $validator_proc->($context, $instance, %s);
    }, to_perl_literal($ref_uri));
}

1;
