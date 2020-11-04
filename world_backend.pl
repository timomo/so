#!/usr/bin/env perl

package main;

use Mojolicious::Lite;
use Data::Dumper;
use Mojo::File;
use File::Spec;
use FindBin;
use Encode;
use Mojo::Collection;
use Storable;
# use Mojo::JSON;
use JSON;
# use Scalar::Util;
# use File::Basename;
# use Crypt::PasswdMD5;
# use Image::Magick;
use YAML::XS;
use DateTime;
use Math::Round;
use Mojo::UserAgent;
use Mojo::JSON;
use Mojo::EventEmitter;
use Mojo::Promise;
use Mojo::IOLoop;
use CGI::Compile;
use CGI::Emulate::PSGI;
use Time::HiRes;
use String::Random;
use DBIx::Custom;
# use String::Random;
# use Devel::Cycle;
use lib File::Spec->catdir($FindBin::Bin, "lib");
use SO::AI;

plugin Config => { file => "so.conf.pl" };

$Storable::Deparse = 1;
$Storable::Eval = 1;

my $loop = Mojo::IOLoop->singleton;
my $results = Mojo::Collection->new;
my $queue = Mojo::Collection->new;
my $characters = Mojo::Collection->new;
my $character_types = Mojo::Collection->new;
my $appends = Mojo::Collection->new;
my @keys = @{app->config->{keys}};
my @keys2 = @{app->config->{keys2}};
my @keys3 = @{app->config->{keys3}};
my $sep = app->config->{sep};
my $new_line = app->config->{new_line};
my @default_parameter = @{app->config->{default_parameter}};
my $app;
my $clients = {};
my $dbis = {};

app->log->level(app->config->{log_level});

get "/neighbors" => sub
{
    my $self = shift;
    my $json = $self->req->json;
    my $id = $json->{id};
    my $rand = $self->neighbors($id);
    my @ret;

    for my $append (@$rand)
    {
        my $c = $self->character($append->{id});

        if (defined $c)
        {
            my $bool = $self->is_battle($append->{id}) || $self->is_pvp($append->{id}) ? "(戦闘中)" : "";
            my $name = sprintf("%s Lv: %d%s", $c->{名前}, $c->{レベル}, $bool);

            push(@ret, [$c->{id}, $name]);
        }
    }

    return $self->render(json => {neighbors => \@ret});
};

app->helper(
    neighbors => sub
    {
        my $self = shift;
        my $id = shift;

        my $k = $self->character($id);
        my @ret = ();

        my $neighbors = $appends->grep(sub
        {
            my $append = shift;

            if ($k->{id} eq $append->{id})
            {
                return 0;
            }

            if ($k->{エリア} == $append->{エリア})
            {
                if ($k->{スポット} == $append->{スポット})
                {
                    if ($k->{距離} == $append->{距離}) {
                        return 1;
                    }
                }
            }

            return 0;
        });

        my $rand = $neighbors->head(5);

        return $rand;
    },
);

get "/current" => sub
{
    my $self = shift;
    my $json = $self->req->json;
    my $id = $json->{id};
    my $k = $self->character($id);

    if (! defined $k)
    {
        return $self->render("no_result");
    }

    if (exists $json->{accept} && ($json->{accept} || "") ne "")
    {
        my $hit = $results->first(sub { return $_->{id} eq $id && $_->{accept} eq $json->{accept} });

        if (! defined $hit) # 更新結果がメモリ上にない場合
        {
            my $path = File::Spec->catfile($FindBin::Bin, qw|save archive|, $json->{accept}. ".command.html");

            if (! -f $path)
            {
                return $self->render("no_result");
            }

            my $file = Mojo::File->new($path);
            my $utf8 = $file->slurp;

            if (defined $utf8)
            {
                my $enc = Encode::decode_utf8($utf8);
                return $self->render(text => $enc, format => "html");
            }
        }

        my $enc = Encode::decode_utf8($hit->{content});

        return $self->render(text => $enc, format => "html");
    }

    my $mode = $self->location($id);
    my $param = {};
    $param->{mode} = $mode || "log_in";

    my $env = $self->tx->req->env || {};
    my $url = Mojo::URL->new;

    $url->query({ %$param, id => $k->{id}, pass => $k->{パスワード} });
    $env->{QUERY_STRING} = $url->to_string;
    $env->{QUERY_STRING} =~ s/^\?//;

    my $utf8 = $self->emulate_cgi($env);

    return $self->render(text => $utf8, format => "html");
};

post "/command" => sub
{
    my $self = shift;
    my $json = $self->req->json;
    my $res = $self->command($json);
    return $self->render(json => $res);
};

get "/character/:id" => sub
{
    my $self = shift;
    my $k = $self->character($self->param("id"));
    return $self->render(json => $k);
};

app->helper(
    command => sub
    {
        my $self = shift;
        my $json = shift;
        my $accept = $self->get_time_of_day;
        my $ret = { accept => $accept };
        my $c = $self->get_connection($json);

        push(@$queue, { id => $json->{const_id}, param => $json->{data}, "accept" => $accept });

        my $ref = {};
        $ref->{from} = $json->{const_id};
        $ref->{要求id} = $accept;
        $ref->{パラメータ} = YAML::XS::Dump($json->{data});
        $ref->{パラメータ} = Encode::decode_utf8($ref->{パラメータ});

        $self->dbi("main")->model("コマンド結果")->insert($ref, ctime => "ctime");

        $loop->timer(1, sub { $self->manage });

        if (defined $c)
        {
            $c->send({ json => { method => "command", data => $ret } });
        }

        return $ret;
    },
);

app->helper(
    get_state => sub
    {
        my $self = shift;
        my $id = shift;
        my $k = $self->character($id);
        my $mode = $self->location($id);

        if (! defined $k)
        {
            return undef;
        }

        if ($self->is_battle($id) || $self->is_pvp($id)) { # 戦闘優先
            return "battle";
        }

        my $per = ($k->{HP} / $k->{最大HP}) * 100;

        if ($per < 30) # 回復優先
        {
            return "cure";
        }
        else # 探索優先
        {
            return "search";
        }
    },
);

app->helper(
    is_battle => sub
    {
        my $self = shift;
        my $id = shift;
        my $path = File::Spec->catfile($FindBin::Bin, qw|save battle|, $id. qw|.monster.yaml|);
        return -f $path;
    },
);

app->helper(
    is_pvp => sub
    {
        my $self = shift;
        my $id = shift;
        my $dir = Mojo::File->new(File::Spec->catdir($FindBin::Bin, "save", "battle"));
        my $collection = $dir->list_tree;

        for my $file (@$collection)
        {
            if ($file->basename !~ /\.pvp\.yaml$/)
            {
                next;
            }
            if ($file->basename =~ /$id/)
            {
                return 1;
            }
        }

        return 0;
    },
);

app->helper(
    get_pvp_ids => sub
    {
        my $self = shift;
        my $id = shift;

        my $dir = Mojo::File->new(File::Spec->catdir($FindBin::Bin, "save", "battle"));
        my $collection = $dir->list_tree;

        for my $file (@$collection)
        {
            if ($file->basename !~ /\.pvp\.yaml$/)
            {
                next;
            }
            if ($file->basename =~ /$id/)
            {
                my $name = $file->basename;
                $name =~ s/\.pvp\.yaml$//;
                my @tmp = split("_____", $name);

                return \@tmp;
            }
        }

        return undef;
    },
);

app->helper(
    get_time_of_day => sub
    {
        my $self = shift;
        my @tmp = Time::HiRes::gettimeofday;
        return join(".", @tmp);
    },
);

app->helper(
    character => sub
    {
        my $self = shift;
        my $id = shift;
        my $path = File::Spec->catfile($FindBin::Bin, qw|save chara.dat|);
        my $ret = $self->load_ini($path, \@keys);

        for my $k (@$ret)
        {
            if ($k->{id} eq $id)
            {
                return $k;
            }
        }

        return undef;
    },
);

app->helper(
    save => sub
    {
        my $self = shift;
        my $path = File::Spec->catfile($FindBin::Bin, qw|save chara.dat|);
        my $path3 = File::Spec->catfile($FindBin::Bin, qw|save chara_type.dat|);
        my $file = Mojo::File->new($path);
        my $file3 = Mojo::File->new($path3);

        $file->touch;
        $file3->touch;

        my @raw;
        my @raw3;

        for my $k (@$characters)
        {
            my @tmp = @{$k}{@keys};
            push(@raw, Encode::encode_utf8(join($sep, @tmp)));
        }

        for my $type (@$character_types)
        {
            my @tmp2 = @$type{@keys3};
            push(@raw3, Encode::encode_utf8(join($sep, @tmp2)));
        }

        $file->spurt(join($new_line, @raw));
        $file3->spurt(join($new_line, @raw3));

        warn "##### saved!!!!";
    },
);

app->helper(
    save_append => sub
    {
        my $self = shift;
        my $ref  = shift;
        my $path2 = File::Spec->catfile($FindBin::Bin, qw|save append.dat|);
        my $file2 = Mojo::File->new($path2);
        $file2->touch;
        my @raw2;
        my $hit = 0;

        for my $append (@$appends)
        {
            if ($append->{id} eq $ref->{id})
            {
                $append = $ref;
                $hit = 1;
            }
            my @tmp2 = @$append{@keys2};
            push(@raw2, Encode::encode_utf8(join($sep, @tmp2)));
        }

        if ($hit == 0)
        {
            my @tmp2 = @$ref{@keys2};
            push(@raw2, Encode::encode_utf8(join($sep, @tmp2)));
        }

        $file2->spurt(join($new_line, @raw2));
    },
);

app->helper(
    load_raw_ini => sub
    {
        my $self = shift;
        my $path = shift;
        my $file = Mojo::File->new($path);
        $file->touch;
        my @raw = split(/\r\n|\r|\n/, $file->slurp);
        my @ret;

        for my $line (@raw) {
            chomp($line);

            if ($line =~ /^$/) {
                next;
            }

            my @tmp2 = split(/<>/, Encode::decode_utf8($line));

            for my $no (0 .. $#tmp2)
            {
                if ($tmp2[$no] =~ /^\d+$/)
                {
                    $tmp2[$no] *= 1;
                }
            }

            push(@ret, \@tmp2);
        }

        return \@ret;
    },
);

app->helper(
    load_ini => sub
    {
        my $self = shift;
        my $path = shift;
        my $keys = shift;
        my $ret = $self->load_raw_ini($path);
        my @ret;

        for my $tmp (@$ret)
        {
            my $k = {};
            @$k{@$keys} = @$tmp;
            push(@ret, $k);
        }

        return \@ret;
    },
);

app->helper(
    character_types => sub
    {
        my $self = shift;
        my $path = File::Spec->catfile($FindBin::Bin, qw|save chara_type.dat|);
        my $ret = $self->load_ini($path, \@keys3);
        return $ret;
    },
);

app->helper(
    load_append => sub
    {
        my $self = shift;
        my $path = File::Spec->catfile($FindBin::Bin, qw|save append.dat|);
        my $ret = $self->load_ini($path, \@keys2);
        return $ret;
    },
);

app->helper(
    characters => sub
    {
        my $self = shift;
        my $path = File::Spec->catfile($FindBin::Bin, qw|save chara.dat|);
        my $ret = $self->load_ini($path, \@keys);
        return $ret;
    },
);

app->helper(
    spawn => sub
    {
        my $self = shift;
        my $npc = $character_types->grep(sub { return $_->{操作種別} eq "npc" });

        if ($npc->size > 1)
        {
            return;
        }

        my $n = {};
        my $hp = int(($default_parameter[3]) * 5 + 10);

        @$n{@keys} = (
            $self->create_uuid, # id
            $self->create_uuid, # パスワード
            "NPC:". ($character_types->size + 1), # 名前
            1, # 性別: 1 ... 女性
            "", # 画像
            @default_parameter, # 力 賢さ 信仰心 体力 器用さ 素早さ 魅力
            $hp, # HP
            $hp, # 最大HP
            0, # 経験値
            1, # レベル
            0, # 残りAP
            1000, # 所持金
            5, # LP
            0, # 戦闘数
            0, # 勝利数
            '127.0.0.1', # ホスト
            time(), # 最終アクセス
            0, # エリア
            0, # スポット
            0, # 距離
            0, # アイテム
        );

        my $t = {};
        @$t{@keys3} = (
            $n->{id},
            "npc",
        );

        my $append = {};
        @$append{@keys2} = (
            $n->{id},
            undef,
            $n->{エリア},
            $n->{スポット},
            $n->{距離},
            undef
        );

        push(@$appends, $append);
        push(@$character_types, $t);
        push(@$characters, $n);

        $self->save_append($append);
        $self->save;

        # $self->save;
    },
);

app->helper(
    create_uuid => sub
    {
        my ($self) = @_;
        return String::Random->new->randregex('[A-Za-z0-9]{10}');
    },
);

app->helper(
    location => sub
    {
        my $self = shift;
        my $id = shift;
        my $mode = shift;
        my $tmp = Mojo::Collection->new(@{$self->load_append});
        my $hit = $tmp->first(sub { return $_->{id} eq $id });

        if (! defined $hit)
        {
            my $k = $self->character($id);

            if (defined $k)
            {
                @$hit{@keys2} = ($k->{id}, undef, $k->{エリア}, $k->{スポット}, $k->{距離}, undef);
            }
        }

        if ($self->is_pvp($id))
        {
            $mode = "pvp";
        }
        elsif ($self->is_battle($id))
        {
            $mode = "monster";
        }

        # set
        if (defined $mode)
        {
            $hit->{最終コマンド} = $mode;
            $self->save_append($hit);
        }

        return $hit->{最終コマンド};
    },
);

app->helper(
    step_run => sub
    {
        my $self = shift;
        my $command = shift;
        my $id = $command->{id};
        my $k = $self->character($id);

        if (! defined $k)
        {
            return;
        }

        my $param = $command->{param};
        my $accept = $command->{accept};
        my $env = {};
        my $mode = $param->{mode};
        my $mode_prev = $self->location($id);

        $self->log->debug(sprintf("chara=%s, mode=%s, rid=%s", $id, $mode. $param->{rid} || ""));
        # warn Dump([$param, $accept]);

        my $url = Mojo::URL->new;
        $url->query({ %$param, id => $k->{id}, pass => $k->{パスワード} });
        $env->{QUERY_STRING} = $url->to_string;
        $env->{QUERY_STRING} =~ s/^\?//;

        my $utf8 = $self->emulate_cgi($env);
        my $enc = Encode::encode_utf8($utf8);

        my $file = Mojo::File->new(File::Spec->catfile($FindBin::Bin, qw|save archive|, $accept. ".command.html"));
        $file->spurt($enc);

        my $result = $self->dbi("main")->model("コマンド結果")->select(["*"], where => {要求id => $accept, from => $id});
        my $row = $result->fetch_hash_one;

        if (! defined $row)
        {
            $self->log->error("ジョブがない![". $accept. "]");
            return;
        }

        $row->{結果id} = $accept;

        $self->dbi("main")->model("コマンド結果")->update($row, where => {要求id => $accept}, mtime => "mtime");

        $self->reset_ini_all;

        # TODO: もしPVPなら、コマンド結果が2つ？

        warn Dump($param);

        if ($param->{mode} eq "pvp")
        {
            delete $row->{id};

            if ($param->{k1id} eq $id)
            {
                $row->{from} = $param->{k2id};
            }
            else
            {
                $row->{from} = $param->{k1id};
            }

            $self->dbi("main")->model("コマンド結果")->insert($row, ctime => "ctime");

            my $c = $self->get_connection({ const_id => $row->{from} });

            if (defined $c)
            {
                $c->send({ json => { method => "result", data => { accept => $accept, } } });
            }
        }

        # push(@$results, { "accept" => $accept, id => $id, content => $enc });

        my $mode_next = $self->location($id);

        my $c = $self->get_connection({ const_id => $id });

        if (defined $c)
        {
            $c->send({ json => { method => "result", data => { accept => $accept, } } });
        }

    },
);

app->helper(
    manage => sub
    {
        my ($self) = @_;
        $self->log->debug("###############");

        # reload
        $self->reset_ini_all;

        if ($queue->size != 0)
        {
            my $command = pop(@$queue);
            if (defined $command)
            {
                $self->step_run($command);
            }
        }

        $self->spawn;

        my $min = 9999;

        for my $type (@$character_types)
        {
            if (! exists $type->{id})
            {
                $self->log->warn("character_types に空データあり！");
                next;
            }

            my $append = $appends->first(sub { return $_->{id} eq $type->{id} });

            if (! defined $append || ! exists $append->{id})
            {
                $self->log->warn("appends に空データあり！");
                next;
            }

            my $timer = 15;
            my $time = $append->{最終実行時間} - time() + $timer;

            if ($time <= 0)
            {
                # noop
            }
            else
            {
                next;
            }

            my $id = $append->{id};

            my $ai = SO::AI->new(context => $self, id => $id);
            $ai->open;
            my $npc_command = $ai->command;
            warn Dump($npc_command);
            $ai->close;

            if (defined $npc_command)
            {
                $self->command({ const_id => $id, data => $npc_command });

                $append->{最終実行時間} = time();
                $self->save_append($append);

                {
                    my $time2 = $append->{最終実行時間} - time() + $timer;

                    if ($min < $time2)
                    {
                        $min = $time2;
                    }
                }
            }
        }

        if ($min == 9999)
        {
            $min = 15;
        }

        if ($min < 0)
        {
            $min = 1;
        }

        if ($queue->size == 0)
        {
            $loop->timer($min, sub { $self->manage });
        }
        else
        {
            $loop->timer(1, sub { $self->manage });
        }
    },
);

app->helper(
    multicast_reload => sub
    {
        my $self = shift;

        for my $id (keys %$clients)
        {
            my $c = $clients->{$id};
            my $mes = { method => "reload", data => 1 };
            $c->send({ json => $mes });
        }
    },
);

app->helper(
    get_connection => sub
    {
        my ($self, $json) = @_;
        my $const_id = $json->{const_id};
        my $c = $clients->{$const_id};

        if ($c && ! $c->is_finished)
        {
            return $c;
        }
        else
        {
            $self->log->warn(sprintf("%s の接続が切れてます！", $const_id));
            delete $clients->{$const_id};
        }
        return undef;
    },
);

app->helper(
    unicast_ping => sub
    {
        my ($self, $json) = @_;
        my $data = { location => undef, time => undef };
        my $const_id = $json->{const_id};
        my $c = $self->get_connection($json);
        my $append = $appends->first(sub { return $_->{id} eq $const_id });

        if (defined $append)
        {
            $data->{location} = $append->{最終コマンド};
            $data->{time} = $append->{最終実行時間};
        }

        if (defined $c)
        {
            warn "<------------------- ping";

            $c->send({ json => { method => "ping", data => $data } });
        }
    },
);

app->helper(
    multicast_ping => sub
    {
        my ($self) = @_;

        for my $id (keys %$clients)
        {
            $self->unicast_ping({ const_id => $id });
        }
    },
);

app->helper(
    dbi => sub
    {
        my $self = shift;
        my $type = shift;

        if ($type eq "main")
        {
            if (defined $dbis->{$type})
            {
                return $dbis->{$type};
            }

            my $dbFile = File::Spec->catfile($FindBin::Bin, "so.sqlite");
            my $dbi = DBIx::Custom->connect(
                "dbi:SQLite:dbname=$dbFile",
                undef,
                undef,
                { sqlite_unicode => 1 }
            );

            $dbi = $dbi->safety_character("\x{2E80}-\x{2FDF}々〇〻\x{3400}-\x{4DBF}\x{4E00}-\x{9FFF}\x{F900}-\x{FAFF}\x{20000}-\x{2FFFF}ーぁ-んァ-ヶa-zA-Z0-9_");
            $dbi->create_model("コマンド結果");

            $dbis->{$type} = $dbi;

            return $dbi;
        }
    },
);

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

app->helper(
    dump => sub
    {
        my ($self, $ref, $encode) = @_;
        my $context = Dump($ref);
        if (!defined $encode) {
            return Encode::decode_utf8($context);
        }
        return $context;
    }
);

app->helper(
    reset_ini_all => sub
    {
        my ($self) = @_;

        $character_types = Mojo::Collection->new;
        my $types = app->character_types;
        push(@$character_types, @$types);
        $appends = Mojo::Collection->new;
        my $tmp = app->load_append;
        push(@$appends, @$tmp);
        $characters = Mojo::Collection->new;
        my $all = app->characters;
        push(@$characters, @$all);
    },
);

helper events => sub {
    state $events = Mojo::EventEmitter->new
};

websocket '/channel' => sub {
    my ($c) = @_;

    my $tx = $c->tx;
    Mojo::IOLoop->stream($tx->connection)->timeout(0);

    $c->on(json => sub {
        my ($c, $json) = @_;

        warn "------------------->". $json->{method};

        given ($json->{method}) {
            when (/^ping$/)
            {
                my $const_id = $json->{const_id};
                $clients->{$const_id} = $tx;
                app->unicast_ping($json);
            }
            when (/^command$/)
            {
                app->command($json);
            }
            when (/^difference$/)
            {
                # app->battle_request_ws($c, "difference", $json->{data});
            }
            when (/^reload/)
            {
                # app->battle_request_ws($c, "difference", $json->{data});
            }
        }
    });

    my $cb = $c->events->on(
        message => sub {
            my ($event, $json) = @_;
            $c->send({ json => $json });
        }
    );

    $c->on(finish => sub {
        my ($c) = @_;

        for my $key (keys %$clients)
        {
            if ($clients->{$key} == $c)
            {
                delete $clients->{$key};
            }
        }

        $c->events->unsubscribe(message => $cb);
    });
};

$loop->timer(1, sub {
    app->reset_ini_all
});

$loop->recurring(60, sub { app->save });
$loop->timer(3, sub { app->manage });
# $loop->timer(5, sub { app->create_battle_ws_my });

app->start;
