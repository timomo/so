package SO::Event::UnknownTreasure;

# push @ISA, 'SO::Event::Base';
use Mojo::Base 'SO::Event::Base';
use YAML::XS;
use SO::Event::SimpleMessage;
use SO::Event::TrappedTreasure;

has event_type => 1; # イベント種別
has chara_id => undef; # キャラid
has message => "宝箱を発見した！<br />開けますか？"; # メッセージ
has choices => sub { ["開ける", "開けない"] }; # 選択肢
has choice => undef; # 選択
has correct_answer => undef; # 正解
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

    if ($self->choice eq "開ける")
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
    my $class = $self->import("SO::Event::TrappedTreasure");
    my $mes = $class->new(chara_id => $self->chara_id);
    $mes->save;
    $mes->close;
    $self->continue_id($mes->id);
    $self->save;
    $self->is_continue(0);
}

sub _result2
{
    my $self = shift;
    my $args = shift;
    my $class = $self->import("SO::Event::SimpleMessage");
    my $mes = $class->new(chara_id => $self->chara_id);
    $mes->message("あなたは宝箱を開けるのをやめました。");
    $mes->save;
    $mes->close;
    $self->continue_id($mes->id);
    $self->save;
    $self->is_continue(0);
}

1;
