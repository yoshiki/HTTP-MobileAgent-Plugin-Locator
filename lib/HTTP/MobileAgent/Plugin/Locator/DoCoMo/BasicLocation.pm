package HTTP::MobileAgent::Plugin::Locator::DoCoMo::BasicLocation;
# Open iArea

use strict;
use base qw( HTTP::MobileAgent::Plugin::Locator );
use Location::Area::DoCoMo::iArea;
use Geo::Coordinates::Converter;

sub get_location {
    my ( $self, $params ) = @_;
    my $areacode = $params->{ AREACODE };
    my $obj = Location::Area::DoCoMo::iArea->create_iarea( $areacode );
    my ( $lat, $lng ) = $obj->get_center->datum_wgs84->format_gpsone->array;
    return Geo::Coordinates::Converter->new(
        lat    => $lat || undef,
        lng    => $lng || undef,
        datum  => 'wgs84',
    )->convert;
}

1;
