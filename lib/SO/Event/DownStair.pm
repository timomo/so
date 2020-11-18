package SO::Event::DownStair;

use SO::Event::Base -base;

sub bind
{
    my $self = shift;
    $self->hooks->{self} = $self;
    $self->hooks->{encount} = "_encount";
    $self->hooks->{choice} = "_choice";
    $self->hooks->{result} = "_result1";
}

sub _encount
{
    my $self = shift;
    my $mes = "下り階段を発見した！<br />降りますか？";
    my $dat = {};
    $dat->{キャラid} = $self->data->{id};
    $dat->{メッセージ} = $mes;
    my $choice = ["はい", "いいえ"];
    $dat->{選択肢} = $choice;
    $dat->{イベント開始時刻} = time;
    $dat->{イベント種別} = 3; # 下り階段
    $dat->{正解} = "";

    $self->answer($dat);

    $self->insert($dat);
}

sub _choice
{
    my $self = shift;

    if ($self->event->{選択} eq "はい")
    {
        $self->hooks->{result} = "_result1";
    }
    else
    {
        $self->hooks->{result} = "_result2";
    }
}

sub _result1
{
    my $self = shift;
    my $args = shift;
    my $mes = "階段を降りました。";
    my $dat = {};
    $dat->{キャラid} = $self->id;
    $dat->{メッセージ} = $mes;
    my $choice = ["はい"];
    $dat->{選択肢} = $choice;
    $dat->{イベント開始時刻} = time;
    $dat->{イベント種別} = 0; # メッセージのみ
    $dat->{正解} = "";
    $self->insert($dat);

    $self->answer($dat);

    my $append = $self->system->load_append($self->id);
    $append->{階数}++;

    $self->system->save_append_db($append);
}

sub _result2
{
    my $self = shift;
    my $args = shift;
    my $mes = "降りるのをやめました。";
    my $dat = {};
    $dat->{キャラid} = $self->id;
    $dat->{メッセージ} = $mes;
    my $choice = ["はい"];
    $dat->{選択肢} = $choice;
    $dat->{イベント開始時刻} = time;
    $dat->{イベント種別} = 0; # メッセージのみ
    $dat->{正解} = "";
    $self->insert($dat);
    $self->answer($dat);
}

1;
