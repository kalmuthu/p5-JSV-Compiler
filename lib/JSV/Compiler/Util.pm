package JSV::Compiler::Util;
use strict;
use warnings;

use Exporter qw(import);
use Data::Dumper;
use URI::Split qw(uri_split uri_join);

our @EXPORT_OK = (qw/
    to_perl_literal
    normalize_uri
/);

sub to_perl_literal {
    my $value = shift;
    
    local $Data::Dumper::Terse = 1;
    local $Data::Dumper::Useqq = 1;
    local $Data::Dumper::Indent = 0;
    Dumper($value);
}

sub normalize_uri {
    my $uri = shift;
    my %parts;

    @parts{qw/scheme authority path query fragment/} = uri_split($uri);
    my $fragment = $parts{fragment};
    $parts{fragment} = undef;

    my $normalized_uri = uri_join(@parts{qw/scheme authority path query fragment/});

    return wantarray ? ($normalized_uri, $fragment) : $normalized_uri;
}
