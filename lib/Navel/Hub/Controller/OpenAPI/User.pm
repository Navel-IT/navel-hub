# Copyright (C) 2015-2017 Yoann Le Garff, Nicolas Boquet and Yann Le Bras
# navel-hub is licensed under the Apache License, Version 2.0

#-> BEGIN

#-> initialization

package Navel::Hub::Controller::OpenAPI::User 0.1;

use Navel::Base;

use Mojo::Base 'Mojolicious::Controller';

#-> methods

sub login {
    my $controller = shift->openapi->valid_input || return;

    my (@ok, @ko);

    my $users = $controller->config('users');
    my $userinfo = $controller->validation->param('userinfo');

    push @ko, 'wrong username' unless exists $users->{$userinfo->{username}};
    push @ko, 'wrong password' unless $userinfo->{password} eq $users->{$userinfo->{username}};

    unless (@ko) {
        $controller->session(
            logged_in => 1
        );

        $controller->session(
            username => $userinfo->{username}
        );
    } else {
        push @ok, 'successfully logged in';
    }

    $controller->render(
        openapi => $controller->navel->api->definitions->ok_ko(\@ok, \@ko),
        status => @ko ? 403 : 201
    );
}

sub logout {
    my $controller = shift->openapi->valid_input || return;

    my (@ok, @ko);

    if ($controller->session('logged_in')) {
        $controller->session(
            expires => 1
        );

        push @ok, 'user successfully logged out';
    } else {
        push @ko, 'this user is not logged in';
    }

    $controller->render(
        openapi => $controller->navel->api->definitions->ok_ko(\@ok, \@ko),
        status => @ko ? 400 : 200
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

Navel::Hub::Controller::OpenAPI::User

=head1 COPYRIGHT

Copyright (C) 2015-2017 Yoann Le Garff, Nicolas Boquet and Yann Le Bras

=head1 LICENSE

navel-hub is licensed under the Apache License, Version 2.0

=cut
