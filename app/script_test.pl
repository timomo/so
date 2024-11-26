#!/usr/bin/perl
use strict;
# use warnings FATAL => 'all';
use Mojo::File;
use FindBin;
use File::Spec;
use YAML::XS;
use Data::Dumper;
no warnings 'recursion';
use 5.010001;

{
    my $parse = &parse_rathena_script("", File::Spec->catfile($FindBin::Bin, "master", "alchemist_skills.txt"));
    my $ret;
    my $para;

    while(1)
    {
        print "case?: ";
        my $case = <STDIN>;
        chomp($case);
        my $num = 0;
        my @hits2;

        for my $elm (@$parse)
        {
            my @tmp2 = split(/\[(\d+)\]:/, $elm);

            push(@hits2, [$num, int($tmp2[1])]);

            $num++;
        }

        my @hits3;
        for my $elm (@hits2)
        {
            if ($case == $elm->[1] || $case + 1 == $elm->[1])
            {
                push(@hits3, $parse->[$elm->[0]]);
            }
        }

        my $parse2 = &_parse_rathena_script("", join("\n", @hits3));

        print Dumper $parse2;
    }
}

sub parse_rathena_script
{
    my $self = shift;
    my $path = shift;
    my $file = Mojo::File->new($path);
    my $content = $file->slurp;
    $content =~ s/\r\n|\r|\n/\n/;
    my @tmp;

    if ($content =~ m/(.+?)\{(.+?)\n\}/s)
    {
        my $titie = $1;
        my $body = $2;
        my $ref = &parse_script($body);

        return $ref;
    }
}

sub get_paragraph
{
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
    my $body = shift;
    my @tmp = split("{", $body);
    my @ret;

    for my $no (0 .. $#tmp)
    {
        my $line = $tmp[$no];
        my $paragraph = &get_paragraph($line);

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
                    my $paragraph2 = &get_paragraph($line2);

                    $line2 =~ s/\r\n|\r|\n/\n/g;
                    $line2 =~ s/^\s+|\s+$//g;
                    $line2 =~ s/^\t+|\t+$//g;

                    if ($line2 =~ /^$/)
                    {
                        next;
                    }

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

    return \@ret;
}

sub _parse_rathena_script
{
    my $self = shift;
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