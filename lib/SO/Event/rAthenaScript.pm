package SO::Event::rAthenaScript;

# push @ISA, 'SO::Event::Base';
use Mojo::Base 'SO::Event::SimpleMessage';
use YAML::XS;
use IO::Capture::Stdout;
use IO::Capture::Stderr;
# use Expect;
use 5.010001;
use Mojo::Util qw(xml_escape);
use Text::Diff 'diff';
use Perl::Tidy;

has choices => sub { ["次へ"] }; # 選択肢
has event_type => 5; # イベント種別
has input_data => sub { {} }; # イベントのAUTOLOAD系の情報
has buffer => ""; # メッセージの送信前情報

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
    my $parse = $self->parse_rathena_script(File::Spec->catfile($FindBin::Bin, "master", "EndlessTower.utf8.txt"), 1);
    # my $parse = $self->parse_rathena_script(File::Spec->catfile($FindBin::Bin, "master", "script.txt"), 0);

    $self->paragraph_check($parse);
}

sub _choice
{
    my $self = shift;
    my $parse = $self->parse_rathena_script(File::Spec->catfile($FindBin::Bin, "master", "EndlessTower.utf8.txt"), 1);
    # my $parse = $self->parse_rathena_script(File::Spec->catfile($FindBin::Bin, "master", "script.txt"), 0);

    $self->paragraph_check($parse);
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

    return $mes;
}

sub get_rows
{
    my $self = shift;
    my $rows = shift;
    my @ret;

    if ($self->paragraph == -1)
    {
        return \@ret;
    }

    for my $no (0 .. $#$rows)
    {
        my $row = $rows->[$no];

        if ($self->paragraph >= $row->[0])
        {
            if ($row->[2] =~ /conversation_close/)
            {
                $row->[2] =~ s/>conversation_close\(/>_conversation_close\(/;
            }
            if ($row->[2] =~ /conversation_next/)
            {
                $row->[2] =~ s/>conversation_next\(/>_conversation_next\(/;
            }
            if ($row->[2] =~ /select_choice/)
            {
                $row->[2] =~ s/>select_choice\(/>_select_choice\(/;
            }
            # warn join (", ", ($self->paragraph, @$row));
        }
        else
        {
            # noop
        }
        push(@ret, $row->[2]);
    }

    # warn join (", ", ($self->paragraph, $_, $ret[$_])) for 0 ..  $#ret;

    return \@ret;
}

sub complement_syntax
{
    my $self = shift;
    my $scripts = shift;

    for my $num (0 .. 100)
    {
        my $capture = IO::Capture::Stdout->new;
        $capture->start;
        eval(join("\n", @$scripts));
        $capture->stop;
        if ($@ =~ /Missing right curly or square bracket/)
        {
            # warn "rethrow: $@";
            push(@$scripts, "}");
        }
        else
        {
            last;
        }
    }

    return $scripts;
}

sub paragraph_check
{
    my $self = shift;
    my $rows = shift;
    my @ret;
    my $stdout;
    my $tmp = $self->get_rows($rows);
    $self->complement_syntax($tmp);
    @ret = @$tmp;
    my $close = 0;

    for my $num (0 .. 10)
    {
        my $capture = IO::Capture::Stdout->new;
        warn "num = $num";
        $capture->start;
        eval(join("\n", @ret));
        $capture->stop;

        if ($@ =~ /メッセージ破棄/)
        {
            $stdout = "&nbsp;";
            warn "skip: $@";
            # warn Dump $self->choices;
            last;
        }
        elsif ($@ =~ /てへ/ || $@ =~ /__CLOSE__/)
        {
            if ($@ =~ /__CLOSE__/)
            {
                $close = 1;
            }

            my @tmp = @ret;
            unshift(@tmp, $self->get_mock_class_string);
            my $file = Mojo::File->new("test2.pl");
            $tmp[$_] = Encode::encode_utf8($tmp[$_]) for 0 .. $#tmp;
            $file->spurt(join("\n", @tmp));

            my @stdout = $capture->read;
            my $res = join("", @stdout);

            warn "skip: $@";

            if ($res eq "")
            {
                warn "here";
            }
            else
            {
                $stdout = $res;
                warn "no here";
                last;
            }
        }
        elsif ($@ eq "")
        {
            my @stdout = $capture->read;
            my $res = join("", @stdout);

            if ($self->paragraph != -1)
            {
                $self->paragraph($self->paragraph + 1);
                $self->save;
                $tmp = $self->get_rows($rows);
                $self->complement_syntax($tmp);
                @ret = @$tmp;

                my @tmp = @ret;
                unshift(@tmp, $self->get_mock_class_string);
                my $file = Mojo::File->new("test2.pl");
                $file->spurt(join("\n", @tmp));
            }
            else
            {
                last;
            }

            # TODO: どうやらここに来る事がある模様
            warn "pppppppppppppppppppppppppppppppppppppp";
            # warn $res;
        }
        else
        {
            warn $@;
            die $@;
        }
    }

    if (defined $stdout)
    {
        $self->save;
        my $event = $self->object(ref $self);
        $event->paragraph($self->paragraph);
        $event->parent_id($self->id);

        if ($close == 1)
        {
            $event->event_end_time(time);
        }

        $event->save;
        $self->message(Encode::decode_utf8($stdout));
    }
    $self->event_end_time(time);
    $self->save;

    return $stdout;
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

            $self->input_data->{$method} = $val;

            return 0;
            # warn YAML::XS::Dump($self);
        };
    }
    goto &$method;
}

sub switch
{
    my $self = shift;
    my $args = shift;

    # warn "------------------------>switch";
    # warn Dump($args);

    $self->case($args);
}

sub _select_choice
{
    my $self = shift;
    my $paragraph = shift;
    my $mes = shift;
    my @tmp = split(":", $mes);
    my $dummy = $self->object(ref $self);
    my $event = $self;
    my $select;

    $self->paragraph($paragraph);
    $self->save;

    while(my $parent = $event->parent)
    {
        if ($paragraph == $parent->paragraph)
        {
            $select = $parent;
            last;
        }
        $event = $parent;
    }

    if (defined $select)
    {
        # warn Dump($select->generate);
        # warn Dump($select->choice);
        return int($select->choice + 1);
    }

    return undef;
}

sub select_choice
{
    my $self = shift;
    my $paragraph = shift;
    my $mes = shift;
    my @tmp = split(":", $mes);

    $tmp[$_] = $self->trim($tmp[$_]) for 0 .. $#tmp;

    $self->choices(\@tmp);
    $self->paragraph($paragraph);
    $self->save;

    die "メッセージ破棄";
}

sub JobLevel
{
    my $self = shift;
    return 41;
}

sub ALCHE_SK
{
    my $self = shift;
    return 1;
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

sub _conversation_next
{
    my $self = shift;
    my $paragraph = shift;

    $self->paragraph($paragraph);

    warn "---------------------------->メッセージ破棄開始1";
    warn Encode::encode_utf8($self->buffer);
    warn "---------------------------->メッセージ破棄終了1";
    $self->buffer(undef);
    $self->save;

    # die "てへ";
}

sub conversation_next
{
    my $self = shift;
    my $paragraph = shift;
    my $event = $self->object(ref $self);

    $self->paragraph($paragraph);
    $self->save;

    print Encode::encode_utf8($self->buffer);
    $self->buffer(undef);
    $self->save;

    die "てへ";
}

sub conversation_close
{
    my $self = shift;
    my $paragraph = shift;
    my $event = $self->object(ref $self);

    # $self->paragraph(-1);
    $self->event_end_time(time);
    $self->save;

    print Encode::encode_utf8($self->buffer);
    $self->buffer(undef);
    $self->save;

    die "__CLOSE__";
}

sub mes
{
    my $self = shift;
    my $line = shift;

    my $message = $self->buffer;
    $message .= $self->trim($line). "<br />\n";

    $self->buffer($message);

    return 1;
}

sub _result1
{
    my $self = shift;
    my $args = shift;
}

sub _parse_rathena_script
{
    my $self = shift;
    my $path = shift;
    my $file = Mojo::File->new($path);
    my $content = $file->slurp;
    $self->__parse_rathena_script($content);
}

sub __parse_rathena_script
{
    my $content = shift;
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

sub parse_rathena_script
{
    my $self = shift;
    my $path = shift;
    my $number = shift;
    my $file = Mojo::File->new($path);
    my $content = $file->slurp;
    {
        my $utf8 = Encode::decode_utf8($content);
        $content = $utf8;
    }
    $content =~ s/\r\n|\r|\n/\n/g;
    my @dummy = split(/\n/, $content);

    # my $root_paragraph = $self->get_paragraph($dummy[0]);
    my $map = {};
    my $key = undef;
    my @ary;
    my $map2 = {};

    for my $no (0 ..$#dummy)
    {
        my $line = $dummy[$no];
        # my $paragraph = $self->get_paragraph($line);

        push(@ary, $line);

        if ($line =~ qr|^//| || $line =~ qr|^\s*$|)
        {
            next;
        }

        if ($line =~ /script/)
        {
            if ($line ne $key)
            {
                $map->{$key} = $no;
                $key = $line;
            }
        }
    }

    my @keys = sort { $map->{$a} <=> $map->{$b} } keys %$map;

    if (scalar(@keys) != 1)
    {
        for my $no (1 .. $#keys)
        {
            my $now = $keys[$no];
            my $prev = $keys[$no - 1];
            my $now_no = $map->{$now};
            my $prev_no = $map->{$prev};
            $map2->{$now} ||= [];
            my @lines = @ary[$prev_no .. $now_no];
            push(@{$map2->{$now}}, @lines);
        }
    }
    elsif (scalar(@keys) == 1)
    {
        my $now = $keys[0];
        my $prev = $keys[0];
        my $now_no = $#ary;
        my $prev_no = 0;
        $map2->{$now} ||= [];
        my @lines = @ary[$prev_no .. $now_no];
        push(@{$map2->{$now}}, @lines);
    }

    my $current = $keys[$number];
    my $content2 = join("\n", @{$map2->{$current} || []});

    if ($content2 =~ m/(.+?)(\{)(.+?)\n(\})/s)
    {
        # TODO: なぜか括弧を付け加えないと括弧がずれる
        my $titie = $1;
        my $right = $2;
        my $body = $3;

        # case文~case文~括弧閉じるは別処理

        if (0)
        {
            while($body =~ /case (\d+):(.+?)case (\d+):(.+?)\}/s)
            {
                my $diff1 = $body;
                $body =~ s/case (\d+):(.+?)case (\d+):(.+?)\}/if (\$self->case eq "$1") {$2} if (\$self->case eq "$3") { $4 }}/gs;
                my $diff2 = $body;
                my $diff = diff(\$diff1, \$diff2);
            }
        }

        my $left = $4;
        my $ref = $self->parse_script($body);
        my @mes = @$ref;
        my $num = 0;
        my @hits2;

        for my $elm (@mes)
        {
            my @tmp2 = split(/\[(\d+)\]:/, $elm);

            push(@hits2, [$num, int($tmp2[1]), $tmp2[2]]);

            $num++;
        }

        my $choices = $self->choices;
        my $choice;
        if ($self->paragraph == 0 || ! defined $self->paragraph || $self->paragraph eq "")
        {
            # $self->paragraph(1);
        }

        if (ref $choices ne "ARRAY")
        {
            $choices = YAML::XS::Load(Encode::encode_utf8($self->choices));
            $choice = $choices->[$self->choice];
        }

        my @tmp;
        for my $elm (@hits2)
        {
            push(@tmp, $elm);
        }

        return \@tmp;
    }
}

sub get_paragraph
{
    my $self = shift;
    my $body = shift;
    $body =~ s/\r\n|\r|\n//g;
    my @list = split //, $body;
    my $count = 0;

    for my $str (@list)
    {
        if ($str =~ /\t/)
        {
            $count++;
        }
        else
        {
            last;
        }
    }

    return $count;
}

sub parse_script
{
    my $self = shift;
    my $body = shift;
    my @tmp = split("{", $body);
    my @ret;

    for my $no (0 .. $#tmp)
    {
        my $line = $tmp[$no];
        my $paragraph = $self->get_paragraph($line);

        $line =~ s/\r\n|\r|\n/\n/g;

        if ($#tmp != $no)
        {
            $line =~ s/$/{/g;
        }

        if ($line =~ /mes/)
        {
            if ($line =~ /if/)
            {
                my @tmp2 = split("\n", $line);
                my $ret;
                my $cnt = 0;

                for my $line2 (@tmp2)
                {
                    my $paragraph2 = $self->get_paragraph($line2) || 0;

                    $line2 =~ s/\r\n|\r|\n/\n/g;
                    $line2 =~ s/^\s+|\s+$//g;

                    if ($line2 =~ /^$/)
                    {
                        next;
                    }

                    push(@{$ret}, "[$paragraph2]:$line2");
                }

                push(@ret, @$ret);
            }
            else
            {
                my @tmp2 = split("\n", $line);
                my $ret;
                my $cnt = 0;

                for my $line2 (@tmp2)
                {
                    my $paragraph2 = $self->get_paragraph($line2) || 0;

                    $line2 =~ s/\r\n|\r|\n/\n/g;
                    $line2 =~ s/^\s+|\s+$//g;

                    if ($line2 =~ /^$/)
                    {
                        next;
                    }

                    if ($paragraph2 == 0)
                    {
                        # warn "まじで！？";
                        # warn $line2;
                        # warn "まじで！？";
                        # next;
                    }

                    # warn "------------->[$paragraph2]:$line2";

                    push(@{$ret}, "[$paragraph2]:$line2");
                }

                push(@ret, @$ret);
            }
        }
        else
        {
            $line =~ s/^\s+|\s+$//g;

            push(@ret, "[$paragraph]:$line");
        }
    }

    # 中間データ1を吐き出し
    {
        my @tmp3;
        for my $elm (@ret)
        {
            my @tmp2 = split(/\[(\d+)\]:/, $elm);
            my $string = "\t" x $tmp2[1];
            push(@tmp3, $string. $tmp2[2]);
        }
        my $file = Mojo::File->new("intermediate_data1.pl");

        $tmp3[$_] = Encode::encode_utf8($tmp3[$_]) for 0 .. $#tmp3;

        $file->spurt(join("\n", @tmp3));
    }

    my $para = 0;
    my $switch = 0;
    my $case = 0;

    for my $no (0 .. $#ret)
    {
        my $elm = $ret[$no];
        my @tmp2 = split(/\[(\d+)\]:/, $elm);
        my $mes = $tmp2[2];
        my @words = (qw|Zeny in_102tower JobLevel BaseJob BaseLevel Job_Priest Job_Monk BaseClass Job_Acolyte SKILL_PERM Job_Alchemist ALCHE_SK Sex SEX_FEMALE SEX_MALE break|);

        # TODO: ここに関しては、無理やりswitch文のcase用に括弧を足しているので、処理が怪しい。。。
        if ($case == 1 && $para == $tmp2[1])
        {
            if ($mes =~ /^\}$/)
            {
                # warn Dump([$para, $mes]);

                $case = 0;
                $para = 0;
                $tmp2[2] = "}}";
            }
        }

        if ($mes =~ /case (\d):/)
        {
            $case = 1;
            $para = $tmp2[1];
            if ($1 == 1)
            {
                $mes = "if (\$self->case eq \"$1\") {";
            }
            else
            {
                $mes = "} if (\$self->case eq \"$1\") {";
            }
            $tmp2[2] = $mes;
        }
        if ($mes =~ qr|//|)
        {
            $mes =~ s|//|# |;
            $tmp2[2] = $mes;
        }
        if ($mes =~ /else if/)
        {
            $mes =~ s|else if|elsif|;
            $tmp2[2] = $mes;
        }
        if ($mes =~ /^(switch.+)\{/)
        {
            $para = $tmp2[1];
            $switch = 1;
            $mes = "if(\$self->". $1. ") {";
            $tmp2[2] = $mes;
        }
        if ($mes =~ /rand\(/)
        {
            $mes =~ s|rand\(|\$self->random(|;
            $tmp2[2] = $mes;
        }
        if ($mes =~ /select\(/)
        {
            $mes =~ s|select\(|\$self->select_choice($no, |;
            $tmp2[2] = $mes;
        }
        if ($mes =~ /next;/)
        {
            $mes =~ s|next;|\$self->conversation_next($no);|;
            $tmp2[2] = $mes;
        }
        if ($mes =~ /end;/)
        {
            $mes =~ s|end;|\$self->conversation_end($no);|;
            $tmp2[2] = $mes;
        }
        if ($mes =~ /close2;/)
        {
            $mes =~ s|close2;|\$self->conversation_close2($no);|;
            $tmp2[2] = $mes;
        }
        if ($mes =~ /close;/)
        {
            $mes =~ s|close;|\$self->conversation_close($no);|;
            $tmp2[2] = $mes;
        }
        if ($mes =~ /EF_SUI_EXPLOSION/)
        {
            $mes =~ s|EF_SUI_EXPLOSION|\$self->EF_SUI_EXPLOSION()|;
            $tmp2[2] = $mes;
        }
        if ($mes =~ /specialeffect/)
        {
            $mes =~ s|specialeffect (.+);|\$self->specialeffect($1);|;
            $tmp2[2] = $mes;
        }
        if ($mes =~ /strcharinfo\(/)
        {
            $mes =~ s|strcharinfo\(|\$self->strcharinfo(|;
            $tmp2[2] = $mes;
        }
        if ($mes =~ /mes/)
        {
            $mes =~ s/mes "(.+)";/\$self->mes("$1");/g;
            $tmp2[2] = $mes;
        }
        if ($mes =~ /warp/)
        {
            # warp "e_tower",70,114;
            $mes =~ s/warp (.+),(.+),(.+);/\$self->warp($1, $2, $3);/g;
            $tmp2[2] = $mes;
        }
        if ($mes =~ /menu/)
        {
            # menu "一人で行くつもりですか？",-;
            $mes =~ s/menu (.+),\s*(-);/\$self->menu($1, '$2');/g;
            $tmp2[2] = $mes;
        }
        if ($mes =~ /\.\@.+\$/)
        {
            if ($mes =~ /set/)
            {
                # noop
            }
            else
            {
                $mes =~ s/\.\@(.+?)(\$)/\$self->get('.\@$1\$')/g;
            }
            # $mes =~ s/\.\@(.+?)(\$)/".__At_Mark__$1__Dollar_Mark__"/g;
            $tmp2[2] = $mes;
        }
        if ($mes =~ /set/)
        {
            $mes =~ s/set (.+),(.+);/\$self->set('$1', $2);/g;
            $tmp2[2] = $mes;
        }
        if ($mes =~ /delitem/)
        {
            $mes =~ s/delitem (.+);/\$self->delitem($1);/g;
            $tmp2[2] = $mes;
        }
        if ($mes =~ /getitem/)
        {
            $mes =~ s/getitem (.+);/\$self->getitem($1);/g;
            $tmp2[2] = $mes;
        }
        if ($mes =~ /countitem/)
        {
            $mes =~ s/countitem/\$self->countitem/g;
            $tmp2[2] = $mes;
        }
        if ($mes =~ /getskilllv/)
        {
            $mes =~ s/getskilllv\s*\((.+)\)/\$self->getskilllv($1)/g;
            $tmp2[2] = $mes;
        }
        if ($mes =~ /skill/)
        {
            $mes =~ s/skill "(.+)",(\d+),(.+);/\$self->skill("$1", $2, "$3");/g;
            $tmp2[2] = $mes;
        }
        if ($mes =~ /mes/ && $mes =~ /\+/)
        {
            $mes =~ s/\+/./g;
            $tmp2[2] = $mes;
        }
        if ($#ret == $no)
        {
            # $mes = "}}}}}";
            # $tmp2[2] = $mes;
        }

        for my $regex (@words)
        {
            if ($mes =~ /($regex)/)
            {
                if ($mes =~ /mes.+($regex)/)
                {

                }
                elsif ($mes =~ /switch.+($regex)/)
                {

                }
                elsif ($mes =~ /["']($regex)["']/)
                {
                    if ($regex eq "Zeny")
                    {
                        $mes =~ s/Zeny\-(\d+)/Zeny - $1/g;
                    }
                    $mes =~ s/[^"']($regex)[^"']/\$self->$1()/g;
                }
                else
                {
                    # warn "2:".$mes;
                    $mes =~ s/($regex)/\$self->$1()/g;
                }
                $tmp2[2] = $mes;
            }
        }

        $ret[$no] = sprintf("[%d]:%s", $tmp2[1], $tmp2[2]);

        # warn $ret[$no];
    }

    # 中間データ2を吐き出し
    {
        my @tmp3;
        for my $elm (@ret)
        {
            my @tmp2 = split(/\[(\d+)\]:/, $elm);
            # warn $tmp2[1];

            my $string = "\t" x $tmp2[1];

            push(@tmp3, $string. $tmp2[2]);
        }
        my $file = Mojo::File->new("intermediate_data2.pl");
        my $file2 = Mojo::File->new("intermediate_data_tidy.pl");
        $tmp3[$_] = Encode::encode_utf8($tmp3[$_]) for 0 .. $#tmp3;

        {
            my @tmp4 = @tmp3;
            unshift(@tmp4, $self->get_mock_class_string);
            my $source_string = join("\n", @tmp4);
            my $dest_string;
            my $stderr_string;
            my $errorfile_string;
            my $argv = "-npro";   # Ignore any .perltidyrc at this site
            $argv .= " -pbp";     # Format according to perl best practices
            $argv .= " -nst";     # Must turn off -st in case -pbp is specified
            $argv .= " -se";      # -se appends the errorfile to stderr

            my $error = Perl::Tidy::perltidy(
                argv        => $argv,
                source      => \$source_string,
                destination => \$dest_string,
                stderr      => \$stderr_string,
                errorfile   => \$errorfile_string,    # ignored when -se flag is set
                ##phasers   => 'stun',                # uncomment to trigger an error
            );

            $file2->spurt($dest_string);
        }

        $file->spurt(join("\n", @tmp3));
    }

    return \@ret;
}

sub get_mock_class_string
{
    my $self = shift;
    my $class = <<EOF;
package Mock;

use Mojo::Base -base;

has paragraph => 0;
has case => "";

sub random
{
    my \$self = shift;
}

sub JobLevel
{
    return 41;
}

sub AUTOLOAD
{
    our \$AUTOLOAD;
    my (\$method) = (\$AUTOLOAD =~ /([^:']+\$)/);
    {
        warn "-------->\$method";
        no strict 'refs';
        *{\$method} = sub {
            use strict 'refs';
            my (\$self, \$val) = \@_;
            return 0;
            # warn YAML::XS::Dump(\$self);
        };
    }
    goto &\$method;
}

sub conversation_close
{
    my \$self = shift;
    exit;
}

sub conversation_next
{
    my \$self = shift;
    # my \$in = <STDIN>;
    # chomp(\$in);
    \$self->paragraph(\$self->paragraph + 1);
}

sub mes
{
    my \$self = shift;
    my \$mes = shift;

    print \$mes, "\\n";
}

sub switch
{
    my \$self = shift;
    my \$args = shift;
    \$self->case(\$args);
}

sub _select_choice
{
    my \$self = shift;
    return 1;
}

sub ALCHE_SK
{
    my \$self = shift;
    return 2;
}

package main;

my \$self = Mock->new;
EOF
    return $class;
}

1;
