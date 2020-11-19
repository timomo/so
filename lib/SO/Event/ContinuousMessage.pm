package SO::Event::ContinuousMessage;

# push @ISA, 'SO::Event::Base';
use Mojo::Base 'SO::Event::SimpleMessage';
use YAML::XS;

has choices => sub { ["次へ"] }; # 選択肢
has event_type => 4; # イベント種別

has messages => sub {
    [
        "./master/town/msg_matsushima.mst",
        "./master/town/msg_yukinoura.mst",
        "./master/town/msg_taira.mst",
        "./master/town/msg_seto.mst",
        "./master/town/msg_ikeshima.mst",
    ];
};

has test_messages => sub {
    [
        {
            話者 => "ゲームマスター",
            文章 => "古代の本を開き、その文字を読み始めた。",
        },
        {
            話者 => "ゲームマスター",
            文章 => "一夜目に雄羊、",
        },
        {
            話者 => "ゲームマスター",
            文章 => "次なるもまた雄羊、",
        },
        {
            話者 => "ゲームマスター",
            文章 => "祭壇の上、輝く光りに三なるものを求め、",
        },
        {
            話者 => "ゲームマスター",
            文章 => "四なる夜の杖、",
        },
        {
            話者 => "ゲームマスター",
            文章 => "五つに再び魔の光り、",
        },
        {
            話者 => "ゲームマスター",
            文章 => "これ祭壇を地にしずめ",
        },
        {
            話者 => "ゲームマスター",
            文章 => "夜に花開かん！",
        },
    ];
};

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
    my $mes = $self->display_message($self->test_messages->[0]);

    # 初期データがない場合にのみ、メッセージを初期化する
    if (! defined $self->message)
    {
        $self->message($mes);
        $self->event_end_time(time);
        $self->save;
    }
}

sub display_message
{
    my $self = shift;
    my $row = shift;
    my $mes = undef;

    if (exists $row->{話者})
    {
        $mes .= "【". $row->{話者}. "】<br />";
    }
    if (exists $row->{文章})
    {
        $mes .= $row->{文章};
    }

    return $mes;
}

sub _choice
{
    my $self = shift;

    my $parent = $self->parent;

    if (! defined $parent)
    {
        my $mes = $self->display_message($self->test_messages->[1]);
        my $event = $self->object(ref $self);
        $event->chara_id($self->chara_id);
        $event->message($mes);
        $event->parent_id($self->id);
        $event->save;
        $self->continue_id($event->id);
        $self->save;
    }
    else
    {
        my $age = $self->age;
        my $mes = $self->display_message($self->test_messages->[$age]);
        if (defined $mes)
        {
            my $event = $self->object(ref $self);
            $event->chara_id($self->chara_id);
            $event->message($mes);
            $event->parent_id($self->id);
            $event->save;
            $self->continue_id($event->id);
            $self->save;
        }
    }
    $self->event_end_time(time);
    $self->save;
}

sub _result1
{
    my $self = shift;
    my $args = shift;


}

1;
