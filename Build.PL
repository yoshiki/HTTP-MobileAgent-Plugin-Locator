use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'HTTP::MobileAgent::Plugin::Locator',
    dist_author         => 'Yoshiki Kurihara <kurihara __at__ cpan.org>',
    dist_version_from   => 'lib/HTTP/MobileAgent/Plugin/Locator.pm',
    requires => {
        'Test::More' => 0,
        'Geo::Coordinates::Converter' => 0,
        'HTTP::MobileAgent' => 0,
        'UNIVERSAL::require' => 0,
        'UNIVERSAL::can' => 0,
    },
    add_to_cleanup      => [ 'HTTP-MobileAgent-Plugin-Locator-*' ],
);

$builder->create_build_script();
