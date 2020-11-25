package SO::Event::Base;

# push @ISA, 'Mojo::Base';
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
use SO::System;
# use UNIVERSAL::require;

has data => sub {{}};
has watch_hook => sub {{}};
has context => undef;
has k1id => undef;
has k2id => undef;
has log_level => undef;
has system => sub{ SO::System->new };
has event => sub { {} };
has hooks => sub { {} };
has answer => undef;
has is_continue => 1;

has id => undef; # id
has event_type => undef; # イベント種別
has chara_id => undef; # キャラid
has message => undef; # メッセージ
has choices => sub { [] }; # 選択肢
has choice => undef; # 選択
has correct_answer => undef; # 正解
has event_start_time => undef; # イベント開始時刻
has event_end_time => undef; # イベント処理済時刻
has continue_id => 0; # イベント継続id
has parent_id => 0; # 親イベントid
has paragraph => 0; # 段落
has case => ""; # ケース
has fin_flag => 0; # 終了フラグ

sub import
{
    my $self = shift;
    my $class = shift;
    return $class;
}

sub close
{
    my $self = shift;
    $self->data({});
    $self->watch_hook({});
    $self->context(undef);
    $self->system(undef);
    $self->event(undef);
    $self->answer(undef);
}

sub open
{
    my $self = shift;
    my $k = $self->system->load_chara($self->chara_id);
    $self->data($k);
    $self->log_level($self->context->log->level);
    $self->event({});
    $self->answer(undef);

    if (defined $self->id)
    {
        my $where = $self->system->dbi("main")->where;
        $where->clause("キャラid = :キャラid and id = :イベントid");
        $where->param({ キャラid => $self->id, イベントid => $self->id });
        my $result = $self->system->dbi("main")->model("イベント")->select(["*"], where => $where);
        my $row = $result->fetch_hash_one;
        $self->event($row);
    }
    # $self->system(So::System->new(context => $self->context));
}

sub hook
{
    my $self = shift;
    my $point = shift;
    my $row = shift;
    my $method = $self->hooks->{$point};
    $self->$method($row);
}

sub render_to_string
{
    my $self = shift;
    my $row = $self->generate;
    $row->{id} = $self->id;

    if (defined $row)
    {
        if (ref $row->{選択肢} ne "ARRAY")
        {
            $row->{選択肢} = Encode::encode_utf8($row->{選択肢});
            $row->{選択肢} = YAML::XS::Load($row->{選択肢});

            if (ref $row->{選択肢} ne "ARRAY")
            {
                $row->{選択肢} = [ $row->{選択肢} ];
            }
        }

        warn "選択肢--------------";
        warn Dump($row->{選択肢});
        warn "選択肢--------------";

        my $html = $self->context->render_to_string(
            template      => "event",
            event        => $row,
        );

        return Encode::encode_utf8($html);
    }
    return;
}

sub encount
{
    my $self = shift;
    my $args = shift;

    if (! defined $self->event_end_time)
    {
        $self->hook("encount", $args);
    }
}

sub select
{
    my $self = shift;
    my $choice = shift;

    warn Dump([$choice, $self->id]);

    if (int($choice->{イベントid}) != $self->id)
    {
        return;
    }

    warn Dump($choice->{選択});

    if ($choice->{選択} eq "")
    {
        return;
    }

    warn Dump($choice);

    my $raw = $self->choice;

    if (ref $raw ne "ARRAY")
    {
        $raw = Encode::encode_utf8($raw);
        $raw = YAML::XS::Load($raw);

        if (ref $raw ne "ARRAY")
        {
            $raw = [ $raw ];
        }
    }

    push(@$raw, $choice->{選択});

    $self->choice($raw);
    # $self->event_end_time(time);
    $self->save;
    $self->hook("choice", {});
}

sub result
{
    my $self = shift;
    my $args = shift;
    $self->hook("result", {});
}

sub insert
{
    my $self = shift;
    my $row = shift;
    my $dat = {};

    for my $key (keys %$row)
    {
        $dat->{$key} = $row->{$key};
    }

    if (ref $dat->{選択肢} eq "ARRAY")
    {
        $dat->{選択肢} = YAML::XS::Dump($dat->{選択肢});
        $dat->{選択肢} = Encode::decode_utf8($dat->{選択肢});
    }

    eval {
        $self->system->dbi("main")->model("イベント")->insert($dat, ctime => "ctime");
    };
    if ($@)
    {
        warn YAML::XS::Dump($dat);
        die $@;
    }
    $self->id($self->system->dbi("main")->dbh->sqlite_last_insert_rowid);

    $row->{id} = $self->id;
}

sub update
{
    my $self = shift;
    my $row = shift;
    my $dat = {};

    for my $key (keys %$row)
    {
        $dat->{$key} = $row->{$key};
    }

    if (ref $dat->{選択肢} eq "ARRAY")
    {
        $dat->{選択肢} = YAML::XS::Dump($dat->{選択肢});
        $dat->{選択肢} = Encode::decode_utf8($dat->{選択肢});
    }
    if (ref $dat->{選択} eq "ARRAY")
    {
        $dat->{選択} = YAML::XS::Dump($dat->{選択});
        $dat->{選択} = Encode::decode_utf8($dat->{選択});
    }

    eval {
        $self->system->dbi("main")->model("イベント")->update($dat, where => {id => $self->id}, mtime => "mtime");
    };
    if ($@)
    {
        warn YAML::XS::Dump($dat);

        warn YAML::XS::Dump(caller(1));

        # warn YAML::XS::Dump(ref $self->system);
        die $@;
    }
}

sub generate
{
    my $self = shift;

    my $dat = {};
    $dat->{イベント種別} = $self->event_type;
    $dat->{キャラid} = $self->chara_id;
    $dat->{メッセージ} = $self->message;
    $dat->{選択肢} = $self->choices;
    $dat->{選択} = $self->choice;
    $dat->{正解} = $self->correct_answer;
    $dat->{イベント開始時刻} = $self->event_start_time;
    $dat->{イベント処理済時刻} = $self->event_end_time;
    $dat->{イベント継続id} = $self->continue_id;
    $dat->{親イベントid} = $self->parent_id;
    $dat->{段落} = $self->paragraph;
    $dat->{ケース} = $self->case;
    $dat->{終了フラグ} = $self->fin_flag;

    return $dat;
}

sub save
{
    my $self = shift;

    my $dat = $self->generate;

    # warn Dump $dat;

    if (defined $self->id)
    {
        $self->update($dat);
    }
    else
    {
        $self->insert($dat);
    }
}

sub age
{
    my $self = shift;
    my $age = 1;

    if ($self->parent_id == 0)
    {
        return $age;
    }
    my $event = $self;

    while(defined $event)
    {
        $event = $event->parent;
        if (defined $event)
        {
            $age++;
        }
    }

    return $age;
}

sub next
{
    my $self = shift;

    if ($self->fin_flag == 1)
    {
        return;
    }

    if ($self->continue_id == 0)
    {
        return;
    }

    my $where = $self->system->dbi("main")->where;
    $where->clause("キャラid = :キャラid AND id = :イベントid");
    $where->param({ キャラid => $self->chara_id, イベントid => $self->continue_id });
    my $result = $self->system->dbi("main")->model("イベント")->select(["*"], where => $where);
    my $row = $result->fetch_hash_one;

    if (! defined $row)
    {
        return;
    }

    my $class = $self->get_event_class($row);
    my $event = $self->object($class);
    $event->id($row->{id});
    $event->open;
    $event->bind;
    $event->event_type($row->{イベント種別});
    $event->chara_id($row->{キャラid});
    $event->message($row->{メッセージ});
    $event->choices($row->{選択肢});
    $event->choice($row->{選択});
    $event->correct_answer($row->{正解});
    $event->event_start_time($row->{イベント開始時刻});
    $event->event_end_time($row->{イベント処理済時刻});
    $event->continue_id($row->{イベント継続id});
    $event->parent_id($row->{親イベントid});
    $event->paragraph($row->{段落});
    $event->case($row->{ケース});
    $event->fin_flag($row->{終了フラグ});

    return $event;
}

sub parent
{
    my $self = shift;

    if ($self->parent_id == 0)
    {
        return;
    }

    my $where = $self->system->dbi("main")->where;
    $where->clause("キャラid = :キャラid AND id = :イベントid");
    $where->param({ キャラid => $self->chara_id, イベントid => $self->parent_id });
    my $result = $self->system->dbi("main")->model("イベント")->select(["*"], where => $where);
    my $row = $result->fetch_hash_one;

    if (! defined $row)
    {
        return;
    }

    my $class = $self->get_event_class($row);
    my $event = $self->object($class);
    $event->id($row->{id});
    $event->open;
    $event->bind;
    $event->event_type($row->{イベント種別});
    $event->chara_id($row->{キャラid});
    $event->message($row->{メッセージ});
    $event->choices($row->{選択肢});
    $event->choice($row->{選択});
    $event->correct_answer($row->{正解});
    $event->event_start_time($row->{イベント開始時刻});
    $event->event_end_time($row->{イベント処理済時刻});
    $event->continue_id($row->{イベント継続id});
    $event->parent_id($row->{親イベントid});
    $event->paragraph($row->{段落});
    $event->case($row->{ケース});
    $event->fin_flag($row->{終了フラグ});

    return $event;
}

sub object
{
    my $self = shift;
    my $class = shift;
    $class->require or die $@;
    my $event = $class->new(context => $self->context, "system" => $self->system, chara_id => $self->chara_id);
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

sub delete
{
    my ($self) = @_;
    $self->system->dbi("main")->model("イベント")->delete(where => { id => $self->{id} });

}


1;
