package SO::Event;

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
use UNIVERSAL::require;

has data => sub {{}};
has watch_hook => sub {{}};
has context => undef;
has k1id => undef;
has k2id => undef;
has id => undef;
has log_level => undef;
has system => undef;
has event_id => undef;
has event => undef;
has random => 0;

sub close
{
    my $self = shift;
    $self->data({});
    $self->watch_hook({});
    $self->context(undef);
    $self->system(undef);
    $self->event(undef);
}

sub open
{
    my $self = shift;
    my $k = $self->system->load_chara($self->id);
    $self->data($k);
    $self->log_level($self->context->log->level);
    $self->event(undef);

    if (! defined $self->event_id)
    {
=begin
        my $where = $self->system->dbi("main")->where;
        $where->clause("イベント処理済時刻 IS NULL AND キャラid = :キャラid");
        $where->param({ キャラid => $self->id });
        my $result = $self->system->dbi("main")->model("イベント")->select(["*"], where => $where);
        my $row = $result->fetch_hash_one;
        $self->event($row);
        $self->event_id($row->{id});
=cut
    }
    elsif (defined $self->event_id)
    {

    }

    # $self->system(So::System->new(context => $self->context));
}

sub object
{
    my $self = shift;
    my $class = shift;
    $class->require or die $@;
    my $event = $class->new(context => $self->context, "system" => $self->system, chara_id => $self->id);
    return $event;
}

sub get_event_class
{
    my $self = shift;
    my $event = shift;
    my $class;

    if ($event->{イベント種別} == 0) {
        $class = "SO::Event::SimpleMessage";
    }
    elsif ($event->{イベント種別} == 1) {
        $class = "SO::Event::UnknownTreasure";
    }
    elsif ($event->{イベント種別} == 2) {
        $class = "SO::Event::TrappedTreasure";
    }
    elsif ($event->{イベント種別} == 3) {
        $class = "SO::Event::DownStair";
    }
    elsif ($event->{イベント種別} == 4) {
        $class = "SO::Event::ContinuousMessage";
    }
    elsif ($event->{イベント種別} == 5) {
        $class = "SO::Event::rAthenaScript";
    }

    return $class;
}

sub reserved
{
    my $self = shift;
    $self->open;
    my $class;
    my $event;

    {
        my $where = $self->system->dbi("main")->where;
        $where->clause("イベント処理済時刻 IS NULL AND キャラid = :キャラid");
        $where->param({ キャラid => $self->id });
        my $result = $self->system->dbi("main")->model("イベント")->select(["*"], where => $where, append => "order by id asc");
        my $row = $result->fetch_hash_one;

        if (defined $row)
        {
            $self->event($row);
            $self->event_id($row->{id});
        }
    }

    if (defined $self->event)
    {
        $class = $self->get_event_class($self->event);
        $event = $self->object($class);
        $event->id($self->event->{id});
        $event->open;
        $event->bind;
        $event->id($self->event->{id});
        $event->event_type($self->event->{イベント種別});
        $event->chara_id($self->event->{キャラid});
        $event->message($self->event->{メッセージ});
        $event->choices($self->event->{選択肢});
        $event->choice($self->event->{選択});
        $event->correct_answer($self->event->{正解});
        $event->event_start_time($self->event->{イベント開始時刻});
        $event->event_end_time($self->event->{イベント処理済時刻});
        $event->continue_id($self->event->{イベント継続id});
        $event->parent_id($self->event->{親イベントid});
        $event->paragraph($self->event->{段落});
        $event->case($self->event->{ケース});
        $event->fin_flag($self->event->{終了フラグ});
    }

    $self->close;

    return $event;
}

sub encounter
{
    my $self = shift;
    $self->open;

    my $class;
    my $event;

    my $rand0 = $self->system->range_rand(0, 100);

    if ($rand0 <= 30)
    {
        my $rand1 = $self->system->range_rand(0, 100);

        if ($rand1 >= 0 && $rand1 <= 29)
        {
            $class = "SO::Event::DownStair";
        }
        elsif ($rand1 >= 30 && $rand1 <= 59)
        {
            my $treasure = $self->check_treasure;
            if (defined $treasure)
            {
                $class = "SO::Event::UnknownTreasure";
                my $ref = {};
                $ref->{取得者} = $self->data->{id};
                $self->system->dbi("main")->model("アイテムスポーンデータ")->update($ref, where => {id => $treasure->{id}}, mtime => "mtime");
            }
        }
        elsif ($rand1 >= 60 && $rand1 <= 100)
        {
            $class = "SO::Event::AreaRandomMessage";
        }
    }

    $class = "SO::Event::rAthenaScript";
    # $class = "SO::Event::DownStair";

    if (defined $class)
    {
        $event = $self->object($class);
        $event->id($self->event_id);
        $event->open;
        $event->bind;

        if (defined $self->event)
        {
            $event->id($self->event->{id});
            $event->event_type($self->event->{イベント種別});
            $event->chara_id($self->event->{キャラid});
            $event->message($self->event->{メッセージ});
            $event->choices($self->event->{選択肢});
            $event->choice($self->event->{選択});
            $event->correct_answer($self->event->{正解});
            $event->event_start_time($self->event->{イベント開始時刻});
            $event->event_end_time($self->event->{イベント処理済時刻});
            $event->continue_id($self->event->{イベント継続id});
            $event->parent_id($self->event->{親イベントid});
            $event->paragraph($self->event->{段落});
            $event->case($self->event->{ケース});
            $event->fin_flag($self->event->{終了フラグ});
        }
    }

    $self->close;

    return $event;
}

sub load
{
    my $self = shift;
    $self->open;

    my $class;
    my $event;

    my $where = $self->system->dbi("main")->where;
    $where->clause("キャラid = :キャラid AND id = :イベントid");
    $where->param({ キャラid => $self->id, イベントid => $self->event_id });
    my $result = $self->system->dbi("main")->model("イベント")->select(["*"], where => $where);
    my $row = $result->fetch_hash_one;
    if (defined $row)
    {
        $self->event($row);
    }

    if (defined $self->event)
    {
        $class = $self->get_event_class($self->event);
        $event = $self->object($class);
        $event->id($self->event_id);
        $event->open;
        $event->bind;
        $event->id($self->event->{id});
        $event->event_type($self->event->{イベント種別});
        $event->chara_id($self->event->{キャラid});
        $event->message($self->event->{メッセージ});
        $event->choices($self->event->{選択肢});
        $event->choice($self->event->{選択});
        $event->correct_answer($self->event->{正解});
        $event->event_start_time($self->event->{イベント開始時刻});
        $event->event_end_time($self->event->{イベント処理済時刻});
        $event->continue_id($self->event->{イベント継続id});
        $event->parent_id($self->event->{親イベントid});
        $event->paragraph($self->event->{段落});
        $event->case($self->event->{ケース});
        $event->fin_flag($self->event->{終了フラグ});
    }

    $self->close;

    return $event;
}

sub check_treasure
{
    my $self = shift;
    my $result = $self->system->dbi("main")->model("キャラ追加情報1")->select(["*"], where => {id => $self->data->{id}});
    my $row = $result->fetch_hash_one;
    my $where = $self->system->dbi("main")->where;
    $where->clause("取得者 IS NULL AND エリア = :エリア AND スポット = :スポット AND 距離 = :距離 AND 階数 = :階数");
    my @keys = ("エリア", "スポット", "距離", "階数");
    my $query = {};
    @$query{@keys} = @$row{@keys};
    $where->param($query);
    my $result2 = $self->system->dbi("main")->model("アイテムスポーンデータ")->select(["*"], where => $where);
    my $row2 = $result2->fetch_hash_one;
    return $row2;
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
