package JSV::Compiler;
use 5.008001;
use strict;
use warnings;

use Module::Pluggable::Object;
use JSV::Compiler::Context;
use JSV::Compiler::Keyword qw(:constants);
use JSV::Compiler::Reference;
use JSV::Compiler::Validator;

use Class::Accessor::Lite (
    new => 0,
    ro  => [qw/
        reference
        environment
        environment_keywords
    /]
);

our $VERSION = "0.01";

my %supported_environments = (
    draft4 => "Draft4"
);
my %environment_keywords = ();

sub load_environments {
    my ($class, @environments) = @_;

    for my $environment (@environments) {
        next unless (exists $supported_environments{$environment});
        my $finder = Module::Pluggable::Object->new(
            search_path => ["JSV::Compiler::Keyword::" . $supported_environments{$environment}],
            require => 1,
        );

        $environment_keywords{$environment} =  {
            INSTANCE_TYPE_NUMERIC() => [],
            INSTANCE_TYPE_STRING()  => [],
            INSTANCE_TYPE_ARRAY()   => [],
            INSTANCE_TYPE_OBJECT()  => [],
            INSTANCE_TYPE_ANY()     => [],
        };
        my @keywords =
            sort { $a->keyword_priority <=> $b->keyword_priority }
            $finder->plugins;

        for my $keyword (@keywords) {
            my $type = $keyword->instance_type;
            push(@{$environment_keywords{$environment}{$type}}, $keyword);
        }
    }
}

sub new {
    my ($class, %args) = @_;
    %args = (
        environment => 'draft4',
        reference   => JSV::Compiler::Reference->new,
        %args,
    );

    ### RECOMMENDED: you should do to preloading environment before calling constructor
    unless (exists $environment_keywords{$args{environment}}) {
        $class->load_environments($args{environment});
    }

    bless +{
        environment_keywords => \%environment_keywords,
        %args,
    }, $class;
}

sub compile {
    my ($self, $schema, $opts) = @_;

    $opts ||= +{};
    %$opts = (
        loose_type => 0,
        %$opts,
    );

    my $keywords = +{
        INSTANCE_TYPE_ANY()     => $self->_instance_type_keywords(INSTANCE_TYPE_ANY),
        INSTANCE_TYPE_NUMERIC() => $self->_instance_type_keywords(INSTANCE_TYPE_NUMERIC),
        INSTANCE_TYPE_STRING()  => $self->_instance_type_keywords(INSTANCE_TYPE_STRING),
        INSTANCE_TYPE_ARRAY()   => $self->_instance_type_keywords(INSTANCE_TYPE_ARRAY),
        INSTANCE_TYPE_OBJECT()  => $self->_instance_type_keywords(INSTANCE_TYPE_OBJECT),
    };

    my $compiler_context = JSV::Compiler::Context->new(
        keywords   => $keywords,
        loose_type => $opts->{loose_type},
    );

    my $code = $compiler_context->generate_code($schema);

    my $validator_code = qq{
        use JSON;
        use List::MoreUtils qw(firstidx);
        sub {
            my (\$context, \$instance) = \@_;
            $code
        }
    };

    return JSV::Compiler::Validator->new(
        validator_code => $validator_code,
    );
}

sub _instance_type_keywords {
    my ($self, $instance_type) = @_;
    return $self->environment_keywords->{$self->environment}{$instance_type};
}

sub register_schema {
    my $self = shift;
    self->reference->register_schema(@_);
}

sub unregister_schema {
    my $self = shift;
    self->reference->unregister_schema(@_);
}

1;

__END__

=encoding utf-8

=head1 NAME

JSV::Compiler - It's new $module

=head1 SYNOPSIS

    use JSV::Compiler;

=head1 DESCRIPTION

JSV::Compiler is ...

=head1 LICENSE

Copyright (C) Yoshitaro Makise.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Yoshitaro Makise E<lt>yoshizow@turtlewalk.orgE<gt>

=cut

