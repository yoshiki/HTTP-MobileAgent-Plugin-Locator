package HTTP::MobileAgent::Plugin::Locator::EZweb::BasicLocation;
# 簡易位置情報

use strict;
use base qw( HTTP::MobileAgent::Plugin::Locator::Base );
use Geo::Coordinates::Converter;

sub get_location {
    my $self = shift;
    my $lat   = $self->params->{ lat };
    my $lng   = $self->params->{ lon };
    my $datum = 'wgs84';
    my $geo   = Geo::Coordinates::Converter->new(
        lat   => $lat,
        lng   => $lng,
        datum => $datum,
    )->convert( 'tokyo' );
    return +{
        lat => $geo->lat || undef,
        lng => $geo->lng || undef,
    };
}

1;
