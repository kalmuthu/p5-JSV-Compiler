package JSV::Compiler::Context;
use strict;
use warnings;

use JSON;
use JSV::Compiler::Keyword qw(:constants);

use Class::Accessor::Lite (
    new => 0,
    ro  => [qw/
        keywords
        reference
        original_schema
        registered_code_map
        json
        loose_type
    /],
);

sub new {
    my ($class, %args) = @_;

    bless +{
        registered_code_map => +{},
        json                => JSON->new->allow_nonref->canonical,
        %args,
    }, $class;
}

sub generate_code {
    my ($self, $schema) = @_;

    my @codes = ();

    for my $keyword (@{ $self->keywords->{INSTANCE_TYPE_ANY()} }) {
        next unless exists $schema->{$keyword->keyword};
        push @codes, $keyword->generate_code($self, $schema);
    }
    push @codes, q[ if (ref($instance) eq 'HASH') { ];
    for my $keyword (@{ $self->keywords->{INSTANCE_TYPE_OBJECT()} }) {
        next unless exists $schema->{$keyword->keyword};
        push @codes, $keyword->generate_code($self, $schema);
    }
    push @codes, q[ } ];

    return join "\n", @codes;
}

sub is_registered_code {
    my ($self, $uri) = @_;
    
    return $self->registered_code_map->{$uri};
    
}

sub register_code {
    my ($self, $uri, $code) = @_;

    $self->registered_code_map->{$uri} = $code;
}

1;
