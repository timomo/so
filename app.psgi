#!/usr/bin/perl

use Plack::Builder;
use Plack::App::WrapCGI;
use Plack::App::File;
use File::Spec;
use FindBin;

builder {
    mount "/" => Plack::App::WrapCGI->new(script => File::Spec->catfile($FindBin::Bin, 'so_index.pl'))->to_app;
    mount "/so_item.cgi" => Plack::App::WrapCGI->new(script => File::Spec->catfile($FindBin::Bin, 'so_item.pl'))->to_app;
    mount "/so_ctrl.cgi" => Plack::App::WrapCGI->new(script => File::Spec->catfile($FindBin::Bin, 'so_ctrl.pl'))->to_app;
    mount "/so_battle.js" => Plack::App::File->new(file => File::Spec->catfile($FindBin::Bin, 'public',  'so_battle.js'))->to_app;
    mount "/so_town.js" => Plack::App::File->new(file => File::Spec->catfile($FindBin::Bin, 'public', 'so_town.js'))->to_app;
    mount "/so_common.css" => Plack::App::File->new(file => File::Spec->catfile($FindBin::Bin, 'public', 'so_common.css'))->to_app;
};
