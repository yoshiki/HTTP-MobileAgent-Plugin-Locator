use Test::More 'no_plan';

use HTTP::MobileAgent;
use HTTP::MobileAgent::Plugin::Locator;

{
    local $ENV{HTTP_USER_AGENT} = 'DoCoMo/2.0 SH904i(c100;TB;W24H16)';
    my $agent = HTTP::MobileAgent->new;
    my $location = $agent->get_location( {
        lat => '35.21.03.342', lon => '138.34.45.725', geo => 'wgs84'
    } );
    is ref $location, 'Geo::Coordinates::Converter::Point';
    is_deeply( { lat => $location->lat, lng => $location->lng  },
               { lat => '35.21.03.342', lng => '138.34.45.725' } );
}

{
    local $ENV{HTTP_USER_AGENT} = 'DoCoMo/1.0/P503i/c10';
    my $agent = HTTP::MobileAgent->new;
    my $location = $agent->get_location( { AREACODE => '05902' } );
    is ref $location, 'Geo::Coordinates::Converter::Point';
    is_deeply( { lat => $location->lat, lng => $location->lng  },
               { lat => '35.39.43.538', lng => '139.44.06.232' } );
}

{
    local $ENV{HTTP_USER_AGENT} = 'KDDI-CA31 UP.Browser/6.2.0.7.3.129 (GUI) MMP/2.0';
    local $ENV{HTTP_X_UP_DEVCAP_MULTIMEDIA} = '0200000000000000';
    my $agent = HTTP::MobileAgent->new;
    my $location = $agent->get_location( {
        lat => '+35.21.03.342', lon => '+138.34.45.725', datum => '0'
    } );
    is ref $location, 'Geo::Coordinates::Converter::Point';
    is_deeply( { lat => $location->lat, lng => $location->lng  },
               { lat => '35.21.03.342', lng => '138.34.45.725' } );
}

{
    local $ENV{HTTP_USER_AGENT} = 'KDDI-CA31 UP.Browser/6.2.0.7.3.129 (GUI) MMP/2.0';
    my $agent = HTTP::MobileAgent->new;
    my $location = $agent->get_location( { lat => '+35.21.03.342', lon => '+138.34.45.725' } );
    is ref $location, 'Geo::Coordinates::Converter::Point';
    is_deeply( { lat => $location->lat, lng => $location->lng  },
               { lat => '35.21.03.342', lng => '138.34.45.725' } );
}

{
    local $ENV{HTTP_USER_AGENT} = 'SoftBank/1.0/911T/TJ001 Browser/NetFront/3.3 Profile/MIDP-2.0 Configuration/CLDC-1.1';
    my $agent = HTTP::MobileAgent->new;
    my $location = $agent->get_location( { pos => 'N35.21.03.342E138.34.45.725' } );
    is ref $location, 'Geo::Coordinates::Converter::Point';
    is_deeply( { lat => $location->lat, lng => $location->lng  },
               { lat => '35.21.03.342', lng => '138.34.45.725' } );
}

{
    local $ENV{HTTP_USER_AGENT} = 'J-PHONE/2.0/J-DN02';
    local $ENV{ HTTP_X_JPHONE_GEOCODE } = '352051%1a1383456%1afoo';
    my $agent = HTTP::MobileAgent->new;
    my $location = $agent->get_location();
    is ref $location, 'Geo::Coordinates::Converter::Point';
    is_deeply( { lat => $location->lat, lng => $location->lng  },
               { lat => '35.21.02.678', lng => '138.34.44.820' } );
}

{
    local $ENV{HTTP_USER_AGENT} = 'Mozilla/3.0(DDIPOCKET;JRC/AH-J3001V,AH-J3002V/1.0/0100/c50)CNF/2.0';
    my $agent = HTTP::MobileAgent->new;
    my $location = $agent->get_location( { pos => 'N35.20.51.664E138.34.56.905' } );
    is ref $location, 'Geo::Coordinates::Converter::Point';
    is_deeply( { lat => $location->lat, lng => $location->lng  },
               { lat => '35.21.03.342', lng => '138.34.45.725' } );
}


