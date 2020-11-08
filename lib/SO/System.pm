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
has dbis => sub { {} };

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

sub dbi
{
    my $self = shift;
    my $type = shift;

    if ($type eq "main")
    {
        if (defined $self->dbis->{$type})
        {
            return $self->dbis->{$type};
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
        $dbi->create_model("キャラ");
        $dbi->create_model("キャラ追加情報1");
        $dbi->create_model("メッセージ");

        $self->dbis->{$type} = $dbi;

        return $dbi;
    }
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

sub range_rand
{
    my ($self, $min, $max) = @_;

    if ($max < $min) {
        ($max, $min) = ($min, $max);
    }
    elsif ($max == $min) {
        return int($max);
    }

    my $rand = $min + int(rand($max - $min)) + 1;

    return $rand;
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
    my $id = shift;

    my $result = $self->dbi("main")->model("キャラ追加情報1")->select(["*"], where => { id => $id });
    my $row = $result->fetch_hash_one;

    return $row;
}

sub load_chara
{
    my $self = shift;
    my $id = shift;

    my $result = $self->dbi("main")->model("キャラ")->select(["*"], where => { id => $id });
    my $row = $result->fetch_hash_one;

    return $row;
}

sub load_message
{
    my ($self, $from) = @_;
    my $where = "送付元id = :送付元id or 送付先id = :送付先id";
    my $query = { 送付元id => $from, 送付先id => $from };
    my $result = $self->dbi("main")->model("メッセージ")->select(["*"], where => [$where, $query], append => "order by 受信日時 desc limit 5");
    return $result->fetch_hash_all;
}

sub load_chara_by_name
{
    my $self = shift;
    my $id = shift;

    my $result = $self->dbi("main")->model("キャラ")->select(["*"], where => { 名前 => $id });
    my $row = $result->fetch_hash_one;

    return $row;
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

sub modify_message_data
{
    my $self = shift;
    my $new = shift;

    $new->{送付元名前} ||= $self->load_chara($new->{送付元id})->{名前} || "";
    $new->{送付先名前} ||= $self->load_chara($new->{送付先id})->{名前} || "";
    $new->{受信日時} ||= DateTime->now(time_zone => "Asia/Tokyo")->datetime;

    if (! defined $new->{id})
    {
        delete $new->{id};
    }
}

sub save_chara
{
    my $self = shift;
    my $new = shift;
    return $self->save_chara_db($new);
}

sub save_append
{
    my $self = shift;
    my $new = shift;
    return $self->save_append_db($new);
}

sub save_message
{
    my $self = shift;
    my $new = shift;
    return $self->save_message_db($new);
}

sub save_chara_db
{
    my $self = shift;
    my $new = shift;

    $self->modify_chara_data($new);

    my $result = $self->dbi("main")->model("キャラ")->select(["*"], where => { id => $new->{id} });
    my $row = $result->fetch_hash_one;

    if (defined $row)
    {
        $self->dbi("main")->model("キャラ")->update($new, where => {id => $new->{id}}, mtime => "mtime");
    }
    else
    {
        $self->dbi("main")->model("キャラ")->insert($new, ctime => "ctime");
    }
}

sub save_append_db
{
    my $self = shift;
    my $new = shift;

    $self->modify_append_data($new);

    my $result = $self->dbi("main")->model("キャラ追加情報1")->select(["*"], where => { id => $new->{id} });
    my $row = $result->fetch_hash_one;

    if (defined $row)
    {
        $self->dbi("main")->model("キャラ追加情報1")->update($new, where => {id => $new->{id}}, mtime => "mtime");
    }
    else
    {
        $self->dbi("main")->model("キャラ追加情報1")->insert($new, ctime => "ctime");
    }
}

sub save_message_db
{
    my $self = shift;
    my $new = shift;

    $self->modify_message_data($new);

    my $result;
    my $row;

    if (defined $new->{id})
    {
        $result = $self->dbi("main")->model("メッセージ")->select(["*"], where => { id => $new->{id} });
        $row = $result->fetch_hash_one;
    }

    if (defined $row)
    {
        $self->dbi("main")->model("メッセージ")->update($new, where => {id => $new->{id}}, mtime => "mtime");
    }
    else
    {
        $self->dbi("main")->model("メッセージ")->insert($new, ctime => "ctime");
        return $self->dbi("main")->dbh->sqlite_last_insert_rowid;
    }
}

sub save_chara_file
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

sub save_append_file
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
