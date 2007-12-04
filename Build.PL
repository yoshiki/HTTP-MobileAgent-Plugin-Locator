use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'HTTP::MobileAgent::Plugin::Locator',
    license             => '',
    dist_author         => 'Yoshiki Kurihara <kurihara@cpan.org>',
    dist_version_from   => 'lib/HTTP/MobileAgent/Plugin/Locator.pm',
    requires => {
        'Test::More' => 0,
    },
    add_to_cleanup      => [ 'HTTP-MobileAgent-Plugin-Locator-*' ],
);

$builder->create_build_script();
