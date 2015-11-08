package JSV::Compiler::Reference;
use strict;
use warnings;

sub new {
    my ($class, %args) = @_;

    bless +{
        %args,
    }, $class;
}

sub register_schema {
    # TODO:
}

sub unregister_schema {
    # TODO:
}

1;
