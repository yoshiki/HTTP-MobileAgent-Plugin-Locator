package HTTP::MobileAgent::Plugin::Locator::EZweb::GPS;
# GPS

use strict;
use base qw( HTTP::MobileAgent::Plugin::Locator::Base );
use Geo::Coordinates::Converter;

sub get_location {
    my $self = shift;
    (my $lat = $self->params->{ lat }) =~ s/^[\-\+]//g;
    (my $lng = $self->params->{ lon }) =~ s/^[\-\+]//g;
    my $datum = $self->params->{ datum } || 'tokyo';
    my $geo = Geo::Coordinates::Converter->new(
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
