use strict;
use warnings;
use Module::Build;

my $build = Module::Build->new(
    module_name        => 'Example::Build',
    license            => 'perl',
    dist_author        => 'Test Author <test@example.com>',
    dist_abstract      => 'An example module using Module::Build',
    create_makefile_pl => 'traditional',

    configure_requires => {
        'Module::Build' => '0.40',
    },

    build_requires => {
        'File::Temp'    => 0,
        'File::Spec'    => 0,
    },

    test_requires => {
        'Test::More'    => '0.96',
        'Test::Fatal'   => 0,
        'Test::Warn'    => 0,
    },

    requires => {
        'perl'              => '5.010',
        'Moose'             => '2.0',
        'namespace::clean'  => '0.20',
        'Try::Tiny'         => '0.22',
        'JSON'              => 0,
        'YAML'              => 0,
    },

    recommends => {
        'JSON::XS' => '3.0',
    },

    meta_merge => {
        resources => {
            repository => 'https://github.com/example/example-build',
        },
    },
);

$build->create_build_script;
