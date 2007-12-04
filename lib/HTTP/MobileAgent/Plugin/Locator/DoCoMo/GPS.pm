package HTTP::MobileAgent::Plugin::Locator::DoCoMo::GPS;
# GPS

use strict;
use base qw( HTTP::MobileAgent::Plugin::Locator::Base );
use Geo::Coordinates::Converter;

sub get_location {
    my $self = shift;
    my $lat   = $self->params->{ lat };
    my $lng   = $self->params->{ lon };
    my $datum = $self->params->{ geo };
    my $geo = Geo::Coordinates::Converter->new(
        lat   => $lat,
        lng   => $lng,
        datum => lc $datum,
    )->convert( 'tokyo' );
    return +{
        lat => $geo->lat || undef,
        lng => $geo->lng || undef,
    };
}

1;
