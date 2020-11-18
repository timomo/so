package SO::Event::UnknownTreasure;

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

    my $dat = {};
    $dat->{キャラid} = $self->id;
    $dat->{メッセージ} = "宝箱を発見した！<br />開けますか？";
    my $choice = ["開ける", "開けない"];
    $dat->{イベント開始時刻} = time;
    $dat->{イベント種別} = 1; # 宝箱
    $dat->{選択肢} = $choice;

    $self->answer($dat);

    $self->insert($dat);
}

sub _choice
{
    my $self = shift;

    if ($self->event->{選択} eq "開ける")
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
    $self->insert($dat);
    $self->answer($dat);
}

sub _result2
{
    my $self = shift;
    my $args = shift;
    my $mes = "あなたは宝箱を開けるのをやめました。";
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
