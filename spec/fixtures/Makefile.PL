use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME             => 'Example::Module',
    AUTHOR           => 'Test Author <test@example.com>',
    VERSION_FROM     => 'lib/Example/Module.pm',
    ABSTRACT_FROM    => 'lib/Example/Module.pm',
    LICENSE          => 'perl',
    MIN_PERL_VERSION => '5.010',

    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => '6.64',
    },

    BUILD_REQUIRES => {
        'File::Temp' => 0,
    },

    TEST_REQUIRES => {
        'Test::More'   => '0.88',
        'Test::Deep'   => 0,
        'Test::Warn'   => '0.30',
    },

    PREREQ_PM => {
        'Moo'                       => '2.0',
        'JSON::XS'                  => 0,
        'LWP::UserAgent'            => '6.0',
        'URI'                       => 0,
        'Data::Dumper'              => 0,
        'File::Spec'                => '0.8',
    },

    META_MERGE => {
        'meta-spec' => { version => 2 },
        resources => {
            repository => {
                type => 'git',
                url  => 'https://github.com/example/example-module.git',
            },
        },
    },
);
