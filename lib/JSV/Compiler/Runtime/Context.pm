package JSV::Compiler::Runtime::Context;
use strict;
use warnings;

use Class::Accessor::Lite (
    new => 0,
    ro  => [qw/
        errors
    /],
);

sub new {
    my ($class, %args) = @_;

    bless +{
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
