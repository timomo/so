#!/usr/bin/perl
use strict;
use warnings FATAL => 'all';
use Mojo::File;
use FindBin;
use File::Spec;
use YAML::XS;

{
    my $parse = &parse_rathena_script(File::Spec->catfile($FindBin::Bin, "master", "script.txt"));
    my $case = "";
    my $para = 0;

    while(1)
    {
        if ($case eq "")
        {
            for my $line (@{$parse->{$case}->{$para}})
            {
                my $mes = $line || "";
                print $mes. "\n";
                if ($mes =~ /next;/)
                {
                    print "please enter key.";
                    my $tmp = <STDIN>;
                    $para++;
                }
                elsif ($mes =~ /close;/)
                {
                    exit;
                }
            }
        }
        elsif (exists $parse->{$case})
        {
            for my $line (@{$parse->{$case}->{$para}})
            {
                my $mes = $line || "";
                print $mes. "\n";
                if ($mes =~ /next;/)
                {
                    print "please enter key.";
                    my $tmp = <STDIN>;
                    $para++;
                }
                elsif ($mes =~ /close;/)
                {
                    exit;
                }
            }
        }

        print "case?: ";
        my $in = <STDIN>;
        chomp($in);

        if ($case ne $in && $in =~ /^\d+$/)
        {
            $para = 0;
            $case = "case $in";
        }
    }
}

sub parse_rathena_script
{
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
