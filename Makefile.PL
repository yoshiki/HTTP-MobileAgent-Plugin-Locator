use strict;
use warnings;
use inc::Module::Install;

name            'HTTP-MobileAgent-Plugin-Locator';
author          'Yoshiki Kurihara <kurihara __at__ cpan.org>';
all_from        'lib/HTTP/MobileAgent/Plugin/Locator.pm';
version_from    'lib/HTTP/MobileAgent/Plugin/Locator.pm';

build_requires 'Test::More' => 0;

requires 'Geo::Coordinates::Converter' => 0;
requires 'Geo::Coordinates::Converter::iArea' => '0.08';
requires 'HTTP::MobileAgent' => 0;
requires 'UNIVERSAL::require' => 0;
requires 'UNIVERSAL::can' => 0;

auto_install;
WriteAll;
