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

app->helper(
    manage => sub {
        my ($self) = @_;
        $self->log->debug("###############");



        $loop->timer(3, sub { $self->manage });
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

$loop->timer(3, sub { app->manage });
$loop->timer(5, sub { app->create_battle_ws_my });

app->start;
