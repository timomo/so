#!/usr/bin/perl

use Plack::Builder;
use Plack::App::WrapCGI;
use Plack::App::Directory;
use File::Spec;
use FindBin;
use Mojolicious::Lite;
use Mojo::Server::PSGI;
use IO::Capture::Stdout;
use Encode;
use Data::Dumper;
use YAML::XS;

push @{app->static->paths}, File::Spec->catdir($FindBin::Bin, qw|public js|);
push @{app->static->paths}, File::Spec->catdir($FindBin::Bin, qw|public css|);
push @{app->static->paths}, File::Spec->catdir($FindBin::Bin, qw|public sound|);

any "/" => sub
{
    my $self = shift;
    my $sub = CGI::Compile->compile(File::Spec->catfile($FindBin::Bin, 'so_index.pl'));
    my $app = CGI::Emulate::PSGI->handler($sub);
    seek($self->tx->req->env->{"psgi.input"}, 0, 0);
    my $content = join("", @{$app->($self->tx->req->env)->[2]});
    my $utf8 = Encode::decode_utf8($content);

    return $self->render(text => $utf8, format => "html");
};

app->start;
