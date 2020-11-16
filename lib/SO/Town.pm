package SO::Town;

use Mojo::Base -base;
use Data::Dumper;
use Mojo::Collection;
use Storable;
use Mojo::File;
use File::Spec;
use FindBin;
use YAML::XS;
use Encode;
use DateTime::HiRes;
use SO::System;

has data => sub {{}};
has watch_hook => sub {{}};
has context => undef;
has k1id => undef;
has k2id => undef;
has id => undef;
has log_level => undef;
has system => undef;

sub close
{
    my $self = shift;
    $self->data({});
    $self->watch_hook({});
    $self->context(undef);
    $self->system(undef);
}

sub open
{
    my $self = shift;
    # my $k = $self->context->character($self->id);
    # $self->data($k);
    $self->log_level($self->context->log->level);
    # $self->system(So::System->new(context => $self->context));
}

sub load
{
    my $self = shift;
    my $k = shift;
    my $log_town = $self->system->load_raw_ini($self->context->config->{town_info});
    my $ret = {};
    $ret->{move} = $self->context->config->{タウン間距離};
    my $town_name = $self->context->config->{街};
    my $area_name = $self->context->config->{フィールド};

    foreach(@$log_town)
    {
        my ($t_no,$t_info,$t_shop,$t_inn,$t_cost,$t_prize,$t_drop) = @$_;
        if($k->{エリア} eq "$t_no")
        {
            my $tmp = {};
            $tmp->{id} = $t_no * 1;
            $tmp->{info} = $t_info;
            $tmp->{shop} = $t_shop;
            $tmp->{inn} = $t_inn;
            $tmp->{cost} = $t_cost * 1;
            $tmp->{price} = $t_prize * 1;
            $tmp->{drop} = $t_drop;
            $tmp->{距離} = $ret->{move}->[$k->{エリア}]->[3];

            if ($k->{スポット} == 1)
            {
                $tmp->{距離} -= $k->{距離};
            }
            else
            {
                $tmp->{距離} += $k->{距離};
            }

            $tmp->{地名} = $town_name->[$tmp->{id}];
            $tmp->{場所} = $area_name->[$tmp->{id}];
            $ret->{current} = $tmp;
            last;
        }
    }

    my $farea = 0;

    if($k->{エリア} > 0)
    {
        $farea = $k->{エリア} - 1;
    }
    else
    {
        $farea = @$town_name - 1;
    }

    foreach(@$log_town)
    {
        my ($f_no,$f_info,$f_shop,$f_inn) = @$_;
        if($farea eq "$f_no")
        {
            my $tmp = {};
            $tmp->{id} = $f_no * 1;
            $tmp->{info} = $f_info;
            $tmp->{shop} = $f_shop;
            $tmp->{inn} = $f_inn;
            $tmp->{距離} = $ret->{move}->[$k->{エリア}]->[2];

            if ($k->{スポット} == 2)
            {
                $tmp->{距離} -= $k->{距離};
            }
            else
            {
                $tmp->{距離} += $k->{距離};
            }
            $tmp->{地名} = $town_name->[$tmp->{id}];
            $tmp->{場所} = $area_name->[$tmp->{id}];
            $ret->{next} = $tmp;
            last;
        }
    }

    my $rarea = @$town_name - 1;

    if($k->{エリア} < (@$town_name - 1))
    {
        $rarea = $k->{エリア} + 1;
    }
    else
    {
        $rarea = 0;
    }

    foreach(@$log_town)
    {
        my ($r_no,$r_info,$r_shop,$r_inn) = @$_;
        if($rarea eq "$r_no")
        {
            my $tmp = {};
            $tmp->{id} = $r_no * 1;
            $tmp->{info} = $r_info;
            $tmp->{shop} = $r_shop;
            $tmp->{inn} = $r_inn;
            $tmp->{距離} = $ret->{move}->[$k->{エリア}]->[1];

            if ($k->{スポット} == 3)
            {
                $tmp->{距離} -= $k->{距離};
            }
            else
            {
                $tmp->{距離} += $k->{距離};
            }
            $tmp->{地名} = $town_name->[$tmp->{id}];
            $tmp->{場所} = $area_name->[$tmp->{id}];
            $ret->{previous} = $tmp;
            last;
        }
    }

    # warn sprintf("%s = %s, %s", $_, $ret->{$_}->{地名}, $ret->{$_}->{距離}) for (qw|previous next current|);

    delete $ret->{move};

    return $ret;
}


sub watch
{
    my ($self, $key, $func) = @_;
    $self->watch_hook->{$key} = $func;
}

sub in_array
{
    my ($self, $val, $array_ref) = @_;

    foreach my $elem (@$array_ref) {
        if ($val =~ m/^[0-9]+$/) {
            if ($val == $elem) {return 1;}
        }
        else {
            if ($val eq $elem) {return 1;}
        }
    }

    return 0;
}

sub param
{
    my ($self, $key, $val) = @_;
    if (defined $val) {
        my $oldVal = $self->data->{$key};
        my $newVal = $val;
        $self->data->{$key} = $newVal;

        if (exists $self->watch_hook->{$key} && ref $self->watch_hook->{$key} eq "CODE") {
            $self->watch_hook->{$key}->($self, $newVal, $oldVal);
        }
    }
    return $self->data->{$key};
}

sub unset
{
    my ($self, $key) = @_;
    delete $self->data->{$key};
}

sub dump
{
    my ($self, $data) = @_;
    my $str = YAML::XS::Dump($data);
    utf8::decode($str);
    return $str;
}

sub DESTROY
{
    my ($self) = @_;
    my $dt = DateTime::HiRes->now(time_zone => "Asia/Tokyo");
    my $mes = sprintf("[%s] [%s] [%s] %s [%s] DESTROY", $dt->strftime('%Y-%m-%d %H:%M:%S.%5N'), $$, "debug", $self, $self->id || "-");
    my $utf8 = Encode::encode_utf8($mes);
    warn $utf8. "\n" if ($self->log_level eq "debug");
}

1;
