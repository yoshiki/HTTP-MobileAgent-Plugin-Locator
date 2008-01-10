package HTTP::MobileAgent::Plugin::Locator;

use warnings;
use strict;
use HTTP::MobileAgent;
use Carp;
use UNIVERSAL::require;
use UNIVERSAL::can;

our $VERSION = '0.01';

our $DOCOMO_GPS_COMPLIANT_MODELS = qr/(?:903i(?!TV|X)|(?:90[45]|SA[78]0[02])i)/;

sub import {
    my $class = shift;
    no strict 'refs';
    *{"HTTP\::MobileAgent\::gps_compliant"} = \&_gps_compliant;
    *{"HTTP\::MobileAgent\::locator"}       = sub { $class->new( shift ) };
    *{"HTTP\::MobileAgent\::get_location"}  = sub {
        my ( $self, $stuff ) = @_;
        $self->locator->get_location( _prepare_params( $stuff ) );
    };
}

sub _gps_compliant {
    my $self = shift;
    if ( $self->is_docomo ) {
        return $self->model =~ $DOCOMO_GPS_COMPLIANT_MODELS;
    } elsif ( $self->is_ezweb ) {
        my @specs = split //, $ENV{ HTTP_X_UP_DEVCAP_MULTIMEDIA } || '';
        return defined $specs[ 1 ] && $specs[ 1 ] =~ /^[23]$/;
    } elsif ( $self->is_softbank ) {
        return $self->is_type_3gc;
    }
}

sub new {
    my ( $class, $agent ) = @_;

    my $sub;
    if ( $agent->is_docomo ) {
        $sub = $agent->gps_compliant ? 'DoCoMo::GPS'
                                     : 'DoCoMo::BasicLocation';
    }
    elsif ( $agent->is_ezweb ) {
        $sub = $agent->gps_compliant ? 'EZweb::GPS'
                                     : 'EZweb::BasicLocation';
    }
    elsif ( $agent->is_softbank ) {
        $sub = $agent->gps_compliant ? 'SoftBank::GPS'
                                     : 'SoftBank::BasicLocation';
    }
    elsif ( $agent->is_airh_phone ) {
        $sub = 'Willcom::BasicLocation';
    }
    else {
        croak( "Invalid mobile user agent: " . $agent->user_agent );
    }

    my $locator_class = "HTTP::MobileAgent::Plugin::Locator\::$sub";
    $locator_class->require or die $!;
    return bless {}, $locator_class;
}

sub get_location { die "ABSTRACT METHOD" }

sub _prepare_params {
    my $stuff = shift;
    if ( ref $stuff && eval { $stuff->can( 'param' ) } ) {
        return +{ map { $_ => $stuff->param( $_ ) } $stuff->param };
    }
    else {
        return $stuff;
    }
}

1;
__END__

=head1 NAME

HTTP::MobileAgent::Plugin::Locator - Handling mobile location information plugin for HTTP::MobileAgent

=head1 SYNOPSIS

    use CGI;
    use HTTP::MobileAgent;
    use HTTP::MobileAgent::Plugin::Locator;

    # get location is Geo::Coordinates::Converter::Point instance formatted wgs84
    my $q = CGI->new;
    my $agent = HTTP::MobileAgent->new;
    my $location = $agent->get_location( $q );

    print "lat is " . $location->lat;
    print "lng is " . $location->lng;

=head1 METHODS

=over

=item get_location([params]);

return Geo::Coordinates::Converter::Point instance formatted if specify gps or basic location parameters sent from carrier. The parameters are different by each carrier.

This method accept a Apache instance, CGI instance or hashref of query parameters.

=item gps_compliant()

returns if the agent is GPS compliant.

=back

=head1 CLASSES

=over

=item HTTP::MobileAgent::Plugin::Locator::DoCoMo::BasicLocation

for iArea data support.

=item HTTP::MobileAgent::Plugin::Locator::DoCoMo::GPS

for GPS data support.

=item HTTP::MobileAgent::Plugin::Locator::EZweb::BasicLocation

for basic location information data support.

=item HTTP::MobileAgent::Plugin::Locator::EZweb::GPS

for EZnavi data support.

=item HTTP::MobileAgent::Plugin::Locator::SoftBank::BasicLocation

for basic location information data support.

=item HTTP::MobileAgent::Plugin::Locator::SoftBank::GPS

for GPS data support.

=item HTTP::MobileAgent::Plugin::Locator::Willcom::BasicLocation

for basic location information data support.

=back

=head1 EXAMPLES

There is request template using C<Template> in eg directory and mod_rewrite configuration for ezweb extraordinary parameter handling.

=head1 SEE ALSO

C<HTTP::MobileAgent>, C<Geo::Coordinates::Converter>, C<Geo::Coordinates::Converter::Point>

=head1 AUTHOR

Yoshiki Kurihara  C<< <kurihara at cpan.org> >>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2007, Yoshiki Kurihara C<< <kurihara at cpan.org> >>. All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.

=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.
