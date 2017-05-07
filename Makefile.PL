# Copyright (C) 2015-2017 Yoann Le Garff, Nicolas Boquet and Yann Le Bras
# navel-hub is licensed under the Apache License, Version 2.0

#-> BEGIN

#-> initialization

use strict;
use warnings;

use ExtUtils::MakeMaker;

#-> main

my $min_perl_version = '5.20.0';

WriteMakefile(
    NAME => 'Navel::Hub',
    VERSION_FROM => 'lib/Navel/Hub.pm',
    ABSTRACT => 'navel-hub',
    AUTHOR => 'Yoann Le Garff, Nicolas Boquet and Yann Le Bras',
    LICENSE => 'Apache License, Version 2.0',
    META_MERGE => {
        requires => {
            perl => $min_perl_version
        },
        resources => {
            license => 'http://www.apache.org/licenses/LICENSE-2.0.html',
            repository => 'http://github.com/Navel-IT/navel-hub'
        }
    },
    MIN_PERL_VERSION => $min_perl_version,
    PREREQ_PM => {
        'Navel::Base' => 0,
        'Navel::Mojolicious::Plugin::OpenAPI::StdResponses' => 0,
        'Navel::API' => 0,
        'Mojolicious' => 0,
        # 'Mojo::Pg' => 0,
        'Mojo::JSON::MaybeXS' => 0,
        'Mojolicious::Plugin::OpenAPI' => 0,
        'FindBin' => 0,
        'IO::Socket::SSL' => 1.84
    },
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => 6.64
    },
    TEST_REQUIRES => {
        'Test::More' => 0,
        'Test::Mojo' => 0
    }
);

#-> END

__END__
