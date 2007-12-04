package HTTP::MobileAgent::Plugin::Locator::Willcom::BasicLocation;

use strict;
use base qw( HTTP::MobileAgent::Plugin::Locator::Base );

sub get_location {
    my $self = shift;
    my ( $lat, $lng ) = $self->params->{ pos } =~ /^N([^E]+)E(.+)$/;
    return +{
        lat => $lat || undef,
        lng => $lng || undef,
    };
}

1;
