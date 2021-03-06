# Copyright (C) 2015-2017 Yoann Le Garff, Nicolas Boquet and Yann Le Bras
# navel-hub is licensed under the Apache License, Version 2.0

#-> BEGIN

#-> initialization

package Navel::Hub 0.1;

use Navel::Base;

use Mojo::JSON::MaybeXS;

use Mojo::Base 'Mojolicious';

# use Mojo::Pg;
use Mojo::URL;
use Mojo::Util 'secure_compare';

use Navel::API::OpenAPI::Hub;

#-> methods

sub startup {
    my $self = shift;

    $self->plugin('Config');
    $self->plugin('Navel::Mojolicious::Plugin::API::StdResponses');

    $self->app->sessions->cookie_name(__PACKAGE__);

    # $self->helper(
        # pg => sub {
            # state $pg = Mojo::Pg->new(shift->config('pg'));
        # }
    # );

    # $self->pg->auto_migrate(1)->migrations->from_file($self->home->child('sql', 'migrations.sql'));

    $self->hook( # https://metacpan.org/pod/Mojolicious::Plugin::OAuth2::Server
        around_action => sub {
            my ($next, $controller) = @_;

            state $is_authenticated = sub {
                my $controller = shift;

                return 1 if $controller->session('logged_in');

                my $url = $controller->req->url->to_abs;

                if (defined (my $userinfo = $url->userinfo)) {
                    my $username = $url->username;

                    my $users = $controller->config('users');

                    exists $users->{$username} && secure_compare(
                        $userinfo,
                        join ':', $username, $users->{$username} // ''
                    );
                }
            };

            if (defined $controller->stash('remote')) {
                return $controller->navel->api->responses->unauthorized unless $is_authenticated->($controller);
            } elsif (defined (my $openapi_op_spec = $controller->openapi->spec)) {
                return $controller->navel->api->responses->unauthorized if $openapi_op_spec->{responses}->{401} && ! $is_authenticated->($controller);
            }

            $next->();
        }
    );

    $self->hook(
        before_render => sub {
            my ($controller, $arguments) = @_;

            my (@ok, @ko);

            my $template = $arguments->{template} // '';

            if ($template eq 'exception') {
                push @ko, $controller->stash('exception')->message;
            } elsif ($template eq 'not_found') {
                push @ko, "the page you were looking for doesn't exist."
            } else {
                return;
            }

            $arguments->{json} = $controller->navel->api->definitions->ok_ko(\@ok, \@ko);
        }
    );

    $self->helper(
        'navel.storer_proxy_pass' => sub {
            state $proxy_pass = {
                remote => Mojo::URL->new($self->config('storer')),
                location => '/api/storer/proxy'
            };
        }
    );

    $self->helper(
        'navel.collector_managers_proxy_pass' => sub {
            state $proxy_pass = {};
        }
    );

    my $routes = $self->routes;

    $routes->any($self->navel->storer_proxy_pass->{location})->partial(1)->to(
        'RESTProxy#any',
        remote => $self->navel->storer_proxy_pass->{remote}
    );

    while (my ($collector_manager_name, $collector_manager_url) = each %{$self->config('collector_managers')}) {
        $self->navel->collector_managers_proxy_pass->{$collector_manager_name} = {
            remote => Mojo::URL->new($collector_manager_url),
            location => '/api/collector-managers/' . $collector_manager_name . '/proxy'
        };

        $routes->any($self->navel->collector_managers_proxy_pass->{$collector_manager_name}->{location})->partial(1)->to(
            'RESTProxy#any',
            remote => $self->navel->collector_managers_proxy_pass->{$collector_manager_name}->{remote}
        );
    }

    $self->plugin(
        OpenAPI => {
            url => Navel::API::OpenAPI::Hub->spec_file_location,
            coerce => {}, # empty hashtable is for 'coerce nothing'
            renderer => sub {
                my ($controller, $data) = @_;

                $data = $controller->navel->api->definitions->ok_ko([], $data->{errors}) if ref $data eq 'HASH' && ref $data->{errors} eq 'ARRAY';

                Mojolicious::Plugin::OpenAPI::_render_json($controller, $data);
            }
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

Navel::Hub

=head1 COPYRIGHT

Copyright (C) 2015-2017 Yoann Le Garff, Nicolas Boquet and Yann Le Bras

=head1 LICENSE

navel-hub is licensed under the Apache License, Version 2.0

=cut
