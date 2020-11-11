package SO::AI;

use Mojo::Base -base;
use Data::Dumper;
use Mojo::Collection;
use Storable;
use Mojo::File;
use File::Spec;
use FindBin;
use YAML::XS;
use Encode;
use DateTime::HiRes;

has data => sub {{}};
has watch_hook => sub {{}};
has context => undef;
has id => undef;
has log_level => undef;

sub close
{
    my $self = shift;
    $self->data({});
    $self->watch_hook({});
    $self->context(undef);
}

sub open
{
    my $self = shift;
    my $k = $self->context->character($self->id);
    $self->data($k);
    $self->log_level($self->context->log->level);
}

sub state
{
    my $self = shift;
    my $id = $self->id;
    my $k = $self->context->character($id);
    my $mode = $self->context->location($id);

    if (! defined $k)
    {
        return undef;
    }

    if ($self->context->is_battle($id) || $self->context->is_pvp($id)) { # 戦闘優先
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
};

sub log
{
    my $self = shift;
    my $level = shift;
    my $k = $self->data;
    my $mode = $self->context->location($k->{id});
    my $mes = "id = %s, パスワード = %s, スポット = %s, エリア = %s, 距離 = %s, HP = %s, 前回コマンド = %s. ". shift;
    my @args = (@$k{qw|id パスワード スポット エリア 距離 HP|}, $mode, @_);

    $self->context->log->$level(sprintf($mes, @args));
}

sub command
{
    my $self = shift;
    my $k = $self->data;
    my $id = $self->id;
    my $mode = $self->context->location($id);
    my $state = $self->context->state($id);

    if (! defined $mode)
    {
        $self->log("warn", "mode 取得に失敗");
        return undef;
    }

    if (! defined $state)
    {
        $self->log("warn", "state 取得に失敗");
        return undef;
    }

    if ($state eq "battle")
    {
        if ($self->context->is_pvp($id))
        {
            $self->log("debug", "PVP");

            my $ids = $self->context->get_pvp_ids($id);

            if (defined $ids)
            {
                return {
                    mode => "pvp",
                    id => $id,
                    k1id => $ids->[0],
                    k2id  => $ids->[1],
                };
            }

            $self->log("error", "PVP: ARRAY 失敗");

            return;
        }
        else
        {
            $self->log("debug", "monster: 戦闘中");
            return {
                mode => "monster",
                id   => $id,
            };
        }
    }
    elsif ($state eq "search")
    {
        if ($k->{スポット} == 0 && $k->{距離} == 0) # どこかの街の中
        {
            $self->log("debug", "search: 街の中");
            return {
                mode => "monster",
                area => $k->{エリア},
                spot => 0,
                id   => $id,
            };
        }
        else # 近辺を探索中
        {
            # TODO: PKキャラなら、敵を探し、僧侶系なら、辻ヒールを行う。それ以外なら、応援か素通り
            my $neighbors = Mojo::Collection->new(@{$self->context->neighbors($id)});
            my $shuffle = $neighbors->shuffle;
            my $target_append = $shuffle->head(1)->last;
            my $rand = $self->context->range_rand(0 ,100);

            if (defined $target_append && $rand >= 99)
            {
                my $is_battle = $self->context->is_battle($id) || $self->context->is_pvp($id) ? 1 : 0;
                my $is_battle2 = $self->context->is_battle($target_append->{id}) || $self->context->is_pvp($target_append->{id}) ? 1 : 0;
                my $rand2 = $self->context->range_rand(0 ,100);

                if ($rand2 <= 50)
                {
                    my $mes = "これはNPC " . $k->{名前}. " からのメッセージ送信テストです。絶賛開発中です。";

                    return {
                        mode  => "message",
                        mesid => $target_append->{id},
                        mes   => $mes,
                        name  => $k->{名前},
                        id    => $id,
                    };
                }
                elsif ($rand2 > 50 && $is_battle == 0 && $is_battle2 == 0)
                {
                    # 今の所、決め打ちで、襲い掛かる
                    $self->log("debug", "search: ユーザを見て襲いかかる");
                    return {
                        mode => "pvp",
                        id => $id,
                        k1id => $id,
                        k2id  => $target_append->{id},
                    };
                }
                else # 一度メッセージを送ったら、去る
                {
                    $self->log("debug", "search: ユーザを見て去る");
                    return {
                        mode => "monster",
                        area => $k->{エリア},
                        spot => 0,
                        id   => $id,
                    };
                }
            }
            else
            {
                $self->log("debug", "search: 近辺探索中");
                return {
                    mode => "monster",
                    area => $k->{エリア},
                    spot => 0,
                    id   => $id,
                };
            }
        }
    }
    elsif ($state eq "cure")
    {
        if ($k->{スポット} == 0 && $k->{距離} == 0) # どこかの街の中
        {
            $self->log("debug", "cure: 街の中");
            if ($mode ne "yado")
            {
                $self->log("debug", "cure: 街の中から宿へ");
                return {
                    mode => "yado",
                    area => $k->{エリア},
                    id   => $id,
                };
            }
            elsif ($mode eq "yado")
            {
                $self->log("debug", "cure: 宿に泊まる");
                return {
                    inn_no => 0,
                    mode => "yado_in",
                    area => $k->{エリア},
                    id   => $id,
                };
            }
        }
        else # 近辺を探索中
        {
            if ($k->{所持金} >= 9000) { # 一旦、所持金チェックは決め打ちで。。。
                $self->log("debug", "cure: 近辺探索中で街へ");
                return {
                    mode => "monster",
                    area => $k->{エリア},
                    spot => 1,
                    id   => $id,
                };
            }
            else
            {
                $self->log("debug", "cure: 近辺探索中で休憩");
                return {
                    mode => "rest",
                    area => $k->{エリア},
                    spot => 2,
                    id   => $id,
                };
            }
        }
    }

    return undef;
}

sub watch
{
    my ($self, $key, $func) = @_;
    $self->watch_hook->{$key} = $func;
}

sub in_array
{
    my ($self, $val, $array_ref) = @_;

    foreach my $elem (@$array_ref) {
        if ($val =~ m/^[0-9]+$/) {
            if ($val == $elem) {return 1;}
        }
        else {
            if ($val eq $elem) {return 1;}
        }
    }

    return 0;
}

sub param
{
    my ($self, $key, $val) = @_;
    if (defined $val) {
        my $oldVal = $self->data->{$key};
        my $newVal = $val;
        $self->data->{$key} = $newVal;

        if (exists $self->watch_hook->{$key} && ref $self->watch_hook->{$key} eq "CODE") {
            $self->watch_hook->{$key}->($self, $newVal, $oldVal);
        }
    }
    return $self->data->{$key};
}

sub unset
{
    my ($self, $key) = @_;
    delete $self->data->{$key};
}

sub dump
{
    my ($self, $data) = @_;
    my $str = YAML::XS::Dump($data);
    utf8::decode($str);
    return $str;
}

sub DESTROY
{
    my ($self) = @_;
    my $dt = DateTime::HiRes->now(time_zone => "Asia/Tokyo");
    my $mes = sprintf("[%s] [%s] [%s] %s [%s] DESTROY", $dt->strftime('%Y-%m-%d %H:%M:%S.%5N'), $$, "debug", $self, $self->id || "-");
    my $utf8 = Encode::encode_utf8($mes);
    warn $utf8. "\n" if ($self->log_level eq "debug");
}

1;
