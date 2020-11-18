package SO::Event::TrappedTreasure;

use SO::Event::Base -base;
use YAML::XS;

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

    my $mes = "トラップ付き宝箱だ！<br />罠はどれか？";
    my $dat = {};
    $dat->{キャラid} = $self->id;
    $dat->{メッセージ} = $mes;
    my $choice = ["石つぶて", "毒針", "爆弾", "睡眠ガス", "毒ガス"];
    my $rand = $self->system->range_rand(0, $#$choice);
    $dat->{選択肢} = $choice;
    $dat->{イベント開始時刻} = time;
    $dat->{イベント種別} = 2; # トラップ付き宝箱
    $dat->{正解} = $choice->[$rand] || "";

    $self->answer($dat);

    $self->insert($dat);
}

sub _choice
{
    my $self = shift;

    if ($self->event->{正解} eq $self->event->{選択})
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
    my $mes = "解除に成功した！";
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

sub _result2
{
    my $self = shift;
    my $args = shift;
    my $mes = "解除に失敗した！";
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
