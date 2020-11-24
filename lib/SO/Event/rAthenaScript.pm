package SO::Event::rAthenaScript;

# push @ISA, 'SO::Event::Base';
use Mojo::Base 'SO::Event::SimpleMessage';
use YAML::XS;
use IO::Capture::Stdout;
use IO::Capture::Stderr;
# use Expect;
use 5.010001;
use Mojo::Util qw(xml_escape);

has choices => sub { ["次へ"] }; # 選択肢
has event_type => 5; # イベント種別
has input_data => sub { {} }; # イベントのAUTOLOAD系の情報

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
    my $parse = $self->parse_rathena_script(File::Spec->catfile($FindBin::Bin, "master", "alchemist_skills.txt"));
    # my $parse = $self->_parse_rathena_script(File::Spec->catfile($FindBin::Bin, "master", "script.txt"));

    # 初期データがない場合にのみ、メッセージを初期化する
    if (! defined $self->message)
    {
        my @tmp;
        for my $elm (@$parse)
        {
            push(@tmp, $elm->[2]);
        }
        $self->message($self->paragraph_check($parse));
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

    return $mes;
}

sub _choice
{
    my $self = shift;
    my $parent = $self->parent;
    my $parse = $self->parse_rathena_script(File::Spec->catfile($FindBin::Bin, "master", "alchemist_skills.txt"));
    # my $parse = $self->_parse_rathena_script(File::Spec->catfile($FindBin::Bin, "master", "script.txt"));
    my $choices = YAML::XS::Load(Encode::encode_utf8($self->choices));
    my $choice = $choices->[$self->choice];
    my $event = $self->object(ref $self);
    my $message = undef;

    if (! defined $parent)
    {
        my @tmp;
        for my $elm (@$parse)
        {
            push(@tmp, $elm->[2]);
        }

        if ($tmp[0] eq "---select")
        {
            $event->choices(\@tmp);
        }
        else
        {
            $message = $self->paragraph_check($parse);
        }

        if ($message ne "")
        {
            $event->message($message);
            $event->paragraph($self->paragraph);
            $event->chara_id($self->chara_id);
            $event->parent_id($self->id);
            $event->save;
            $self->continue_id($event->id);
            $self->save;
        }
    }
    else
    {
        my @tmp;
        for my $elm (@$parse)
        {
            push(@tmp, $elm->[2]);
        }

        if ($tmp[0] eq "---select")
        {
            $event->choices(\@tmp);
        }
        else
        {
            $message = $self->paragraph_check($parse);
        }

        if ($message ne "")
        {
            $event->message($message);
            $event->paragraph($self->paragraph);
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

sub get_rows
{
    my $self = shift;
    my $rows = shift;
    my @ret;

    warn "------------------->";
    warn $self->paragraph;
    warn "------------------->";

    for my $row (@$rows)
    {
        # TODO: 明日はここから！
        push(@ret, $row->[2]);
    }

    # warn Dump \@ret;

    return \@ret;
}

sub toggle_mes
{
    my $self = shift;
    my $row = shift;
    my $type = shift;
    my $mes = $row->[2];

    if ($type == 1 && $mes =~ />mes\(/)
    {
        $mes =~ s/>mes\(/>no_mes(/g;
    }
    if ($type == 2 && $mes =~ />no_mes\(/)
    {
        $mes =~ s/>no_mes\(/>mes(/g;
    }

    $row->[2] = $mes;

    # warn Dump $row;
}

sub paragraph_check
{
    my $self = shift;
    my $rows = shift;
    my @ret;

    my $tmp = $self->get_rows($rows);
    @ret = @$tmp;

    my $stdout;

    my $capture = IO::Capture::Stdout->new;

    for my $num (0 .. 100)
    {
        warn "num = $num";
        $capture->start;
        eval(join("\n", @ret));
        $capture->stop;
        if ($@ =~ /Missing right curly or square bracket/)
        {
            push(@ret, "}");
            # warn $@;
        }
        elsif ($@ eq "")
        {
            my @tmp = @ret;
            unshift(@tmp, $self->get_mock_class_string);
            my $path = File::Spec->catfile($FindBin::Bin, "test2.pl");
            my $file = Mojo::File->new($path);
            $file->spurt(join("\n", @tmp));

            my @stdout = $capture->read;
            my $res = join("", @stdout);

            if ($res eq "")
            {
                $self->paragraph($self->paragraph + 1);
                $self->save;
                my $tmp2 = $self->get_rows($rows);
                @ret = @$tmp2;
                warn "here";
            }
            else
            {
                $stdout = $res;
                warn "no here";
                last;
            }
        }
        else
        {
            warn $@;
            die $@;
        }
    }

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

sub select_choice
{
    my $self = shift;
    my $mes = shift;
    my @tmp = split(":", $mes);
    my $choice = $self->choice;

    if ($choice eq "")
    {
        # noop
    }
    else
    {
        $self->choice(undef);
        $self->save;
        return $choice;
    }

    $self->choices(\@tmp);
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

sub here
{
    my $self = shift;
    warn "here";
}

sub mes
{
    my $self = shift;
    my $line = shift;

    print $self->trim($line), "<br />\n";
    return 1;
}

sub no_mes
{
    my $self = shift;
    my $line = shift;

    # warn $self->trim($line). "\n";
    # return 1;
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
    my $file = Mojo::File->new($path);
    my $content = $file->slurp;
    $content =~ s/\r\n|\r|\n/\n/;

    if ($content =~ m/(.+?)(\{)(.+?)\n(\})/s)
    {
        my $titie = $1;
        my $right = $2;
        my $body = $3;
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

        if ($choice eq "次へ")
        {
            # $self->paragraph($self->paragraph + 1);
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
    my $count;

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
        $line =~ s/$/{/g;

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
                    # $line2 =~ s/^\t+|\t+$//g;

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
                    # $line2 =~ s/^\t+|\t+$//g;

                    if ($line2 =~ /^$/)
                    {
                        next;
                    }

                    if ($paragraph2 == 0)
                    {
                        next;
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

    my @disp;

    for my $no (0 .. $#ret)
    {
        my $elm = $ret[$no];
        my @tmp2 = split(/\[(\d+)\]:/, $elm);
        my $mes = $tmp2[2];
        my $words = qr/JobLevel|BaseJob|Job_Priest|Job_Monk|BaseClass|Job_Acolyte|SKILL_PERM|Job_Alchemist|ALCHE_SK|Sex|SEX_FEMALE|SEX_MALE|break/;

        if ($mes =~ /case (\d):/)
        {
            if ($1 == 1)
            {
                $mes = "if (\$self->case eq \"$1\") {";
            }
            else
            {
                $mes = "} elsif (\$self->case eq \"$1\") {";
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
            $mes = "if(". $1. ") {";
            $tmp2[2] = $mes;
        }
        if ($mes =~ /rand\(/)
        {
            $mes =~ s|rand\(|\$self->random(|;
            $tmp2[2] = $mes;
        }
        if ($mes =~ /select\(/)
        {
            $mes =~ s|select\(|\$self->select_choice(|;
            $tmp2[2] = $mes;
        }
        if ($mes =~ /next;/)
        {
            $mes =~ s|next;|\$self->conversation_next;|;
            $tmp2[2] = $mes;
        }
        if ($mes =~ /close;/)
        {
            $mes =~ s|close;|\$self->conversation_close;|;
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
        if ($mes =~ /switch\(/)
        {
            $mes =~ s|switch\(|\$self->switch(|;
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
        if ($mes =~ /set/)
        {
            $mes =~ s/set (.+);/\$self->set($1);/g;
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

        if ($mes =~ /($words)/)
        {
            $mes =~ s/($words)/\$self->$1()/g;
            $tmp2[2] = $mes;
        }

        $ret[$no] = sprintf("[%d]:%s", $tmp2[1], $tmp2[2]);

        push(@disp, $tmp2[2]);
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

sub no_mes
{
    my \$self = shift;
    my \$mes = shift;

    # warn \$mes, "\\n";
}

package main;

my \$self = Mock->new;
EOF
    return $class;
}

1;
