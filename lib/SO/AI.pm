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
}

sub command
{
    my $self = shift;
    my $k = $self->data;
    my $id = $self->id;
    my $mode = $self->context->location($id);
    my $state = $self->context->get_state($id);

    if (! defined $mode)
    {
        $self->context->log->warn(sprintf("location: 取得に失敗: id = %s, パスワード = %s, スポット = %s, エリア = %s, 距離 = %s", $k->{id}, $k->{パスワード}, $k->{スポット}, $k->{エリア}, $k->{距離}));
        return undef;
    }

    if (! defined $state)
    {
        $self->context->log->warn(sprintf("state: 取得に失敗: id = %s, パスワード = %s, スポット = %s, エリア = %s, 距離 = %s", $k->{id}, $k->{パスワード}, $k->{スポット}, $k->{エリア}, $k->{距離}));
        return undef;
    }

    if ($state eq "battle")
    {
        if ($self->context->is_pvp($id))
        {
            $self->context->log->debug(sprintf("battle: PVP中: id = %s, パスワード = %s, スポット = %s, エリア = %s, 距離 = %s", $k->{id}, $k->{パスワード}, $k->{スポット}, $k->{エリア}, $k->{距離}));

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

            $self->context->log->error(sprintf("battle: PVP中、ARRAY失敗: id = %s, パスワード = %s, スポット = %s, エリア = %s, 距離 = %s", $k->{id}, $k->{パスワード}, $k->{スポット}, $k->{エリア}, $k->{距離}));

            return;
        }
        else
        {
            $self->context->log->debug(sprintf("battle: 戦闘中: id = %s, パスワード = %s, スポット = %s, エリア = %s, 距離 = %s", $k->{id}, $k->{パスワード}, $k->{スポット}, $k->{エリア}, $k->{距離}));
            return {
                mode => "monster"
            };
        }
    }
    elsif ($state eq "search")
    {
        if ($k->{スポット} == 0 && $k->{距離} == 0) # どこかの街の中
        {
            $self->context->log->debug(sprintf("search: 街の中: id = %s, パスワード = %s, スポット = %s, エリア = %s, 距離 = %s", $k->{id}, $k->{パスワード}, $k->{スポット}, $k->{エリア}, $k->{距離}));
            return {
                mode => "monster",
                area => $k->{エリア},
                spot => 0,
            };
        }
        else # 近辺を探索中
        {
            # TODO: PKキャラなら、敵を探し、僧侶系なら、辻ヒールを行う。それ以外なら、応援か素通り
            my $neighbors = Mojo::Collection->new(@{$self->context->neighbors($id)});
            my $shuffle = $neighbors->shuffle;
            my $target_append = $shuffle->head(1)->last;

            if (defined $target_append)
            {
                my $is_battle = $self->context->is_battle($id) || $self->context->is_pvp($id) ? 1 : 0;
                my $is_battle2 = $self->context->is_battle($target_append->{id}) || $self->context->is_pvp($target_append->{id}) ? 1 : 0;

                if (0)
                {
                    my $mes = "これはNPC " . $k->{名前}. " からのメッセージ送信テストです。絶賛開発中です。";

                    return {
                        mode  => "message",
                        mesid => $target_append->{id},
                        mes   => $mes,
                        name  => $k->{名前},
                    };
                }
                elsif ($is_battle == 0 && $is_battle2 == 0)
                {
                    # 今の所、決め打ちで、襲い掛かる
                    $self->context->log->debug(sprintf("search: ユーザを見て襲いかかる: id = %s, パスワード = %s, スポット = %s, エリア = %s, 距離 = %s", $k->{id}, $k->{パスワード}, $k->{スポット}, $k->{エリア}, $k->{距離}));
                    return {
                        mode => "pvp",
                        id => $id,
                        k1id => $id,
                        k2id  => $target_append->{id},
                    };
                }
                else # 一度メッセージを送ったら、去る
                {
                    $self->context->log->debug(sprintf("search: ユーザを見て去る: id = %s, パスワード = %s, スポット = %s, エリア = %s, 距離 = %s", $k->{id}, $k->{パスワード}, $k->{スポット}, $k->{エリア}, $k->{距離}));
                    return {
                        mode => "monster",
                        area => $k->{エリア},
                        spot => 0,
                    };
                }
            }
            else
            {
                $self->context->log->debug(sprintf("search: 近辺探索中: id = %s, パスワード = %s, スポット = %s, エリア = %s, 距離 = %s", $k->{id}, $k->{パスワード}, $k->{スポット}, $k->{エリア}, $k->{距離}));
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
            $self->context->log->debug(sprintf("cure: 街の中: id = %s, パスワード = %s, スポット = %s, エリア = %s, 距離 = %s, 前回コマンド = %s, HP = %s", $k->{id}, $k->{パスワード}, $k->{スポット}, $k->{エリア}, $k->{距離}, $mode, $k->{HP}));
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
                $self->context->log->debug(sprintf("cure: 近辺探索中で街へ: id = %s, パスワード = %s, スポット = %s, エリア = %s, 距離 = %s", $k->{id}, $k->{パスワード}, $k->{スポット}, $k->{エリア}, $k->{距離}));
                return {
                    mode => "monster",
                    area => $k->{エリア},
                    spot => 1,
                };
            }
            else
            {
                $self->context->log->debug(sprintf("cure: 近辺探索中で休憩: id = %s, パスワード = %s, スポット = %s, エリア = %s, 距離 = %s", $k->{id}, $k->{パスワード}, $k->{スポット}, $k->{エリア}, $k->{距離}));
                return {
                    mode => "rest",
                    area => $k->{エリア},
                    spot => 2,
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
    my $mes = sprintf("[%s] [%s] [%s] %s [%s] DESTROY", $dt->strftime('%Y-%m-%d %H:%M:%S.%5N'), $$, "custom", $self, $self->id || "-");
    my $utf8 = Encode::encode_utf8($mes);
    warn $utf8. "\n";
}

1;
