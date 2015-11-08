package JSV::Compiler::Runtime::Result;
use strict;
use warnings;
use overload
    'bool' => \&to_boolean,
    'eq'   => \&equals;

use Class::Accessor::Lite (
    new => 1,
    rw  => [qw/instance error errors/]
);

sub equals {
    $_[0]->to_boolean == $_[1];
}

sub to_boolean {
    my $self = shift;
    return (($self->errors && scalar @{ $self->errors }) || $self->error) ? 0 : 1;
}

sub get_error {
    my ($self, $pointer) = @_;

    if ( $self->error ) {
        return $self->error;
    }
    elsif ( $self->errors ) {
        if ( $pointer ) {
            return grep { $_->{pointer} eq $pointer } @{ $self->errors };
        }
        else {
            return @{ $self->errors };
        }
    }
}

sub get_error_map {
    my $self = shift;
    return Hash::MultiValue->new(map { $_->{pointer} => $_ } @{ $self->errors });
}

1;
