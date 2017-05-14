# Copyright (C) 2015-2017 Yoann Le Garff, Nicolas Boquet and Yann Le Bras
# navel-hub is licensed under the Apache License, Version 2.0

#-> BEGIN

#-> initialization

package Navel::Hub::Controller::OpenAPI::Storer 0.1;

use Navel::Base;

use Mojo::Base 'Mojolicious::Controller';

#-> methods

sub show_proxy {
    my $controller = shift->openapi->valid_input || return;

    $controller->render(
        openapi => {
            remote => $controller->navel->storer_proxy_pass->{remote}->to_string,
            location => $controller->navel->storer_proxy_pass->{location}
        }
    );
}

# sub AUTOLOAD {}

# sub DESTROY {}

1;

#-> END

__END__

=pod

=encoding utf8

=head1 NAME

Navel::Hub::Controller::OpenAPI::Storer

=head1 COPYRIGHT

Copyright (C) 2015-2017 Yoann Le Garff, Nicolas Boquet and Yann Le Bras

=head1 LICENSE

navel-hub is licensed under the Apache License, Version 2.0

=cut
