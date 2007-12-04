package HTTP::MobileAgent::Plugin::Locator;

use warnings;
use strict;
use HTTP::MobileAgent;
use UNIVERSAL::require;

our $VERSION = '0.01';

sub import {
    my $class = shift;
    no strict 'refs';
    *{"HTTP\::MobileAgent\::gps_compliant"} = \&_gps_compliant;
    *{"HTTP\::MobileAgent\::get_location"}  = \&_get_location;
}

sub _gps_compliant {
    my $self = shift;
    if ( $self->is_docomo ) {
        return $self->model =~ /(?:90[345]|SA[78]0[02]i)/;
    } elsif ( $self->is_ezweb ) {
        my @specs = split //, $ENV{ HTTP_X_UP_DEVCAP_MULTIMEDIA } || '';
        return defined $specs[ 1 ] && $specs[ 1 ] =~ /^[23]$/;
    } elsif ( $self->is_softbank ) {
        return $self->is_type_3gc;
    }
}

sub _get_location {
    my ( $self, $query ) = @_;
    my $module;
    if ( $self->is_docomo ) {
        $module = $self->gps_compliant
            ? 'HTTP::MobileAgent::Plugin::Locator::DoCoMo::GPS'
            : 'HTTP::MobileAgent::Plugin::Locator::DoCoMo::BasicLocation';
    }
    elsif ( $self->is_ezweb ) {
        $module = $self->gps_compliant
            ? 'HTTP::MobileAgent::Plugin::Locator::EZweb::GPS'
            : 'HTTP::MobileAgent::Plugin::Locator::EZweb::BasicLocation';
    }
    elsif ( $self->is_softbank ) {
        $module = $self->gps_compliant
            ? 'HTTP::MobileAgent::Plugin::Locator::SoftBank::GPS'
            : 'HTTP::MobileAgent::Plugin::Locator::SoftBank::BasicLocation';
    }
    elsif ( $self->is_airh_phone ) {
        $module = 'HTTP::MobileAgent::Plugin::Locator::Willcom::BasicLocation';
    }
    else {
        die "non mobile";
    }
    $module->require or die $!;
    return $module->new( $query )->get_location;
}

1;
__END__

=head1 NAME

HTTP::MobileAgent::Plugin::Locator - Handling mobile location information plugin for HTTP::MobileAgent

=head1 SYNOPSIS

    use HTTP::MobileAgent;
    use HTTP::MobileAgent::Plugin::Locator;

    # get parameters
    my $q = CGI->new;
    $params = { map { $_ => $q->param( $_ ) } $q->param };

    # get location
    my $agent = HTTP::MobileAgent->new;
    my $location = $agent->get_location( $params );

    print "lat is " . $location->{ lat };
    print "lng is " . $location->{ lng };

=head1 METHODS

=over

=item get_location([ gps or basic location parameters from carrier ]);

return hashref included latitude and longitude if specify gps or basic location parameters from carrier. The parameters is different by carrier.

=item gps_compliant

returns if the agent is GPS compliant

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
