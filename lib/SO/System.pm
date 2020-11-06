package SO::System;

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

has id => undef;
has watch_hook => sub {{}};
has context => undef;
has log_level => undef;

sub close
{
    my $self = shift;
    $self->watch_hook({});
    $self->context(undef);
}

sub open
{
    my $self = shift;
    $self->log_level($self->context->log->level);
    # my $k = $self->context->character($self->id);
    # $self->data($k);
}

sub debug_trace
{
    my $self = shift;
    my @ret;

    for my $no (0 .. 5)
    {
        my @tmp;
        if ($no == 0)
        {
            @tmp = caller;
        }
        else
        {
            @tmp = caller($no);
        }

        push(@ret, sprintf("%s, %s, %s, %s", @tmp[0 .. 3]));
    }

    warn join("\n", @ret);
}

sub load_raw_ini
{
    my $self = shift;
    my $path = shift;

    # $self->debug_trace;

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
}

sub save_raw_ini
{
    my $self = shift;
    my $path = shift;
    my $keys = shift;
    my $list = shift;
    my $file = Mojo::File->new($path);
    my @save;

    $file->touch;

    for my $data (@$list)
    {
        my @tmp = @$data{@$keys};
        $tmp[$_] ||= "" for 0 .. $#tmp;
        my $line = join($self->context->config->{sep}, @tmp);
        my $utf8 = Encode::encode_utf8($line);
        push(@save, $utf8);
    }

    $file->spurt(join($self->context->config->{new_line}, @save));
}

sub load_append
{
    my $self = shift;
    my $path = $self->context->config->{append_file};
    my $id = shift;
    my $list = $self->load_ini($path, $self->context->config->{keys2});
    for my $k (@$list)
    {
        if ($k->{id} eq $id) {
            $self->modify_append_data($k);
            return $k;
        }
    }
    return undef;
}

sub load_chara
{
    my $self = shift;
    my $path = $self->context->config->{chara_file};
    my $id = shift;
    my $list = $self->load_ini($path, $self->context->config->{keys});
    for my $k (@$list)
    {
        if ($k->{id} eq $id) {
            $self->modify_chara_data($k);
            return $k;
        }
    }
    return undef;
}

sub load_chara_by_name
{
    my $self = shift;
    my $path = $self->context->config->{chara_file};
    my $name = shift;
    my $list = $self->load_ini($path, $self->context->config->{keys});
    for my $k (@$list)
    {
        if ($k->{名前} eq $name) {
            return $k;
        }
    }
    return undef;
}

sub modify_append_data
{
    my $self = shift;
    my $new = shift;
    my $keys = $self->context->config->{keys2};
    my $regex = qr/(?:エリア|スポット|距離|最終実行時間)/;

    for my $key (@$keys)
    {
        if ($key =~ /$regex/)
        {
            $new->{$key} ||= 0;
        }
    }
}

sub modify_chara_data
{
    my $self = shift;
    my $new = shift;
    my $keys = $self->context->config->{keys};
    my $regex = qr/(?:性別|画像|力|賢さ|信仰心|体力|器用さ|素早さ|魅力|HP|最大HP|経験値|レベル|残りAP|所持金|LP|戦闘数|勝利数|最終アクセス|エリア|スポット|距離|アイテム)/;

    for my $key (@$keys)
    {
        if ($key =~ /$regex/)
        {
            $new->{$key} ||= 0;
        }
    }
}

sub save_chara
{
    my $self = shift;
    my $path = $self->context->config->{chara_file};
    my $new = shift;
    my $list = $self->load_ini($path, $self->context->config->{keys});
    my $hit = 0;

    $self->modify_chara_data($new);

    for my $k (@$list)
    {
        if (! defined $k->{id})
        {
            next;
        }

        if ($k->{id} eq $new->{id})
        {
            $hit = 1;
            @$k{@{$self->context->config->{keys}}} = @$new{@{$self->context->config->{keys}}};
        }
    }

    if ($hit == 0)
    {
        push(@$list, $new);
    }

    $self->save_raw_ini($path, $self->context->config->{keys}, $list);
}

sub save_append
{
    my $self = shift;
    my $path = $self->context->config->{append_file};
    my $new = shift;
    my $list = $self->load_ini($path, $self->context->config->{keys2});
    my $hit = 0;

    $self->modify_append_data($new);

    if (! defined $new->{id})
    {
        $self->context->log->error("save_appendにて不正なデータを検知");
        return;
    }

    for my $k (@$list)
    {
        if (! defined $k->{id})
        {
            next;
        }

        if ($k->{id} eq $new->{id})
        {
            $hit = 1;
            @$k{@{$self->context->config->{keys2}}} = @$new{@{$self->context->config->{keys2}}};
        }
    }

    if ($hit == 0)
    {
        push(@$list, $new);
    }

    $self->save_raw_ini($path, $self->context->config->{keys2}, $list);
}

sub load_ini
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
