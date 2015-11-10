package JSV::Compiler::Keyword::Draft4::Required;
use strict;
use warnings;
use parent 'JSV::Compiler::Keyword';

use Carp qw(croak);
use JSV::Compiler::Keyword qw(:constants);
use JSV::Compiler::Util qw(to_perl_literal);

sub instance_type() { INSTANCE_TYPE_OBJECT(); }
sub keyword() { 'required' }
sub keyword_priority() { 10; }

sub generate_code {
    my ($class, $compiler_context, $schema) = @_;

    my $keyword_value = $class->keyword_value($schema);
    my $props_literal = join ',', map { to_perl_literal($_) } @$keyword_value;

    return qq[
        my \@missing_properties = ( grep { !exists \$instance->{\$_} } ($props_literal) );
        if ( \@missing_properties != 0 ) {
            \$context->log_error(sprintf("The instance properties has not required properties (missing: %s)", join(", ", \@missing_properties)));
        }
    ];
}

1;
