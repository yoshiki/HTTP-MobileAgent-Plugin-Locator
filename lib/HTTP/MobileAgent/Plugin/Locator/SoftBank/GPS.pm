package HTTP::MobileAgent::Plugin::Locator::SoftBank::GPS;
# S!GPS

use strict;
use base qw( HTTP::MobileAgent::Plugin::Locator::Base );
use Geo::Coordinates::Converter;

sub get_location {
    my $self = shift;
    my ( $lat, $lng ) = $self->params->{ pos } =~ /^[NS]([\d\.]+)[EW]([\d\.]+)$/;
    my $geo = Geo::Coordinates::Converter->new(
        lat   => $lat,
        lng   => $lng,
        datum => 'wgs84',
    )->convert( 'tokyo' );
    return +{
        lat => $geo->lat || undef,
        lng => $geo->lng || undef,
    };
}

1;
