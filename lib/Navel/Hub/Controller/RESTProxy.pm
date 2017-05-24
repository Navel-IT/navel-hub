# Copyright (C) 2015-2017 Yoann Le Garff, Nicolas Boquet and Yann Le Bras
# navel-hub is licensed under the Apache License, Version 2.0

#-> BEGIN

#-> initialization

package Navel::Hub::Controller::RESTProxy;

use Navel::Base;

use Mojo::Base 'Mojolicious::Controller';

use Mojo::Path;
use Mojo::Headers;
use Mojo::Transaction::HTTP;

#-> methods

sub any {
    my $controller = shift;

    $controller->render_later;

    my $path = Mojo::Path->new($controller->stash('path'))->leading_slash(0);

    my $url_to_proxy = $controller->stash('remote')->clone;

    $url_to_proxy->path->trailing_slash(1)->merge($path);

    my $request = $controller->req->clone->url($url_to_proxy);

    $request->content->headers(Mojo::Headers->new);

    $request->fix_headers;

    $controller->app->log->debug('proxying HTTP ' . $request->method . ' ' . $request->url);

    $controller->ua->max_redirects(3)->start(
        Mojo::Transaction::HTTP->new(
            req => $request
        ) => sub {
            my ($ua, $tx) = @_;

            $controller->render(
                format => 'json',
                text => $tx->res->body,
                status => $tx->res->code
            );
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

Navel::Hub::Controller::RESTProxy

=head1 COPYRIGHT

Copyright (C) 2015-2017 Yoann Le Garff, Nicolas Boquet and Yann Le Bras

=head1 LICENSE

navel-hub is licensed under the Apache License, Version 2.0

=cut
