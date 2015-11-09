package JSV::Compiler::Keyword::Draft4::Properties;
use strict;
use warnings;
use parent 'JSV::Compiler::Keyword';

use Carp qw(croak);
use JSV::Compiler::Keyword qw(:constants);
use JSV::Compiler::Util qw(to_perl_literal);

sub instance_type() { INSTANCE_TYPE_OBJECT(); }
sub keyword() { 'properties' }
sub keyword_priority() { 10; }

sub generate_code {
    my ($class, $compiler_context, $schema) = @_;

    my $properties = $class->keyword_value($schema) || {};

    my @codes = ();

    for my $property (keys %$properties) {
        my $prop_literal = to_perl_literal($property);
        push @codes, qq[ my \$instance_ = \$instance;
                         if (exists \$instance_->{$prop_literal}) {
                             my \$instance = \$instance_->{$prop_literal}; ];
        push @codes, $compiler_context->generate_code($properties->{$property});
        push @codes, qq[ } ];
    }

    return join "\n", @codes;
}

1;
