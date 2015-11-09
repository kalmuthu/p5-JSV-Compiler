package JSV::Compiler::Util;
use strict;
use warnings;

use Exporter qw(import);
use Data::Dumper;

our @EXPORT_OK = (qw/
    to_perl_literal
/);

sub to_perl_literal {
    my $value = shift;
    
    local $Data::Dumper::Terse = 1;
    local $Data::Dumper::Useqq = 1;
    local $Data::Dumper::Indent = 0;
    Dumper($value);
}
