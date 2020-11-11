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
use Mojo::JSON;
use JSON;

push @{app->static->paths}, File::Spec->catdir($FindBin::Bin, qw|public js|);
push @{app->static->paths}, File::Spec->catdir($FindBin::Bin, qw|public css|);
push @{app->static->paths}, File::Spec->catdir($FindBin::Bin, qw|public sound|);

plugin Config => { file => "so.conf.pl" };

my $ua;
my $app;

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

any "/window/item" => sub
{
    my $self = shift;
    my $k = $self->current_user;

    return $self->reply->not_found unless ($k);

    if ($self->req->method eq "GET")
    {
        my $utf8 = $self->backend_request("get", "/window/item", { id => $k->{id} });
        return $self->render(text => $utf8, format => "html");
    }
    else
    {
        my $json = $self->req->body_params->to_hash;
        my $utf8 = $self->backend_request("post", "/window/item", { id => $k->{id}, %$json });
        return $self->render(text => $utf8, format => "html");
    }
};

any "/message" => sub
{
    my $self = shift;
    my $k = $self->current_user;

    return $self->reply->not_found unless ($k);

    if ($self->req->method eq "GET")
    {
        my $utf8 = $self->backend_request("get", "/message", { id => $k->{id} });
        return $self->render(json => $utf8);
    }
    else
    {
        my $json = $self->req->body_params->to_hash;
        my $utf8 = $self->backend_request("post", "/message", { id => $k->{id}, %$json });
        return $self->render(json => $utf8);
    }
};

get "/neighbors" => sub
{
    my $self = shift;
    my $k = $self->current_user;

    return $self->reply->not_found unless ($k);

    my $utf8 = $self->backend_request("get", "/neighbors", { id => $k->{id} });

    return $self->render(json => $utf8);
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
        rrsk     => 0,
    );
};

get "/current" => sub
{
    my $self = shift;
    my $k = $self->current_user;

    return $self->reply->not_found unless ($k);

    $self->cookie(id => $k->{id});

    my $accept = $self->param("accept");
    my $utf8 = $self->backend_request("get", "/current", { "accept" => $accept, id => $k->{id} });

    return $self->render(text => $utf8 || "", format => 'html');
};

post "/command" => sub
{
    my $self = shift;
    my $json = $self->req->body_params->to_hash;

    delete $json->{pass};

    my $k = $self->current_user;

    return $self->reply->not_found unless ($k);

    my $utf8 = $self->backend_request("POST", "/command", { %$json, id => $k->{id} });

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
        area        => $k->{エリア},
        spot        => $k->{スポット},
        klv         => $k->{レベル},
        klp         => $k->{LP},
        max_lp      => 0,
        khp         => $k->{HP},
        kmaxhp      => $k->{最大HP},
        kex         => $k->{経験値},
        rrsk        => 0,
        kid         => $k->{id},
        kname       => $k->{名前},
        const_id    => $k->{id},
        mode        => "log_in",
        info_array  => [],
        select_menu => [],
        script      => "./",
        kpass       => "test",
    );
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
