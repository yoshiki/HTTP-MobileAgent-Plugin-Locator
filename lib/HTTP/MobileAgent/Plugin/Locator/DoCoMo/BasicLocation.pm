package HTTP::MobileAgent::Plugin::Locator::DoCoMo::BasicLocation;
# Open iArea

use strict;
use base qw( HTTP::MobileAgent::Plugin::Locator );
use Geo::Coordinates::Converter;

sub get_location {
    my ( $self, $params ) = @_;

    return Geo::Coordinates::Converter->new(
        lat    => $params->{ LAT },
        lng    => $params->{ LON },
        datum  => $params->{ GEO },
    )->convert;
}

1;
