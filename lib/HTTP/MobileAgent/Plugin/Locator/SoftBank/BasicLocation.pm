package HTTP::MobileAgent::Plugin::Locator::SoftBank::BasicLocation;
# 簡易位置情報

use strict;
use base qw( HTTP::MobileAgent::Plugin::Locator::Base );

sub get_location {
    my ( $self, $page ) = @_;
    my $geocode = $ENV{ HTTP_X_JPHONE_GEOCODE };
    $geocode =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C",hex($1))/eg;
    my ( $lat, $lng, $address ) = split /\x1a/, $geocode;
    return +{
        lat => _convert_point( $lat ) || undef,
        lng => _convert_point( $lng ) || undef,
    };
}

sub _convert_point {
    my $point = shift;
    ($point = reverse split //, $point) =~ s/(..)/.$1/g;
    return join '', reverse split //, '00' . $point;
}

1;
