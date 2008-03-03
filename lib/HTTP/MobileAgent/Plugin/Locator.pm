package HTTP::MobileAgent::Plugin::Locator;

use warnings;
use strict;
use HTTP::MobileAgent;
use Carp;
use UNIVERSAL::require;
use UNIVERSAL::can;

use base qw( Exporter );
our @EXPORT_OK = qw( $LOCATOR_AUTO_FROM_COMPLIANT $LOCATOR_AUTO $LOCATOR_GPS $LOCATOR_BASIC );
our %EXPORT_TAGS = (locator => [@EXPORT_OK]);

our $VERSION = '0.01';

our $DOCOMO_GPS_COMPLIANT_MODELS = qr/(?:903i(?!TV|X)|(?:90[45]|SA[78]0[02])i)/;

our $LOCATOR_AUTO_FROM_COMPLIANT = 1;
our $LOCATOR_AUTO                = 2;
our $LOCATOR_GPS                 = 3;
our $LOCATOR_BASIC               = 4;


sub import {
    my ( $class ) = @_;
    no strict 'refs';
    *{"HTTP\::MobileAgent\::gps_compliant"} = \&_gps_compliant;
    *{"HTTP\::MobileAgent\::gps_parameter"} = \&_gps_parameter;
    *{"HTTP\::MobileAgent\::locator"}       = sub { $class->new( @_ ) };
    *{"HTTP\::MobileAgent\::get_location"}  = sub {
        my ( $self, $stuff, $option_ref ) = @_;
        my $params = _prepare_params( $stuff );
        $self->locator( $params, $option_ref )->get_location( $params );
    };

    $class->export_to_level(1, @_);
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


sub _gps_parameter {
    my ( $self, $stuff ) = @_;

    my $params = _prepare_params( $stuff );

    if ( $self->is_docomo ) {
        return (!defined $params->{AREACODE}) ? 1 : 0;
    }
    elsif ( $self->is_ezweb ) {
        return ( $params->{datum} =~ /^\d+$/ ) ? 1 : 0;
    }
    elsif ( $self->is_softbank ) {
        return ( defined $params->{pos} ) ? 1 : 0;
    }
    elsif ( $self->is_airh_phone ) {
        return 0;
    }
    else {
        croak( "Invalid mobile user agent: " . $self->user_agent );
    }
}


sub new {
    my ( $class, $agent, $params, $option_ref ) = @_;


    my $sub_locator = _get_sub_locator($agent, $params, $option_ref);

    my $locator_class = "HTTP::MobileAgent::Plugin::Locator\::$sub_locator";
    $locator_class->require or die $!;
    return bless {}, $locator_class;
}

sub get_location { die "ABSTRACT METHOD" }

sub _get_sub_locator {
    my ( $agent, $params, $option_ref ) = @_;

    my $carrier =   ( $agent->is_docomo      ) ? 'DoCoMo'   :
                    ( $agent->is_ezweb       ) ? 'EZweb'    :
                    ( $agent->is_softbank    ) ? 'SoftBank' :
                    ( $agent->is_airh_phone  ) ? 'Willcom'  : undef
    ;
    if ( !$carrier ) {
        croak( "Invalid mobile user agent: " . $agent->user_agent );
    }

    my $locator;
    if (   !defined $option_ref
        || !defined $option_ref->{locator}
        || $option_ref->{locator} eq $LOCATOR_AUTO_FROM_COMPLIANT )
    {
        $locator = ( $agent->gps_compliant ) ? 'GPS' : 'BasicLocation';
    }
    elsif ( $option_ref->{locator} eq $LOCATOR_AUTO ) {
        $locator = ( $agent->gps_parameter( $params ) ) ? 'GPS' : 'BasicLocation';
    }
    elsif ( $option_ref->{locator} eq $LOCATOR_GPS ) {
        $locator =  'GPS';
    }
    elsif ( $option_ref->{locator} eq $LOCATOR_BASIC ) {
        $locator = 'BasicLocation';
    }
    else {
        croak( "Invalid locator: " . $option_ref->{locator} );
    }

    return $carrier . '::' . $locator;
}

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


=head2 get_location([params], $option_ref);

return Geo::Coordinates::Converter::Point instance formatted if specify gps or basic location parameters sent from carrier. The parameters are different by each carrier.

This method accept a Apache instance, CGI instance or hashref of query parameters.

=over

=item $option_ref{locator}

select locator class algorithm option.

$LOCATOR_AUTO_FROM_COMPLIANT
 auto detect locator from gps compliant.this is I<default>.

$LOCATOR_AUTO
 auto detect locator class from params.

$LOCATOR_GPS
 select GPS class.

$LOCATOR_BASIC
 select BasicLocation class.

=back



=head2 gps_compliant()

returns if the agent is GPS compliant.



=head2 gps_parameter([params])

returns if the params is GPS request.


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

=head1 AUTHOR

Yoshiki Kurihara  E<lt>kurihara __at__ cpan.orgE<gt> with many feedbacks and changes from:

  Tokuhiro Matsuno E<lt>tokuhiro __at__ mobilefactory.jpE<gt>

=head1 SEE ALSO

C<HTTP::MobileAgent>, C<Geo::Coordinates::Converter>, C<Geo::Coordinates::Converter::Point>, C<Geo::Coordinates::Converter::iArea>, C<http://coderepos.org/share/log/lang/perl/HTTP-MobileAgent-Plugin-Locator/>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2008, Yoshiki Kurihara E<lt>kurihara __at__ cpan.orgE<gt>. All rights reserved.

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
