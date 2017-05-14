# Copyright (C) 2015-2017 Yoann Le Garff, Nicolas Boquet and Yann Le Bras
# navel-hub is licensed under the Apache License, Version 2.0

#-> BEGIN

#-> initialization

package Navel::Hub::Controller::OpenAPI::CollectorManager 0.1;

use Navel::Base;

use Mojo::Base 'Mojolicious::Controller';

#-> methods

sub list {
    my $controller = shift->openapi->valid_input || return;

    $controller->render(
        openapi => [
            keys %{$controller->navel->collector_managers_proxy_pass}
        ]
    );
}

sub show_proxy {
    my $controller = shift->openapi->valid_input || return;

    my $name = $controller->validation->param('name');

    my $proxy_pass = $controller->navel->collector_managers_proxy_pass->{$name};

    return $controller->navel->stdresponses->resource_not_found($name) unless defined $proxy_pass;

    $controller->render(
        openapi => {
            remote => $proxy_pass->{remote}->to_string,
            location => $proxy_pass->{location}
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

Navel::Hub::Controller::OpenAPI::CollectorManager

=head1 COPYRIGHT

Copyright (C) 2015-2017 Yoann Le Garff, Nicolas Boquet and Yann Le Bras

=head1 LICENSE

navel-hub is licensed under the Apache License, Version 2.0

=cut
