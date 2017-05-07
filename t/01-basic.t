# Copyright (C) 2015-2017 Yoann Le Garff, Nicolas Boquet and Yann Le Bras
# navel-hub is licensed under the Apache License, Version 2.0

#-> BEGIN

#-> initialization

use strict;
use warnings;

use Test::More;
use Test::Mojo;

#-> main

my $mojolicious_tester = Test::Mojo->new('Navel::Hub');

$mojolicious_tester->get_ok('/not_found')->status_is(404);

done_testing();

#-> END

__END__
