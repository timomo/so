package SO::Event::rAthenaScript;

# push @ISA, 'SO::Event::Base';
use Mojo::Base 'SO::Event::SimpleMessage';
use YAML::XS;
use IO::Capture::Stdout;

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
        push(@mes, trim($line));
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
        my $case = "";

        if ($parse->{$case}->{$paragraph}->[0] eq "---select")
        {
            shift(@{$parse->{$case}->{$paragraph}});
            for my $line (@{$parse->{$case}->{$paragraph}})
            {
                push(@mes, trim($line));
            }
            $event->choices(\@mes);
        }
        else
        {
            $event->message($self->paragraph_check($parse->{$case}->{$paragraph}));
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
        my @mes;
        my $event = $self->object(ref $self);
        my $paragraph = $self->paragraph;
        my $case = $self->case;
        my $choices = YAML::XS::Load(Encode::encode_utf8($self->choices));
        my $choice = $choices->[$self->choice];

        if ($choice ne "次へ")
        {
            my $number = $self->choice + 1;
            $case = sprintf("case %s", $number);
            $paragraph = 0;
        }
        else
        {
            $paragraph++;
        }
        $event->case($case);
        $event->paragraph($paragraph);

        if ($parse->{$case}->{$paragraph}->[0] eq "---select")
        {
            shift(@{$parse->{$case}->{$paragraph}});
            for my $line (@{$parse->{$case}->{$paragraph}})
            {
                push(@mes, trim($line));
            }
            $event->choices(\@mes);
        }
        else
        {
            my $ary = $parse->{$case}->{$paragraph};
            if (scalar @$ary != 0)
            {
                $event->message($self->paragraph_check($parse->{$case}->{$paragraph}));
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

sub paragraph_check
{
    my $self = shift;
    my $rows = shift;
    my @ret;
    my $lines = join("\n", @$rows);

    $lines =~ s/^(\s+)*\}//;
    if ($lines =~ /if /)
    {
        if ($lines !~ /\}$/)
        {
            $lines .= "\n}";
        }
    }
    $lines =~ s|//|# |g;
    $lines =~ s/close;//g;
    $lines =~ s/next;//g;

    my @contents = split("\n", $lines);
    my $words = qr/JobLevel|BaseJob|Job_Priest|Job_Monk|BaseClass|Job_Acolyte|SKILL_PERM/;

    for my $syntax (@contents)
    {
        if ($syntax =~ /^\s+$/ || $syntax eq "")
        {
            next;
        }
        if ($syntax =~ /($words)/)
        {
            $syntax =~ s/($words)/\$self->$1()/g;
        }
        if ($syntax =~ /(delitem)\s+(.+);/)
        {
            $syntax = "\$self->$1($2);";
        }
        if ($syntax =~ /^skill (.+);/)
        {
            $syntax = "\$self->skill($1);";
        }
        if ($syntax =~ /getskilllv/)
        {
            $syntax =~ s/(getskilllv)/\$self->$1/g;
        }
        if ($syntax =~ /countitem/)
        {
            $syntax =~ s/(countitem)/\$self->$1/g;
        }

        push(@ret, $syntax);
    }

    $lines = join("\n", @ret);

    warn $lines;

    my $capture = IO::Capture::Stdout->new;
    $capture->start;
    eval($lines);
    $capture->stop;
    if ($@)
    {
        warn $@;
    }

    my @stdout = $capture->read;

    return join("", @stdout);
}

sub AUTOLOAD
{
    our $AUTOLOAD;
    my ($method) = ($AUTOLOAD =~ /([^:']+$)/);
    {
        warn "-------->$method";
        no strict 'refs';
        *{$method} = sub {
            use strict 'refs';
            my ($self, $val) = @_;
            # warn YAML::XS::Dump($self);
        };
    }
    goto &$method;
}

# アイテムを消す
sub delitem
{
    my $self = shift;
    my ($item_id, $num) = @_;
    my $item = $self->system->pickup_item($self->chara_id, $item_id);

    if (ref $item eq "HASH")
    {
        $item->{所持数} -= $num;
        $self->system->save_item_db($self->chara_id, [ $item ]);
    }
}

# アイテムを数える
sub countitem
{
    my $self = shift;
    my $item_id = shift;
    my $item = $self->system->pickup_item($self->chara_id, $item_id);

    if (ref $item eq "HASH")
    {
        return $item->{所持数};
    }
    return 0;
}

sub here
{
    my $self = shift;
    warn "here";
}

sub mes
{
    my $line = shift;
    print trim($line). "<br />\n";
    return 1;
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
