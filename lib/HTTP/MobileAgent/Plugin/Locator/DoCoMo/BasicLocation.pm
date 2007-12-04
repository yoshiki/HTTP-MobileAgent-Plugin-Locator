package HTTP::MobileAgent::Plugin::Locator::DoCoMo::BasicLocation;
# Open iArea

use strict;
use base qw( HTTP::MobileAgent::Plugin::Locator::Base );
use Location::Area::DoCoMo::iArea;

sub get_location {
    my $self = shift;
    my $areacode = $self->params->{ AREACODE };
    my $obj = Location::Area::DoCoMo::iArea->create_iarea( $areacode );
    my ( $lat, $lng ) = $obj->get_center->datum_tokyo->format_gpsone->array;
    return +{
        lat => $lat || undef,
        lng => $lng || undef,
    };
}

1;
