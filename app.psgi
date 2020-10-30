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

push @{app->static->paths}, File::Spec->catdir($FindBin::Bin, qw|public js|);
push @{app->static->paths}, File::Spec->catdir($FindBin::Bin, qw|public css|);
push @{app->static->paths}, File::Spec->catdir($FindBin::Bin, qw|public sound|);

my @keys = (qw|
    id パスワード 名前 性別 画像 力 賢さ 信仰心 体力 器用さ 素早さ 魅力 HP 最大HP
    経験値 レベル 残りAP 所持金 LP 戦闘数 勝利数 ホスト 最終アクセス エリア スポット 距離 アイテム
|);

my $ua;

app->helper(
    backend_request => sub
    {
        my $self = shift;
        my $method = shift;
        my $url = shift;
        my $data = shift;

        $method = lc($method);

        $ua ||= Mojo::UserAgent->new;
        my $res;
        eval
        {
            $res = $ua->$method("127.0.0.1:3001$url" => json => $data)->result;
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
    }
);

app->helper(
    character => sub
    {
        my $self = shift;
        my $id = shift;
        my $path = File::Spec->catfile($FindBin::Bin, qw|save chara.dat|);
        my $file = Mojo::File->new($path);
        my @raw = split(/\r\n|\r|\n/, $file->slurp);

        for my $line (@raw)
        {
            chomp($line);
            my @tmp = split(/<>/, $line, 2);

            if ($tmp[0] ne $id)
            {
                next;
            }

            my @tmp2 = split(/<>/, Encode::decode_utf8($tmp[1]));

            for my $no (0 .. $#tmp2)
            {
                if ($tmp2[$no] =~ /^\d+$/)
                {
                    $tmp2[$no] *= 1;
                }
            }

            my $k = {};
            @$k{@keys} = ($tmp[0], @tmp2);

            return $k;
        }
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

get "/neighbors" => sub
{
    my $self = shift;
    my $k = $self->current_user;

    return $self->reply->not_found unless ($k);

    my $url = sprintf("/neighbors");
    my $utf8 = $self->backend_request("POST", $url, { id => $k->{id} });

    return $self->render(json => $utf8);
};

get "/current" => sub
{
    my $self = shift;
    my $k = $self->current_user;

    return $self->reply->not_found unless ($k);

    my $accept = $self->param("accept");
    my $url = sprintf("/current");
    my $utf8 = $self->backend_request("POST", $url, { "accept" => $accept, id => $k->{id} });

    return $self->render(text => $utf8 || "", format => 'html');
};

get "/is_result" => sub
{
    my $self = shift;
    my $json = $self->req->query_params->to_hash;

    delete $json->{pass};

    my $k = $self->current_user;

    return $self->reply->not_found unless ($k);

    my $url = sprintf("/is_result");

    my $utf8 = $self->backend_request("POST", $url, { %$json, id => $k->{id} });

    return $self->render(json => $utf8);
};

post "/command" => sub
{
    my $self = shift;
    my $json = $self->req->body_params->to_hash;

    delete $json->{pass};

    my $k = $self->current_user;

    return $self->reply->not_found unless ($k);

    my $url = sprintf("/command");

    my $utf8 = $self->backend_request("POST", $url, { %$json, id => $k->{id} });

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
    $self->redirect_to('/current');
};

get '/logout' => sub {
    my $self = shift;
    my $k = $self->current_user;

    return $self->reply->not_found unless ($k);

    $self->logout();
    $self->flash(confirmation => 'ログアウトしました');
    $self->redirect_to('/');
};

any "/direct" => sub
{
    my $self = shift;
    my $sub = CGI::Compile->compile(File::Spec->catfile($FindBin::Bin, 'so_index.pl'));
    my $app = CGI::Emulate::PSGI->handler($sub);
    my $env = $self->tx->req->env;
    $env->{"psgi.input"} ||= *STDIN;
    seek($env->{"psgi.input"}, 0, 0);

    warn Dump($env);

    my $content = join("", @{$app->($env)->[2]});
    my $utf8 = Encode::decode_utf8($content);

    return $self->render(text => $utf8, format => "html");
};

any "/" => sub
{
    my $self = shift;
    return $self->render('index');
};

app->start;
