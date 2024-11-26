#!/usr/bin/perl

use Plack::Builder;
use Plack::App::WrapCGI;
use Plack::App::File;

builder {
    mount "/" => Plack::App::WrapCGI->new(script => './so_index.pl', execute => 1)->to_app;
    mount "/js" => Plack::App::File->new(root => './public/js/')->to_app;
    mount "/css" => Plack::App::File->new(root => './public/css/')->to_app;
    mount "/sound" => Plack::App::File->new(root => './public/sound/')->to_app;
};