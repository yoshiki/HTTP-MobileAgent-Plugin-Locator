package HTTP::MobileAgent::Plugin::Locator::Base;

use strict;
use base qw( Class::Accessor::Fast );

__PACKAGE__->mk_accessors( qw( params ) );

sub new {
    my ( $class, $stuff ) = @_;
    if ( UNIVERSAL::isa( $stuff, 'Apache' ) ) {
        my $req = Apache::Request->new( $stuff );
        bless { params => {
            map { $_ => $req->param( $_ ) } $req->param
        } }, $class;
    }
    else {
        bless { params => $stuff }, $class;
    }
}

1;
