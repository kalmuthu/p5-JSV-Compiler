package JSV::Compiler::Reference;
use strict;
use warnings;

use Carp;
use Clone qw(clone);
use Data::Walk;
use JSON::Pointer;
use Scalar::Util qw(weaken);
use JSV::Compiler::Util qw(normalize_uri);

sub new {
    my $class = shift;
    my $args = ref $_[0] ? $_[0] : { @_ };

    %$args = (
        registered_schema_map => {},
        max_recursion         => 10,
        %$args,
    );

    bless $args => $class;
}

sub get_schema {
    my ($self, $uri, $opts) = @_;
    if ( ! $uri->scheme && $opts->{base_uri} ) {
        $uri = $uri->abs($opts->{base_uri});
    }

    my ($normalized_uri, $fragment) = normalize_uri($uri);
    my $schema = $self->{registered_schema_map}{$normalized_uri} || $opts->{root};
    unless (ref $schema eq 'HASH') {
        die sprintf("cannot resolve reference: uri = %s", $uri);
    }

    if (exists $schema->{'$ref'} && $schema->{'$ref'} eq $normalized_uri) {
        die sprintf("cannot resolve reference: uri = %s", $uri);
    }

    if ( $fragment ) {
        eval {
            $schema = JSON::Pointer->get($schema, $fragment, 1);
        };
        if (my $e = $@ ) {
            die sprintf("cannot resolve reference fragment: uri = %s, msg = %s", $uri, $e);
        }
        elsif (!$schema) {
            die sprintf("cannot resolve reference fragment: uri = %s, msg = %s", $uri);
        }
    }

    unless (ref $schema eq 'HASH') {
        die sprintf("cannot resolve reference: uri = %s", $uri);
    }

    return $schema;
}

sub register_schema {
    my ($self, $uri, $schema) = @_;
    my $normalized_uri = normalize_uri($uri);
    my $cloned_schema = clone($schema);

    ### recursive reference resolution
    walkdepth(+{
        wanted => sub {
            if (
                defined $Data::Walk::type &&
                $Data::Walk::type eq "HASH" &&
                exists $_->{'$ref'} &&
                !ref $_->{'$ref'} &&
                keys %$_ == 1
            ) {
                my $ref_uri = URI->new($_->{'$ref'});
                return if $ref_uri->scheme;
                $_->{'$ref'} = $ref_uri->abs($normalized_uri)->as_string;
            }
        },
    }, $cloned_schema);

    $self->{registered_schema_map}{$normalized_uri} = $cloned_schema;
}

sub unregister_schema {
    my ($self, $uri) = @_;
    my $normalized_uri = normalize_uri($uri);
    delete $self->{registered_schema_map}{$normalized_uri};
}

1;
