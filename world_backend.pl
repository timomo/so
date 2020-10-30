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
use lib File::Spec->catdir($FindBin::Bin, "lib");
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
# use String::Random;
# use Devel::Cycle;

plugin Config => { file => 'so.conf.pl' };

my $loop = Mojo::IOLoop->singleton;

$Storable::Deparse = 1;
$Storable::Eval = 1;

my $instances = {};
my $loopIds = {};
my $battleTx = {};
my $appTx = {};
my $ua;
my $serverTxs = {};
my $myTx;
my $active = [];
my $archive = [];
my $results = Mojo::Collection->new;
my $queue = Mojo::Collection->new;
my $characters = Mojo::Collection->new;
my @keys = (qw|
    id パスワード 名前 性別 画像 力 賢さ 信仰心 体力 器用さ 素早さ 魅力 HP 最大HP
    経験値 レベル 残りAP 所持金 LP 戦闘数 勝利数 ホスト 最終アクセス エリア スポット 距離 アイテム
|);
my @keys2 = (qw|id 操作種別 最終コマンド エリア スポット 距離 最終実行時間|);
my $character_types = Mojo::Collection->new;
my $sep = "<>";
my $new_line = "\r\n";
my @default_parameter = (5, 5, 5, 5, 5, 5, 5);

app->log->level('debug');

post "/is_result" => sub
{
    my $self = shift;
    my $json = $self->req->json;
    my $id = $json->{id};

    # warn Dump($json);

    if (exists $json->{accept} && $json->{accept} ne "")
    {
        my $hit = $results->first(sub { return $_->{id} eq $id && $_->{accept} eq $json->{accept} });

        if (defined $hit)
        {
            return $self->render(json => { result => "done" });
        }
    }
    return $self->render(json => { result => "yet" });
};

post "/neighbors" => sub
{
    my $self = shift;
    my $json = $self->req->json;
    my $id = $json->{id};
    my $rand = $self->neighbors($id);
    my @ret;

    for my $append (@$rand)
    {
        my $c = $self->character($append->{id});

        if (defined $c) {

            my $bool = $self->is_battle($append->{id}) ? ": 戦闘中" : "";

            push(@ret, $c->{名前}. $bool);
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

        my $neighbors = $character_types->grep(sub
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

post "/current" => sub
{
    my $self = shift;
    my $json = $self->req->json;
    my $id = $json->{id};
    my $k = $self->character($id);

    if (! defined $k) {
        return;
    }

    if (exists $json->{accept} && ($json->{accept} || "") ne "")
    {
        my $hit = $results->first(sub { return $_->{id} eq $id && $_->{accept} eq $json->{accept} });
        return $self->render(text => $hit->{content}, format => "html");
    }

    my $mode = app->location($id);
    my $param = {};
    $param->{mode} = $mode || "log_in";

    my $sub = CGI::Compile->compile(File::Spec->catfile($FindBin::Bin, 'so_index.pl'));
    my $app = CGI::Emulate::PSGI->handler($sub);
    my $env = $self->tx->req->env || {};

    my $url = Mojo::URL->new;
    $url->query({ %$param, id => $k->{id}, pass => $k->{パスワード} });
    $env->{QUERY_STRING} = $url->to_string;

    $env->{QUERY_STRING} =~ s/^\?//;
    # seek($env->{"psgi.input"}, 0, 0);
    my $content = join("", @{$app->($env)->[2]});
    my $utf8 = Encode::decode_utf8($content);

    return $self->render(text => $utf8, format => "html");
};

post "/command" => sub
{
    my $self = shift;
    my $json = $self->req->json;
    my $id = delete $json->{id};
    my $accept = $self->get_time_of_day;

    push(@$queue, { id => $id, param => $json, "accept" => $accept });

    $loop->timer(1, sub { $self->manage });

    return $self->render(json => {accept => $accept});
};

app->helper(
    state => sub
    {
        my $self = shift;
        my $id = shift;
        my $k = $self->character($id);
        my $mode = $self->location($id);

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
    get_npc_command => sub
    {
        my $self = shift;
        my $id = shift;
        my $k = $self->character($id);
        my $mode = $self->location($id);
        my $state = $self->state($id);

        if ($state eq "battle")
        {
            if ($self->is_pvp($id))
            {
                warn sprintf("battle: PVP中: id = %s, パスワード = %s, スポット = %s, エリア = %s, 距離 = %s", $k->{id}, $k->{パスワード}, $k->{スポット}, $k->{エリア}, $k->{距離});
                return { mode => "pvp" };
            }
            else
            {
                warn sprintf("battle: 戦闘中: id = %s, パスワード = %s, スポット = %s, エリア = %s, 距離 = %s", $k->{id}, $k->{パスワード}, $k->{スポット}, $k->{エリア}, $k->{距離});
                return { mode => "monster" };
            }
        }
        elsif ($state eq "search")
        {
            if ($k->{スポット} == 0 && $k->{距離} == 0) # どこかの街の中
            {
                warn sprintf("search: 街の中: id = %s, パスワード = %s, スポット = %s, エリア = %s, 距離 = %s", $k->{id}, $k->{パスワード}, $k->{スポット}, $k->{エリア}, $k->{距離});
                return {
                    mode => "monster",
                    area => $k->{エリア},
                    spot => 0,
                };
            }
            else # 近辺を探索中
            {
                # TODO: PKキャラなら、敵を探し、僧侶系なら、辻ヒールを行う。それ以外なら、応援か素通り
                my $neighbors = Mojo::Collection->new(@{$self->neighbors($id)});
                my $shuffle = $neighbors->shuffle;
                my $target_append = $shuffle->head(1)->last;

                if (defined $target_append)
                {
                    if ($mode ne "message")
                    {
                        return {
                            mode  => "message",
                            mesid => $target_append->{id},
                            mes   => "これはNPC " . $k->{名前} . " からのメッセージ送信テストです。絶賛開発中です。",
                            name  => $k->{名前},
                        };
                    }
                    elsif (1)
                    {
                        # 今の所、決め打ちで、襲い掛かる
                        warn sprintf("search: ユーザを見て襲いかかる: id = %s, パスワード = %s, スポット = %s, エリア = %s, 距離 = %s", $k->{id}, $k->{パスワード}, $k->{スポット}, $k->{エリア}, $k->{距離});
                        return {
                            mode => "pvp",
                            rid  => $target_append->{id},
                        };
                    }
                    else # 一度メッセージを送ったら、去る
                    {
                        warn sprintf("search: ユーザを見て去る: id = %s, パスワード = %s, スポット = %s, エリア = %s, 距離 = %s", $k->{id}, $k->{パスワード}, $k->{スポット}, $k->{エリア}, $k->{距離});
                        return {
                            mode => "monster",
                            area => $k->{エリア},
                            spot => 0,
                        };
                    }
                }
                else
                {
                    warn sprintf("search: 近辺探索中: id = %s, パスワード = %s, スポット = %s, エリア = %s, 距離 = %s", $k->{id}, $k->{パスワード}, $k->{スポット}, $k->{エリア}, $k->{距離});
                    return {
                        mode => "monster",
                        area => $k->{エリア},
                        spot => 0,
                    };
                }
            }
        }
        elsif ($state eq "cure")
        {
            if ($k->{スポット} == 0 && $k->{距離} == 0) # どこかの街の中
            {
                warn sprintf("cure: 街の中: id = %s, パスワード = %s, スポット = %s, エリア = %s, 距離 = %s, 前回コマンド = %s, HP = %s", $k->{id}, $k->{パスワード}, $k->{スポット}, $k->{エリア}, $k->{距離}, $mode, $k->{HP});
                if ($mode ne "yado")
                {
                    return {
                        mode => "yado",
                        area => $k->{エリア},
                    };
                }
                elsif ($mode eq "yado")
                {
                    return {
                        inn_no => 0,
                        mode => "yado_in",
                        area => $k->{エリア},
                    };
                }
            }
            else # 近辺を探索中
            {
                if ($k->{所持金} >= 9000) { # 一旦、所持金チェックは決め打ちで。。。
                    warn sprintf("cure: 近辺探索中で街へ: id = %s, パスワード = %s, スポット = %s, エリア = %s, 距離 = %s", $k->{id}, $k->{パスワード}, $k->{スポット}, $k->{エリア}, $k->{距離});
                    return {
                        mode => "monster",
                        area => $k->{エリア},
                        spot => 1,
                    };
                }
                else
                {
                    warn sprintf("cure: 近辺探索中で休憩: id = %s, パスワード = %s, スポット = %s, エリア = %s, 距離 = %s", $k->{id}, $k->{パスワード}, $k->{スポット}, $k->{エリア}, $k->{距離});
                    return {
                        mode => "rest",
                        area => $k->{エリア},
                        spot => 2,
                    };
                }
            }
        }

        return undef;
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

app->helper(
    save => sub
    {
        my $self = shift;
        my $path = File::Spec->catfile($FindBin::Bin, qw|save chara.dat|);
        my $path2 = File::Spec->catfile($FindBin::Bin, qw|save append.dat|);
        my $file = Mojo::File->new($path);
        my $file2 = Mojo::File->new($path2);
        $file->touch;
        $file2
            ->touch;
        my @raw;
        my @raw2;

        for my $k (@$characters)
        {
            my @tmp = @{$k}{@keys};
            push(@raw, Encode::encode_utf8(join($sep, @tmp)));
            my @tmp2;
            push(@tmp2, $k->{id}); # id
            push(@tmp2, $k->{操作種別}); # 操作種別
            push(@tmp2, $k->{mode} || ""); # 最終コマンド
            push(@tmp2, $k->{エリア});
            push(@tmp2, $k->{スポット});
            push(@tmp2, $k->{距離});
            push(@raw2, Encode::encode_utf8(join($sep, @tmp2)));
        }

        $file->spurt(join($new_line, @raw));
        $file2->spurt(join($new_line, @raw2));
    },
);

app->helper(
    character_types => sub
    {
        my $self = shift;
        my $path = File::Spec->catfile($FindBin::Bin, qw|save append.dat|);
        my $file = Mojo::File->new($path);
        my @raw = split(/\r\n|\r|\n/, $file->slurp);
        my @ret;

        for my $line (@raw)
        {
            chomp($line);
            my @tmp = split(/<>/, $line, 2);
            my @tmp2 = split(/<>/, Encode::decode_utf8($tmp[1]));

            for my $no (0 .. $#tmp2)
            {
                if ($tmp2[$no] =~ /^\d+$/)
                {
                    $tmp2[$no] *= 1;
                }
            }

            my $k = {};
            @$k{@keys2} = ($tmp[0], @tmp2);

            push(@ret, $k);
        }

        return \@ret;
    },
);

app->helper(
    characters => sub
    {
        my $self = shift;
        my $path = File::Spec->catfile($FindBin::Bin, qw|save chara.dat|);
        my $file = Mojo::File->new($path);
        my @raw = split(/\r\n|\r|\n/, $file->slurp);
        my @ret;

        for my $line (@raw)
        {
            chomp($line);
            my @tmp = split(/<>/, $line, 2);
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

            # TODO: $character_types は読み込んでいる前提で

            my $hit = $character_types->first(sub { return $_->{id} eq $k->{id} });

            if (defined $hit)
            {
                $k->{操作種別} = $hit->{type};
            }
            else
            {
                $k->{操作種別} = "npc";
            }

            push(@ret, $k);
        }

        return \@ret;
    },
);

app->helper(
    spawn => sub
    {
        my $self = shift;

        my $npc = $character_types->grep(sub { return $_->{操作種別} eq "npc" });

        if ($npc->size >= 100)
        {
            return;
        }

        my $n = {};
        my $hp = int(($default_parameter[3]) * 5 + 10);

        @$n{@keys} = (
            $self->create_uuid, # id
            $self->create_uuid, # パスワード
            "NPC:". ($npc->size + 1), # 名前
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

        $n->{操作種別} = "npc";

        push(@$characters, $n);

        $self->save;
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

        my $hit = $characters->first(sub { return $_->{id} eq $id });

        if (! defined $hit)
        {
            warn $id;

            my $k = $self->character($id);
            push(@$characters, $k);

            $hit = $k;

            # TODO: 現在地を割り出す
        }

        # set
        if (defined $mode) {
            $hit->{mode} = $mode;
        }

        return $hit->{mode};
    },
);

app->helper(
    step_run => sub
    {
        my $self = shift;
        my $command = shift;
        my $id = $command->{id};

        my $k = $self->character($id);

        if (! defined $k) {
            return;
        }

        my $param = $command->{param};
        my $accept = $command->{accept};
        my $sub = CGI::Compile->compile(File::Spec->catfile($FindBin::Bin, 'so_index.pl'));
        my $app = CGI::Emulate::PSGI->handler($sub);
        my $env = {};

        my $mode = $param->{mode};
        $self->location($id, $mode);

        warn sprintf("chara=%s, mode=%s", $id, $mode);
        warn Dump([$param, $accept]);

        my $url = Mojo::URL->new;
        $url->query({ %$param, id => $k->{id}, pass => $k->{パスワード} });
        $env->{QUERY_STRING} = $url->to_string;
        $env->{QUERY_STRING} =~ s/^\?//;
        # seek($env->{"psgi.input"}, 0, 0);
        my $content = join("", @{$app->($env)->[2]});
        my $utf8 = Encode::decode_utf8($content);

        # my $tmp = Mojo::File->new(File::Spec->catfile($FindBin::Bin, "save", "archive", $accept. ".result.html"));
        # $tmp->touch;
        # $tmp->spurt($content);

        push(@$results, { "accept" => $accept, id => $id, content => $utf8 });
    },
);

app->helper(
    manage => sub
    {
        my ($self) = @_;
        warn "###############";
        $self->log->debug("###############");

        if ($queue->size != 0) {
            my $command = pop(@$queue);
            if (defined $command) {
                $self->step_run($command);
            }
        }

        $self->spawn;

        for my $append (@$character_types)
        {
            my $id = $append->{id};

            my $npc_command = $self->get_npc_command($id);

            if (defined $npc_command)
            {
                my $accept = $self->get_time_of_day;

                push(@$queue, { id => $id, param => $npc_command, "accept" => $accept });
            }
        }

        $loop->timer(60, sub { $self->manage });
    },
);

app->helper(
    multicast_reload => sub {
        my $self = shift;
        my $uuid = shift;

        for my $id (keys %{$battleTx->{$uuid}}) {
            my $const_id = $battleTx->{$uuid}->{$id}->{const_id};
            my $c = $myTx;
            my $mes = { method => "reload", data => 1 };
            $c->send({ json => $mes });
        }
    },
);

app->helper(
    multicast_ping => sub {
        my ($self, $data) = @_;
        my $const_id = "dummy";
        my $c = $myTx;
        my $mes = { method => "ping", data => $data };

        $self->log->debug(ref $c);

        if ($c && ! $c->is_finished) {
            $self->log->debug($self->dump($mes));
            $c->send({ json => $mes });
        }
        else
        {
            $myTx = undef;
            $loop->timer(1, sub {app->create_battle_ws_my});
        }
    },
);

app->helper(
    create_battle_ws_my => sub {
        my $self = shift;

        warn "here";

        if (! defined $myTx) {

            $self->log->debug("create_battle_ws_my start");

            $ua ||= Mojo::UserAgent->new;

            $ua->websocket('ws://127.0.0.1:3000/channel3' => sub {
                my ($ua, $tx) = @_;

                # warn YAML::XS::Dump($tx->res->to_string);

                unless ($tx->is_websocket) {
                    $self->log->info("WebSocketのハンドシェイクに失敗");
                    if (defined $myTx) {
                        $myTx->finish;
                    }
                    $myTx = undef;
                    $loop->timer(5, sub {$self->create_battle_ws_my()});
                    return;
                }
                $tx->on(finish => sub {
                    my ($tx, $code, $reason) = @_;
                    $self->log->info("my:WebSocket closed with status $code.");
                    $myTx->finish;
                    $myTx = undef;
                    $loop->timer(5, sub {$self->create_battle_ws_my()});
                });
                $tx->on(json => sub {
                    my ($tx, $json) = @_;

                    return if (! exists $json->{data});

                    given ($json->{method}) {
                        when (/^active$/) {
                            $active = $json->{data};
                        }
                        when (/^archive$/) {
                            $archive = $json->{data};
                        }
                        default {
                            $self->log->debug(Dump($json));
                        }
                    }

                });

                $self->log->info("my:WebSocket connected!: $tx");
                $myTx = $tx;
            });
        }
    },
);

app->helper(
    create_battle_ws => sub {
        my $self = shift;
        my $c = shift;
        my $clientTx = $c->tx;

        $ua ||= Mojo::UserAgent->new;

        $ua->websocket('ws://127.0.0.1:3000/channel3' => sub {
            my ($ua, $tx) = @_;
            unless ($tx->is_websocket) {
                $clientTx->finish;
                return;
            }
            $tx->on(finish => sub {
                my ($tx, $code, $reason) = @_;

                $clientTx->send({ json => { method => "battle_server_disconnect", data => {} } });

                $self->log->info("WebSocket closed with status $code.");
                $clientTx->finish;
                delete $serverTxs->{sprintf("%s", $clientTx)};
            });
            $tx->on(json => sub {
                my ($tx, $msg) = @_;
                $clientTx->send({ json => $msg });
            });
            $self->log->info("WebSocket connected!: $tx");
            $serverTxs->{sprintf("%s", $clientTx)} = $tx;
        });
    },
);

app->helper(
    battle_request => sub {
        my $self = shift;
        my $method = shift;
        my $url = shift;
        my $data = shift;

        $method = lc($method);

        $ua ||= Mojo::UserAgent->new;
        my $res;
        eval {
            $res = $ua->$method("127.0.0.1:3000$url" => json => $data)->result;
        };
        if ($@) {
            $self->log->warn("connect faild: " . $@);
        }

        if ($res) {
            if ($res->is_success) {
                my $content_type = $res->headers->content_type;
                if ($content_type =~ qr|^text/html|) {
                    return Encode::decode_utf8($res->body);
                }
                return JSON->new->utf8->decode($res->body);
            }
            elsif ($res->is_error) {
                say $res->message
            }
            elsif ($res->code == 301) {
                say $res->headers->location
            }
            else {
                say 'Whatever...'
            }
        }

        return;
    }
);

app->helper(
    dump => sub {
        my ($self, $ref, $encode) = @_;
        my $context = Dump($ref);
        if (!defined $encode) {
            return Encode::decode_utf8($context);
        }
        return $context;
    }
);

helper events => sub {
    state $events = Mojo::EventEmitter->new
};

websocket '/channel' => sub {
    my ($c) = @_;

    my $tx = $c->tx;
    Mojo::IOLoop->stream($tx->connection)->timeout(0);

    my $txName = sprintf("%s", $c->tx);

    app->create_battle_ws($c);

    $c->on(json => sub {
        my ($c, $json) = @_;

        given ($json->{method}) {
            when (/^ping$/) {
                # app->battle_request_ws($c, "ping", $json->{data});
            }
            when (/^command$/) {
                # app->battle_request_ws($c, "command", $json->{data});
            }
            when (/^difference$/) {
                # app->battle_request_ws($c, "difference", $json->{data});
            }
            when (/^reload/) {
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
        $c->events->unsubscribe(message => $cb);
    });
};

$loop->timer(1, sub {
    $characters = Mojo::Collection->new;
    $character_types = Mojo::Collection->new;

    my $all = app->characters;

    push(@$characters, @$all);
    my $types = app->character_types;

    push(@$character_types, @$types);
});

$loop->timer(3, sub { app->manage });
$loop->timer(5, sub { app->create_battle_ws_my });

app->start;
