#!/usr/bin/perl

use Plack::Builder;
use Plack::App::WrapCGI;
use Plack::App::Directory;
use File::Spec;
use FindBin;



builder {
    mount "/app" => Plack::App::WrapCGI->new(script => File::Spec->catfile($FindBin::Bin, 'so_app.pl'))->to_app;
    mount "/so_ctrl.cgi" => Plack::App::WrapCGI->new(script => File::Spec->catfile($FindBin::Bin, 'so_ctrl.pl'))->to_app;
    mount "/public/" => Plack::App::Directory->new(root => File::Spec->catdir($FindBin::Bin, 'public'))->to_app;
    mount "/" => Plack::App::WrapCGI->new(script => File::Spec->catfile($FindBin::Bin, 'so_index.pl'))->to_app;
};
