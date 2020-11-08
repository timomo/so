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
use SO::PVP;
use SO::Monster;
use SO::System;

plugin Config => { file => "so.conf.pl" };

$Storable::Deparse = 1;
$Storable::Eval = 1;

my $not_delivered = {};
my $loop = Mojo::IOLoop->singleton;
my $results = Mojo::Collection->new;
my $queue = Mojo::Collection->new;
my $characters = Mojo::Collection->new;
my $character_types = Mojo::Collection->new;
my $appends = Mojo::Collection->new;
my $messages = Mojo::Collection->new;
my @keys = @{app->config->{keys}};
my @keys2 = @{app->config->{keys2}};
my @keys3 = @{app->config->{keys3}};
my $sep = app->config->{sep};
my $new_line = app->config->{new_line};
my @default_parameter = @{app->config->{default_parameter}};
my $app;
my $clients = {};
my $dbis = {};
my $loops = {};
my $system = SO::System->new(context => app);
$system->open;

app->log->level(app->config->{log_level});

any "/message" => sub
{
    my $self = shift;
    my $json = $self->req->json;

    if ($self->req->method eq "POST")
    {
        my $dat = {};
        $dat->{送付元id} = $json->{id};
        $dat->{送付先id} = $json->{送付先id};
        $dat->{メッセージ} = $json->{メッセージ};
        my $id = $system->save_message($dat);
        my $mes = { method => "message", data => 1 };
        $self->unicast_send($mes, $json->{id}, $json->{送付先id});
        return $self->render(json => { result => $id });
    }
    else
    {
        my $rows = $system->load_message($json->{id});
        return $self->render(json => { result => $rows });
    }
};

get "/neighbors" => sub
{
    my $self = shift;
    my $json = $self->req->json;
    my $id = $json->{id};
    my $rand = $self->neighbors($id);
    my @ret;

    for my $append (@$rand)
    {
        my $c = $system->load_chara($append->{id});

        if (defined $c)
        {
            my $string = "";
            if ($self->is_battle($append->{id}))
            {
                $string = "(モンスター戦闘中)";
            }
            elsif ($self->is_pvp($append->{id}))
            {
                $string = "(PVP戦闘中)";
            }
            my $name = sprintf("%s Lv: %d%s", $c->{名前}, $c->{レベル}, $string);

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

        my $k = $system->load_append($id);
        my @keys = (qw|id エリア スポット 距離|);
        my $query = {};

        for my $key (@keys)
        {
            $query->{$key} = $k->{$key};
        }

        my $where = "id != :id and エリア = :エリア and スポット = :スポット and 距離 = :距離";
        my $result = $self->dbi("main")->model("キャラ追加情報1")->select(["*"], where => [$where, $query]);
        my $rows = $result->fetch_hash_all;
        my $neighbors = Mojo::Collection->new(@{$rows});
        my $rand = $neighbors->head(5);

        return $rand;
    },
);

get "/current" => sub
{
    my $self = shift;
    my $json = $self->req->json;
    my $id = $json->{id};
    my $k = $system->load_chara($id);

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

    if ($param->{mode} eq "pvp")
    {
        my $ids = $self->get_pvp_ids($id);

        if (defined $ids)
        {
            $param->{k1id} = $ids->[0];
            $param->{k2id} = $ids->[1];
        }
        else
        {
            $param->{mode} = "log_in";
        }
    }
    elsif ($param->{mode} eq "monster")
    {
        if ($self->is_battle($id))
        {
            # noop
        }
        else
        {
            $param->{mode} = "log_in";
        }
    }

    my $env = $self->tx->req->env || {};
    my $url = Mojo::URL->new;

    $url->query({ %$param, id => $k->{id}, pass => $k->{パスワード} });
    $env->{QUERY_STRING} = $url->to_string;
    $env->{QUERY_STRING} =~ s/^\?//;

    my $utf8 = $self->emulate_cgi($env);
    $self->reset_ini_all;

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
    my $k = $system->load_chara($self->param("id"));
    return $self->render(json => $k);
};

app->helper(
    command => sub
    {
        my $self = shift;
        my $json = shift;
        my $accept = $self->get_time_of_day;
        my $ret = { accept => $accept };

        push(@$queue, { id => $json->{const_id}, param => $json->{data}, "accept" => $accept });

        my $ref = {};
        $ref->{from} = $json->{const_id};
        $ref->{要求id} = $accept;
        $ref->{パラメータ} = YAML::XS::Dump($json->{data});
        $ref->{パラメータ} = Encode::decode_utf8($ref->{パラメータ});

        $self->dbi("main")->model("コマンド結果")->insert($ref, ctime => "ctime");

        $self->change_timer("manage", 1, sub {$self->manage});

        my $mes = { method => "command", data => $ret };
        $self->unicast_send($mes, $json->{const_id});

        return $ret;
    },
);

app->helper(
    state => sub
    {
        my $self = shift;
        my $id = shift;
        my $ai = SO::AI->new(context => $self, id => $id);
        $ai->open;
        my $state = $ai->state;
        $ai->close;

        return $state;
    },
);

app->helper(
    is_battle => sub
    {
        my $self = shift;
        my $id = shift;
        my $pvp = SO::Monster->new(context => $self);
        my $bool;

        $pvp->open;
        $bool = $pvp->is_battle($id);
        $pvp->close;

        return $bool;
    },
);

app->helper(
    is_pvp => sub
    {
        my $self = shift;
        my $id = shift;
        my $pvp = SO::PVP->new(context => $self);
        my $bool;

        $pvp->open;
        $bool = $pvp->is_pvp($id);
        $pvp->close;

        return $bool;
    },
);

app->helper(
    queue => sub
    {
        return $queue;
    },
);

app->helper(
    get_pvp_ids => sub
    {
        my $self = shift;
        my $id = shift;
        my $pvp = SO::PVP->new(context => $self);
        my $ids;

        $pvp->open;
        $ids = $pvp->get_pvp_ids($id);
        $pvp->close;

        return $ids;
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
    append_data => sub
    {
        my $self = shift;
        my $id = shift;
        my $result = $self->dbi("main")->model("キャラ追加情報1")->select(["*"], where => {id => $id});
        my $row = $result->fetch_hash_one;
        return $row;
    },
);

app->helper(
    character => sub
    {
        my $self = shift;
        my $id = shift;
        my $result = $self->dbi("main")->model("キャラ")->select(["*"], where => {id => $id});
        my $row = $result->fetch_hash_one;
        return $row;
    },
);

app->helper(
    save => sub
    {
        my $self = shift;
        my $path3 = File::Spec->catfile($FindBin::Bin, qw|save chara_type.dat|);
        my $file3 = Mojo::File->new($path3);

        $file3->touch;

        my @raw3;

        for my $k (@$characters)
        {
            my $result = $self->dbi("main")->model("キャラ")->select(["*"], where => {id => $k->{id}});
            my $row = $result->fetch_hash_one;
            my $ref = {};

            if (defined $row)
            {
                $ref = { %$row, %$k };
            }
            else
            {
                $ref = { %$k };
            }

            eval
            {
                if (defined $row)
                {
                    $self->dbi("main")->model("キャラ")->update($ref, where => {id => $ref->{id}}, mtime => "mtime");
                }
                else
                {
                    $self->dbi("main")->model("キャラ")->insert($ref, ctime => "ctime");
                }
            };
            if ($@)
            {
                warn $@;
                die $self->dump($ref);
            }

            $system->save_chara($ref);

            my $append = $system->load_append($ref->{id});

            if (! defined $append)
            {
                $append = {};
                @$append{@{$self->config->{keys2}}} = (
                    $k->{id},
                    $self->location($ref->{id}),
                    $k->{エリア},
                    $k->{スポット},
                    $k->{距離},
                    time
                );
                $system->save_append($append);
            }
            else
            {
                $append = $system->load_append($k->{id});
                if (defined $append)
                {
                    $system->save_append($append);
                }
            }
        }

        for my $type (@$character_types)
        {
            my @tmp2 = @$type{@keys3};
            push(@raw3, Encode::encode_utf8(join($sep, @tmp2)));
        }

        $file3->spurt(join($new_line, @raw3));

        warn "##### saved!!!!";
    },
);

app->helper(
    load_ini => sub
    {
        my $self = shift;
        my $path = shift;
        my $keys = shift;
        my $ret = $system->load_ini($path, $keys);
        return $ret;
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
    messages_from_file => sub
    {
        my ($self) = @_;
        my $path = File::Spec->catfile($FindBin::Bin, qw|save message.dat|);
        my $ret = $self->load_ini($path, [qw|送付元id 送付先id 送付元名前 メッセージ 送付先名前 受信日時|]);
        return $ret;
    },
);

app->helper(
    spawn => sub
    {
        my $self = shift;
        my $npc = $character_types->grep(sub { return $_->{操作種別} eq "npc" });

        if ($npc->size >= $self->config->{number_of_npc})
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

        $system->save_append($append);
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
        my $tmp = Mojo::Collection->new(@{$system->load_appends});
        my $hit = $tmp->first(sub { return $_->{id} eq $id });

        if (! defined $hit)
        {
            my $k = $system->load_chara($id);

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
            $system->save_append($hit);
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
        my $k = $system->load_chara($id);

        if (! defined $k)
        {
            return;
        }

        my $param = $command->{param};
        my $accept = $command->{accept};
        my $env = {};
        my $mode = $param->{mode};
        my $mode_prev = $self->location($id);

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

        my @ids = ($id);

        if ($param->{mode} eq "pvp")
        {
            delete $row->{id};

            for my $tmp_id ($param->{k1id}, $param->{k2id})
            {
                $row->{from} = $tmp_id;
                $self->dbi("main")->model("コマンド結果")->insert($row, ctime => "ctime");
                push(@ids, $row->{from});
            }
        }

        my $mes = { method => "result", data => { accept => $accept, } };

        $self->unicast_send($mes, @ids);
    },
);

app->helper(
    manage => sub
    {
        my ($self) = @_;
        # $self->log->debug("###############");

        # reload
        $self->reset_ini_all;

        if ($queue->size != 0)
        {
            my $command = pop(@$queue);
            if (defined $command)
            {
                # warn Dump($command);
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

            my $append = $system->load_append($type->{id});

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
            # warn Dump($npc_command);
            $ai->close;

            if (defined $npc_command)
            {
                $self->command({ const_id => $id, data => $npc_command });

                $append->{最終実行時間} = time();
                $system->save_append($append);

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

        $self->log->debug("----------------->$min, size=". $queue->size);

        if ($queue->size == 0)
        {
            $self->change_timer("manage", $min, sub {$self->manage});
        }
        else
        {
            $self->change_timer("manage", 1, sub {$self->manage});
        }
    },
);

app->helper(
    change_timer => sub
    {
        my $self = shift;
        my $key = shift;
        my $time = shift;
        my $cb = shift;

        $loop->remove($loops->{$key});
        $loops->{$key} = $loop->timer($time, $cb);
    },
);

app->helper(
    multicast_reload => sub
    {
        my $self = shift;
        my @ids = keys %$clients;
        my $mes = { method => "reload", data => 1 };

        $self->unicast_send($mes, @ids);
    },
);

app->helper(
    is_connection_state => sub
    {
        my ($self, $const_id) = @_;
        my $c = $clients->{$const_id};
        if (defined $c)
        {
            if ($c->is_finished)
            {
                return 1;
            }
            else
            {
                return 2;
            }
        }
        else
        {
            # そもそもない
            return 0;
        }
    },
);

app->helper(
    get_connection => sub
    {
        my ($self, $json) = @_;
        my $const_id = $json->{const_id};
        my $c = $clients->{$const_id};

        if (defined $c)
        {
            if ($c->is_finished)
            {
                $self->log->warn(sprintf("%s の接続が切れてます！", $const_id));
                delete $clients->{$const_id};
            }
            else
            {
                return $c;
            }
        }
        else
        {
            # そもそもない
        }
        return undef;
    },
);

app->helper(
    unicast_send => sub
    {
        my ($self, $data, @ids) = @_;

        for my $id (@ids)
        {
            my $state = $self->is_connection_state($id);

            if ($state == 0 || $state == 1)
            {
                $not_delivered->{$id} ||= Mojo::Collection->new;
                push(@{$not_delivered->{$id}}, $data);
            }
            elsif ($state == 2)
            {
                my $c = $self->get_connection({ const_id => $id });
                if (defined $c)
                {
                    $c->send({ json => $data });
                }
            }
        }
    },
);

app->helper(
    unicast_ping => sub
    {
        my ($self, @ids) = @_;

        for my $id (@ids)
        {
            my $data = { location => undef, time => undef };
            my $append = $appends->first(sub { return $_->{id} eq $id });
            if (defined $append)
            {
                $data->{location} = $append->{最終コマンド};
                $data->{time} = $append->{最終実行時間};
                my $mes = { method => "ping", data => $data };
                $self->unicast_send($mes, $id);
            }
        }
    },
);

app->helper(
    multicast_ping => sub
    {
        my ($self) = @_;
        my @ids = keys %$clients;
        $self->unicast_ping(@ids);
    },
);

app->helper(
    dbi => sub
    {
        my $self = shift;
        my $type = shift;
        return $system->dbi($type);
    },
);

app->helper(
    emulate_cgi => sub
    {
        my $self = shift;
        my $env = shift;
        $env->{"psgi.input"} ||= *STDIN;
        $env->{"psgi.errors"} ||= *STDERR;

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
    detach_history => sub
    {
        my ($self) = @_;
        my $dir = Mojo::File->new(File::Spec->catdir($FindBin::Bin, "save", "archive"));
        my $collection = $dir->list_tree->sort(sub { uc($b) cmp uc($a) });
        my $cnt = {
            command => 0,
            pvp     => 0,
            monster => 0,
        };

        for my $file (@$collection)
        {
            my $basename = $file->basename;
            if ($basename =~ /^(.+)\.(command|pvp|monster)\./)
            {
                $cnt->{$2}++;

                if ($cnt->{$2} > $self->config->{detach_history}->{$2})
                {
                    $self->log->debug(sprintf("detach_history によりファイル[%s]を削除しました。", $basename));
                    $file->remove;

                    $self->dbi("main")->model("コマンド結果")->delete(where => { 結果id => $1 });
                }
            }
        }
    },
);

app->helper(
    check_new_messages => sub
    {
        my ($self) = @_;
        my $ids = Mojo::Collection->new;

        $messages->each(sub
        {
            my $mes = shift;
            $mes->{受信日時} =~ s/\//-/g; # 2020/11/02 19:25
            $mes->{受信日時} .= ":00";

            my $query = {};
            $query->{送付元id} = $mes->{送付元id};
            $query->{送付先id} = $mes->{送付先id};
            $query->{メッセージ} = $mes->{メッセージ};
            $query->{受信日時} = $mes->{受信日時};

            my $result = $self->dbi("main")->model("メッセージ")->select(["*"], where => $query);
            my $row = $result->fetch_hash_one;

            if (defined $row)
            {
                # noop
            }
            else
            {
                # 送付元id 送付先id 送付元名前 メッセージ 送付先名前 受信日時

                my $dat = {};
                $dat->{送付元id} = $mes->{送付元id};
                $dat->{送付先id} = $mes->{送付先id};
                $dat->{送付元名前} = $mes->{送付元名前};
                $dat->{送付先名前} = $mes->{送付先名前};
                $dat->{メッセージ} = $mes->{メッセージ};
                $dat->{受信日時} = $mes->{受信日時};


                $self->dbi("main")->model("メッセージ")->insert($dat, ctime => "ctime");

                push(@$ids, $mes->{送付元id});
                push(@$ids, $mes->{送付先id});
            }
        });

        my $uniq = $ids->uniq();

        my $mes = { method => "message", data => 1 };

        $self->unicast_send($mes, @$uniq);
    },
);

app->helper(
    reset_ini_all => sub
    {
        my ($self) = @_;

        $character_types = Mojo::Collection->new;
        my $types = app->character_types;
        push(@$character_types, @$types);

        $appends = Mojo::Collection->new;
        my $tmp = $system->load_appends;
        push(@$appends, @$tmp);

        $characters = Mojo::Collection->new;
        my $all = $system->characters;
        push(@$characters, @$all);

        $messages = Mojo::Collection->new;
        $tmp = app->messages_from_file;
        push(@$messages, @$tmp);

        $self->check_new_messages;
    },
);

app->helper(
    range_rand => sub
    {
        my ($self) = @_;
        return $system->range_rand(@_);
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

        given ($json->{method})
        {
            when (/^ping$/)
            {
                my $const_id = $json->{const_id};
                $clients->{$const_id} = $tx;
                app->unicast_ping($const_id);

                # 一旦、未配送のデータを一気に送る
                if (exists $not_delivered->{$const_id})
                {
                    my $delivery = $not_delivered->{$const_id};
                    if ($delivery->size != 0)
                    {
                        while (my $data = shift(@$delivery))
                        {
                            app->unicast_send($data, $const_id);
                        }
                    }
                }
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

$loop->recurring(60, sub { app->detach_history });
$loop->recurring(60, sub { app->save });
$loop->timer(3, sub { app->manage });

app->start;
