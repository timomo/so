package SO::Event::rAthenaScript;

# push @ISA, 'SO::Event::Base';
use Mojo::Base 'SO::Event::SimpleMessage';
use YAML::XS;

has choices => sub { ["次へ"] }; # 選択肢
has event_type => 5; # イベント種別

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
    my $parse = $self->parse_rathena_script(File::Spec->catfile($FindBin::Bin, "master", "script.txt"));
    my @mes;
    my $paragraph = 0;

    for my $line (@{$parse->{""}->{$paragraph}})
    {
        push(@mes, $self->trim($line));
    }

    # 初期データがない場合にのみ、メッセージを初期化する
    if (! defined $self->message)
    {
        $self->message(join("<br />", @mes));
        $self->event_end_time(time);
        $self->save;
    }
}

sub trim
{
    my $self = shift;
    my $mes = shift;

    if ($mes =~ /mes/)
    {
        $mes =~ s/^mes ['"]//;
        $mes =~ s/['"];$//;
    }
    if ($mes =~ /\^[0-9A-F]{6}/)
    {
        $mes =~ s/\^([0-9A-F]{6})/<span style="color: #$1;">/g;
        $mes =~ s/color: #000000;/color: #FFFFFF;/g;
    }
    if ($mes =~ /next;|close;/)
    {
        $mes = "";
    }
    return $mes;
}

sub _choice
{
    my $self = shift;
    my $parent = $self->parent;
    my $parse = $self->parse_rathena_script(File::Spec->catfile($FindBin::Bin, "master", "script.txt"));
    my $age = $self->age;

    if (! defined $parent)
    {
        my $paragraph = $self->paragraph;
        $paragraph++;
        my @mes;
        my $event = $self->object(ref $self);

        if ($parse->{""}->{$paragraph}->[0] eq "---select")
        {
            shift(@{$parse->{""}->{$paragraph}});
            for my $line (@{$parse->{""}->{$paragraph}})
            {
                push(@mes, $self->trim($line));
            }
            $event->choices(\@mes);
        }
        else
        {
            for my $line (@{$parse->{""}->{$paragraph}})
            {
                push(@mes, $self->trim($line));
            }
            $event->message(join("<br />", @mes));
        }

        $event->paragraph($paragraph);
        $event->chara_id($self->chara_id);
        $event->parent_id($self->id);
        $event->save;
        $self->continue_id($event->id);
        $self->save;
    }
    else
    {
        my $paragraph = $self->paragraph;
        my %tmp;
        my $choices = YAML::XS::Load(Encode::encode_utf8($self->choices));
        $tmp{$choices->[$_]} = $_ for 0 .. $#$choices;
        my $number = $tmp{$self->choice} + 1;
        my $case = $self->case;

        if ($self->choice ne "次へ")
        {
            $case = sprintf("case %s", $number);
            $paragraph = 0;
        }
        else
        {
            $paragraph++;
        }

        my @mes;
        my $event = $self->object(ref $self);

        if ($parse->{$case}->{$paragraph}->[0] eq "---select")
        {
            shift(@{$parse->{$case}->{$paragraph}});
            for my $line (@{$parse->{$case}->{$paragraph}})
            {
                push(@mes, $self->trim($line));
            }
            $event->choices(\@mes);
        }
        else
        {
            my $ary = $parse->{$case}->{$paragraph};
            if (scalar @$ary != 0)
            {
                for my $line (@{$parse->{$case}->{$paragraph}})
                {
                    push(@mes, $self->trim($line));
                }
                $event->message(join("<br />", @mes));
            }
        }

        if (defined $event->message)
        {
            $event->case($case);
            $event->paragraph($paragraph);
            $event->chara_id($self->chara_id);
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

sub parse_rathena_script
{
    my $self = shift;
    my $path = shift;
    my $file = Mojo::File->new($path);
    my $content = $file->slurp;
    my @contents = split(/\r\n|\r|\n/, $content);
    my $break = qr/(?:next;|close;)/;

    shift(@contents); # prt_church,173,23,4	script	Cleric	79,{
    pop(@contents); # }

    my $skip1 = 1;
    my $para = {};
    my @tmp;
    my $skip2 = 0;
    my $case = "";

    for my $line (@contents)
    {
        my $count = (() = $line =~ m/\t/g);
        $line =~ s/\t//g;

        push(@tmp, $line);

        if ($line =~ /next;|close;|switch|case/)
        {
            if ($line =~ /(case \d+):/)
            {
                if ($case ne $1)
                {
                    $para->{$case} ||= [];
                    push(@{$para->{$case}}, @tmp);
                    @tmp = undef;
                    $case = $1;
                }
            }
        }
    }

    $para->{$case} ||= [];
    push(@{$para->{$case}}, @tmp);

    my $test = {};

    for my $key (keys %$para)
    {
        my $ary = $para->{$key};
        my @tmp1;
        my $cnt1 = 0;

        for my $no (0 .. $#$ary)
        {
            my $line = $ary->[$no] || "";
            if ($line =~ /switch \(select\("(.+?)"\)\)/)
            {
                my $hit = $1;
                my @hits = split(":", $hit);
                unshift(@hits, "---select");
                $test->{$key}->{$cnt1} ||= [];
                push(@{$test->{$key}->{$cnt1}}, @hits);
            }
            push(@tmp1, $line);
            if ($line !~ /^(?:next|close);$/)
            {
                next;
            }
            $test->{$key} ||= {};
            $test->{$key}->{$cnt1} ||= [];
            push(@{$test->{$key}->{$cnt1}}, @tmp1);
            $cnt1++;
            @tmp1 = undef;
        }
    }

    return $test;
}


1;
