package SO::Event::SimpleMessage;

# push @ISA, 'SO::Event::Base';
use Mojo::Base 'SO::Event::Base';
use YAML::XS;

has event_type => 0; # イベント種別
has chara_id => undef; # キャラid
has message => undef; # メッセージ
has choices => sub { ["はい"] }; # 選択肢
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
    $self->event_end_time(time);
    $self->save;
}

sub _choice
{
    my $self = shift;

    warn "_choice";
}

sub _result1
{
    my $self = shift;
    my $args = shift;

    warn "_result1";
}

1;
