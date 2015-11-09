package JSV::Compiler::Validator;
use strict;
use warnings;

use Carp qw(croak);
use JSV::Compiler::Runtime::Context;
use JSV::Compiler::Runtime::Result;

sub new {
    my ($class, %args) = @_;

    my $validator_proc = eval $args{validator_code};
    if (my $e = $@) {
        croak $e . "\n" . "$args{validator_code}";
    }

    bless +{
        validator_proc => $validator_proc,
        %args,
    }, $class;
}

sub validate {
    my ($self, $instance) = @_;

    my $context = JSV::Compiler::Runtime::Context->new();

    my $rv;
    eval {
        $self->{validator_proc}->($context, $instance);

        $rv = JSV::Compiler::Runtime::Result->new();
    };
    if (my $e = $@) {
        $context->log_error(sprintf("Unexpected error: %s", $e));
    }

    if (scalar @{ $context->errors }) {
        $rv = JSV::Compiler::Runtime::Result->new(
            errors => $context->errors,
        );
    }

    return $rv;
}

1;
