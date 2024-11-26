package SO::Event::TrappedTreasure;

# push @ISA, 'SO::Event::Base';
use Mojo::Base 'SO::Event::Base';
use YAML::XS;
use SO::Event::SimpleMessage;

has event_type => 2; # イベント種別
has chara_id => undef; # キャラid
has message => "トラップ付き宝箱だ！<br />罠はどれか？"; # メッセージ
has choices => sub { ["石つぶて", "毒針", "爆弾", "睡眠ガス", "毒ガス"] }; # 選択肢
has choice => undef; # 選択
has correct_answer => sub {
    my $self = shift;
    my $choices = $self->choices;
    my $system = $self->app->entity("system");
    my $rand = $system->range_rand(0, $#$choices);
    return $choices->[$rand];
}; # 正解
has event_start_time => sub { return time; }; # イベント開始時刻
has event_end_time => undef; # イベント処理済時刻

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
    $self->save;
}

sub _choice
{
    my $self = shift;

    if ($self->choice eq $self->correct_answer)
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
    my $mes = $self->object("SO::Event::SimpleMessage");
    $mes->chara_id($self->chara_id);
    $mes->parent_id($self->id);
    $mes->message("解除に成功した！");
    $mes->save;
    $self->event_end_time(time);
    $self->continue_id($mes->id);
    $self->save;
    $self->is_continue(0);
}

sub _result2
{
    my $self = shift;
    my $args = shift;
    my $mes = $self->object("SO::Event::SimpleMessage");
    $mes->chara_id($self->chara_id);
    $mes->parent_id($self->id);
    $mes->message("解除に失敗した！");
    $mes->save;
    $self->event_end_time(time);
    $self->continue_id($mes->id);
    $self->save;
    $self->is_continue(0);
}

1;
