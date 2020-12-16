#!/usr/bin/perl

use Plack::Builder;
use Plack::App::WrapCGI;
use Plack::App::Directory;
use File::Spec;
use FindBin;
use Mojolicious::Lite;
use Mojo::Server::PSGI;
use Mojolicious::Types;
use IO::Capture::Stdout;
use Encode;
use Data::Dumper;
use YAML::XS;
use Mojo::JSON;
use JSON;
use DBIx::Custom;
use Image::Magick;
use lib File::Spec->catdir($FindBin::RealBin, 'lib');
use SO::System;
use SO::Town;

push @{app->static->paths}, File::Spec->catdir($FindBin::Bin, qw|public js|);
push @{app->static->paths}, File::Spec->catdir($FindBin::Bin, qw|public css|);
push @{app->static->paths}, File::Spec->catdir($FindBin::Bin, qw|public sound|);
# push @{app->static->paths}, File::Spec->catdir($FindBin::Bin, qw|public img|);

plugin Config => { file => "so.conf.pl" };
plugin "Model" => {
    namespaces => ["SO"],
};

my $ua;
my $app;

my $system = app->entity("system");
my $town = app->entity("town");
$system->open;

app->helper(
    backend_request => sub
    {
        my $self = shift;
        my $method = shift;
        my $url = shift;
        my $data = shift;

        $method = lc($method);

        if ($method eq "get")
        {
            my $obj = Mojo::URL->new;
            $obj->query($data);
            $url .= $obj->to_string;
        }

        $ua ||= Mojo::UserAgent->new;
        my $res;
        eval
        {
            $res = $ua->$method($self->config->{url_of_world_server}. $url => json => $data)->result;
        };
        if ($@)
        {
            $self->log->warn("connect faild: " . $@);
        }

        if ($res) {
            if ($res->is_success) {
                my $content_type = $res->headers->content_type;
                if ($content_type =~ qr|^text/html|) {
                    return Encode::decode_utf8($res->body);
                }
                my $utf8;
                eval
                {
                    $utf8 = Mojo::JSON::decode_json($res->body);
                };
                if ($@)
                {
                    warn $@;
                    $self->log->error($@);
                }
                return $utf8;
            }
            elsif ($res->is_error) {
                $self->log->error($res->message);
            }
            elsif ($res->code == 301) {
                $self->log->warn($res->headers->location);
            }
            else {
                $self->log->warn('Whatever...');
            }
        }

        return;
    },
);

app->helper(
    character => sub
    {
        my $self = shift;
        my $id = shift;
        return $self->backend_request("GET", "/character/$id", {});
    },
);

plugin 'authentication',
    {
    autoload_user => 1,
    load_user     => sub
    {
        my $self = shift;
        my $id = shift;
        my $k = $self->character($id);
    },
    validate_user => sub
    {
        my $self = shift;
        my $id = shift || '';
        my $password = shift || '';
        my $k = $self->character($id);
        return ($k && $k->{パスワード} eq $password) ? $id : undef;
    },
};

any "/window/:name" => [ name => qr/(?:message|item|status)/ ] => sub
{
    my $self = shift;
    my $k = $self->current_user;

    return $self->reply->not_found unless ($k);

    my $param = $self->req->body_params->to_hash || {};
    my $json = $self->req->json || {};
    my $utf8 = $self->backend_request($self->req->method, $self->req->url->path->to_string, { id => $k->{id}, %$param, %$json });

    return $self->render(text => $utf8, format => "html");
};

any "/message" => sub
{
    my $self = shift;
    my $k = $self->current_user;

    return $self->reply->not_found unless ($k);

    my $param = $self->req->body_params->to_hash || {};
    my $json = $self->req->json || {};
    my $utf8 = $self->backend_request($self->req->method, $self->req->url->path->to_string, { id => $k->{id}, %$param, %$json });

    return $self->render(json => $utf8);
};

get "/neighbors" => sub
{
    my $self = shift;
    my $k = $self->current_user;

    return $self->reply->not_found unless ($k);

    my $param = $self->req->body_params->to_hash || {};
    my $json = $self->req->json || {};
    my $utf8 = $self->backend_request($self->req->method, $self->req->url->path->to_string, { id => $k->{id}, %$param, %$json });

    return $self->render(json => $utf8);
};

get "/location" => sub
{
    my $self = shift;
    my $k = $self->current_user;

    return $self->reply->not_found unless ($k);

    return $self->render(
        template => "window/location",
        kgold    => $k->{所持金},
        area     => $self->config->{街}->[$k->{エリア}],
        spot     => $self->get_spot_name($k),
        k        => $k,
    );
};

get "/status" => sub
{
    my $self = shift;
    my $k = $self->current_user;

    return $self->reply->not_found unless ($k);

    return $self->render(
        template => "window/status",
        kname    => $k->{名前},
        klv      => $k->{レベル},
        klp      => $k->{LP},
        max_lp   => 0,
        khp      => $k->{HP},
        kmaxhp   => $k->{最大HP},
        kex      => $k->{経験値},
        rrsk     => $k->{リスク},
        k        => $k,
    );
};

post "/instant" => sub
{
    my $self = shift;
    my $param = $self->req->body_params->to_hash || {};
    my $json = $self->req->json || {};

    delete $json->{pass};

    my $k = $self->current_user;

    return $self->reply->not_found unless ($k);

    my $utf8 = $self->backend_request($self->req->method, $self->req->url->path->to_string, { %$param, %$json, id => $k->{id} });

    return $self->render(text => $utf8 || "", format => 'html');
};

get "/current" => sub
{
    my $self = shift;
    my $k = $self->current_user;

    return $self->reply->not_found unless ($k);

    $self->cookie(id => $k->{id});

    my $accept = $self->param("accept");
    my $utf8 = $self->backend_request($self->req->method, $self->req->url->path->to_string, { "accept" => $accept, id => $k->{id} });

    return $self->render(text => $utf8 || "", format => 'html');
};

post "/event/:id" => sub
{
    my $self = shift;
    my $k = $self->current_user;

    return $self->reply->not_found unless ($k);

    my $param = $self->req->body_params->to_hash || {};
    my $json = $self->req->json || {};
    my $utf8 = $self->backend_request($self->req->method, $self->req->url->path->to_string, { %$param, %$json, id => $k->{id} });

    return $self->render(json => $utf8);
};

post "/command" => sub
{
    my $self = shift;
    my $param = $self->req->body_params->to_hash || {};
    my $json = $self->req->json || {};

    delete $json->{pass};

    my $k = $self->current_user;

    return $self->reply->not_found unless ($k);

    my $utf8 = $self->backend_request($self->req->method, $self->req->url->path->to_string, { %$param, %$json, id => $k->{id}, const_id => $k->{id} });

    return $self->render(json => $utf8);
};

post '/login' => sub
{
    my $self = shift;
    my $id = $self->param("id");
    my $password = $self->param("pass");

    unless ($self->authenticate($id, $password))
    {
        $self->flash(confirmation => 'ログインに失敗しました');
        return $self->redirect_to('/');
    }
    $self->flash(confirmation => 'ログインに成功しました');
    $self->redirect_to('/main');
};

get '/logout' => sub {
    my $self = shift;
    my $k = $self->current_user;

    return $self->reply->not_found unless ($k);

    $self->logout();
    $self->flash(confirmation => 'ログアウトしました');
    $self->redirect_to('/');
};

app->helper(
    emulate_cgi => sub
    {
        my $self = shift;
        my $env = shift;

        if (! defined $app)
        {
            my $sub = CGI::Compile->compile(File::Spec->catfile($FindBin::Bin, 'so_index.pl'));
            $app = CGI::Emulate::PSGI->handler($sub);
        }

        my $content = join("", @{$app->($env)->[2]});
        my $utf8 = Encode::decode_utf8($content);

        return $utf8;
    },
);

get "/main" => sub
{
    my $self = shift;
    my $k = $self->current_user;

    return $self->reply->not_found unless ($k);

    return $self->render(
        template    => "log_in_frame",
        kgold       => $k->{所持金},
        area        => $self->config->{街}->[$k->{エリア}],
        spot        => $self->get_spot_name($k),
        klv         => $k->{レベル},
        klp         => $k->{LP},
        max_lp      => 0,
        khp         => $k->{HP},
        kmaxhp      => $k->{最大HP},
        kex         => $k->{経験値},
        rrsk        => $k->{リスク},
        kid         => $k->{id},
        kname       => $k->{名前},
        const_id    => $k->{id},
        mode        => "log_in",
        info_array  => [
            "", "", "", "", "",
            "", "", "", "", "",
        ],
        select_menu => [],
        script      => "./",
        kpass       => "*****",
        k           => $k,
    );
};

get "/js/battle/spritesheet/character/:file" => sub
{
    my $self = shift;
    return $self->render(template => "json/spritesheet", format => "json");
};

get "/js/battle/spritesheet/monster/:file" => sub
{
    my $self = shift;
    return $self->render(template => "json/spritesheet_mon", format => "json");
};

get "/js/battle/spritesheet/ikon/:file" => sub
{
    my $self = shift;
    return $self->render(template => "json/spritesheet_ikon", format => "json");
};

get "/img/*file" => sub {
    my $self = shift;
    my $dir = "public/img";

    # $self->res->headers->header("Access-Control-Allow-Origin" => "*");
    warn "---------->". $self->param("file");

    if (my $asset = $self->app->static->file(File::Spec->catfile($FindBin::Bin, $dir, $self->param("file")))) {
        my $regex_suffix = qr/\.[^\.]+$/;
        my $suffix_txt = (fileparse($self->param("file"), $regex_suffix))[2];
        $suffix_txt =~ s/^\.//;

        # デフォルトは左向きとしたいので、右向きのキャラは反転させる
        if ($self->param("file") =~ /^mon_.+?\.gif$/) {
            my $image = Image::Magick->new();
            $image->Read($asset->path);
            $image->Flop;
            my $file = Mojo::File::tempfile(DIR => File::Spec->catdir($FindBin::Bin, 'tmp'));
            $image->Write($file->realpath . ".gif");
            $asset = Mojo::Asset::File->new(path => $file->realpath . ".gif");
        }

        $self->res->headers->content_type("image/" . $suffix_txt);
        return $self->reply->asset($asset);
    }
};

get "/test" => sub
{
    my $self = shift;
    my $path = File::Spec->catfile($FindBin::Bin, "Shimada Online.html");
    my $file = Mojo::File->new($path);
    my $contents = $file->slurp;
    my $utf8 = Encode::decode_utf8($contents);
    return $self->render(text => $utf8, format => "html");
};

any "/" => sub
{
    my $self = shift;
    my $k = $self->current_user;
    my $mode = $self->param("mode");

    return $self->redirect_to("/main") if ($k);

    my $env = $self->tx->req->env;
    $env->{"psgi.input"} ||= *STDIN;
    seek($env->{"psgi.input"}, 0, 0);

    my $param = {};

    if (! defined $mode)
    {
        return $self->render('index');
    }
    elsif ($mode eq "chara_make")
    {
        $param = { mode => "chara_make" };
    }
    elsif ($mode eq "make_end")
    {
        $param = { mode => "make_end" };

        for (qw|id sex pass c_name chara n_0 n_1 n_2 n_3 n_4 n_5 n_6 point|)
        {
            $param->{$_} = $self->param($_);
        }
    }
    elsif ($mode eq "regist")
    {
        $param = { mode => "regist" };

        for (qw|skill1 skill2 new id sex pass c_name chara n_0 n_1 n_2 n_3 n_4 n_5 n_6|)
        {
            $param->{$_} = $self->param($_);
        }
    }

    my $url = Mojo::URL->new;
    $url->query($param);
    $env->{QUERY_STRING} = $url->to_string;
    $env->{QUERY_STRING} =~ s/^\?//;

    my $utf8 = $self->emulate_cgi($env);

    return $self->render(text => $utf8, format => "html");
};

my $serverTxs = {};

app->helper(
    get_spot_name => sub
    {
        my $self = shift;
        my $k = shift;
        my $spot = "";
        my @names = keys @{$self->config->{街}};

        my $data = $town->load($k);

        # warn Dump($data);

        if($k->{スポット} == 0)
        {
            $spot = sprintf("郊外");
        }
        elsif($k->{スポット} == 1)
        {
            $spot = sprintf("%s まで残り %s", $data->{current}->{場所}, $data->{current}->{距離});
        }
        elsif($k->{スポット} == 2)
        {
            $spot = sprintf("%s まで残り %s", $data->{next}->{地名}, $data->{next}->{距離});
        }
        elsif($k->{スポット} == 3)
        {
            $spot = sprintf("%s まで残り %s", $data->{previous}->{地名}, $data->{previous}->{距離});
        }
        elsif($k->{スポット} == 4)
        {
            $spot = sprintf("街の中");
        }

        return $spot;
    },
);

app->helper(
    create_battle_ws => sub
    {
        my $self = shift;
        my $c = shift;
        my $clientTx = $c->tx;

        $ua ||= Mojo::UserAgent->new;

        $ua->websocket('ws://127.0.0.1:3001/channel' => sub
        {
            my ($ua, $tx) = @_;
            unless ($tx->is_websocket)
            {
                $clientTx->finish;
                return;
            }
            $tx->on(finish => sub
            {
                my ($tx, $code, $reason) = @_;

                $clientTx->send({ json => { method => "battle_server_disconnect", data => {} } });
                $self->log->info("WebSocket closed with status $code.");
                $clientTx->finish;
                delete $serverTxs->{sprintf("%s", $clientTx)};
            });
            $tx->on(json => sub
            {
                my ($tx, $msg) = @_;

                $clientTx->send({ json => $msg });
            });
            $self->log->info("WebSocket connected!: $tx");
            $serverTxs->{sprintf("%s", $clientTx)} = $tx;
        });
    },
);

app->helper(
    battle_request_ws => sub
    {
        my $self = shift;
        my $c = shift;
        my $method = shift;
        my $const_id = shift;
        my $data = shift;
        my $mes = { method => $method, const_id => $const_id, data => $data };
        my $txName = sprintf("%s", $c->tx);
        my $tx = $serverTxs->{$txName};

        return if (!$tx);

        $tx->send({ json => $mes });
    },
);

helper events => sub
{
    state $events = Mojo::EventEmitter->new
};

websocket '/channel' => sub
{
    my ($c) = @_;

    my $tx = $c->tx;
    Mojo::IOLoop->stream($tx->connection)->timeout(0);

    my $txName = sprintf("%s", $c->tx);

    app->create_battle_ws($c);

    $c->on(json => sub
    {
        my ($c, $json) = @_;

        my $id = $c->cookie("id");

        given ($json->{method})
        {
            when (/^ping$/)
            {
                app->battle_request_ws($c, "ping", $id, $json->{data});
            }
            when (/^command$/)
            {
                app->battle_request_ws($c, "command", $id, $json->{data});
            }
            when (/^difference$/)
            {
                app->battle_request_ws($c, "difference", $id, $json->{data});
            }
            when (/^reload/)
            {
                app->battle_request_ws($c, "difference", $id, $json->{data});
            }
        }
    });

    my $cb = $c->events->on(
        message => sub
        {
            my ($event, $json) = @_;
            $c->send({ json => $json });
        }
    );

    $c->on(finish => sub
    {
        my ($c) = @_;
        $c->events->unsubscribe(message => $cb);
    });
};

app->start;
