package JSV::Compiler::Runtime::Context;
use strict;
use warnings;

use JSON;

use Class::Accessor::Lite (
    new => 0,
    ro  => [qw/
        json
        errors
    /],
);

sub new {
    my ($class, %args) = @_;

    bless +{
        json   => JSON->new->allow_nonref->canonical,
        errors => [],
        %args,
    }, $class;
}

sub log_error {
    my ($self, $message) = @_;

    my $error = +{
        message => $message,
    };

    push @{ $self->{errors} }, $error;
}

1;
