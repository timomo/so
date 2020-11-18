package SO::Event::Base;

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

has data => sub {{}};
has watch_hook => sub {{}};
has context => undef;
has k1id => undef;
has k2id => undef;
has id => undef;
has log_level => undef;
has system => undef;
has event_id => undef;
has event => sub { {} };
has hooks => sub { {} };
has answer => undef;

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
    my $k = $self->system->load_chara($self->id);
    $self->data($k);
    $self->log_level($self->context->log->level);
    $self->event({});
    $self->answer(undef);

    if (defined $self->event_id)
    {
        my $where = $self->system->dbi("main")->where;
        $where->clause("キャラid = :キャラid and id = :イベントid");
        $where->param({ キャラid => $self->id, イベントid => $self->event_id });
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
    my $row = $self->answer;

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
    $self->hook("encount", $args);
}

sub choice
{
    my $self = shift;
    my $choice = shift;
    my $ref = {};
    $ref->{選択} = $choice;
    $ref->{イベント処理済時刻} = time;
    $self->system->dbi("main")->model("イベント")->update($ref, where => {id => $self->event_id}, mtime => "mtime");
    $self->event->{選択} = $choice;

    $self->hook("choice", {});

    # warn Dump($self->event);
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

    $dat->{選択肢} = YAML::XS::Dump($dat->{選択肢});
    $dat->{選択肢} = Encode::decode_utf8($dat->{選択肢});

    $self->system->dbi("main")->model("イベント")->insert($dat, ctime => "ctime");

    $self->event_id($self->system->dbi("main")->dbh->sqlite_last_insert_rowid);

    $row->{id} = $self->event_id;
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
