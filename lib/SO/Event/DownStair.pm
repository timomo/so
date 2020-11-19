package SO::Event::DownStair;

# push @ISA, 'SO::Event::Base';
use Mojo::Base 'SO::Event::Base';
use SO::Event::SimpleMessage;

has event_type => 3; # イベント種別
has chara_id => undef; # キャラid
has message => "下り階段を発見した！<br />降りますか？"; # メッセージ
has choices => sub { ["はい", "いいえ"] }; # 選択肢
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

    if ($self->choice eq "はい")
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
    my $class = $self->import("SO::Event::SimpleMessage");
    my $mes = $class->new(chara_id => $self->chara_id);

    $mes->parent_id($self->id);
    $mes->message("階段を降りました。");
    $mes->save;

    my $append = $self->system->load_append($self->id);
    $append->{階数}++;

    $self->system->save_append_db($append);

    $self->event_end_time(time);
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
    $mes->parent_id($self->id);
    $mes->message("降りるのをやめました。");
    $mes->save;
    $self->event_end_time(time);
    $self->continue_id($mes->id);
    $self->save;
    $self->is_continue(0);
}

1;
