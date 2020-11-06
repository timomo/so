package SO::PVP;

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

has data => sub {{}};
has watch_hook => sub {{}};
has context => undef;
has k1id => undef;
has k2id => undef;
has id => undef;
has log_level => undef;

sub close
{
    my $self = shift;
    $self->data({});
    $self->watch_hook({});
    $self->context(undef);
}

sub open
{
    my $self = shift;
    # my $k = $self->context->character($self->id);
    # $self->data($k);
    $self->log_level($self->context->log->level);
}

sub is_pvp
{
    my $self = shift;
    my $id = shift;

    my $hit = $self->context->queue->first(sub
    {
        my $command = shift;
        my $param = $command->{param};

        if ($param->{mode} ne "pvp")
        {
            return 0;
        }

        if ($param->{id} ne $id && $param->{k1id} ne $id && $param->{k2id} ne $id)
        {
            return 0;
        }

        return 1;
    });

    if (defined $hit)
    {
        return 1;
    }

    my $ids = $self->get_pvp_ids($id);

    if (! defined $ids)
    {
        return 0;
    }

    if ($ids->[0] eq $id || $ids->[1] eq $id)
    {
        return 1;
    }

    return 0;
}

sub get_pvp_ids
{
    my $self = shift;
    my $id = shift;

    my $hit = $self->context->queue->first(sub
    {
        my $command = shift;
        my $param = $command->{param};

        if ($param->{mode} ne "pvp")
        {
            return 0;
        }

        if ($param->{id} ne $id && $param->{k1id} ne $id && $param->{k2id} ne $id)
        {
            return 0;
        }

        return 1;
    });

    if (defined $hit)
    {
        return [$hit->{param}->{k1id}, $hit->{param}->{k2id}];
    }

    my $dir = Mojo::File->new(File::Spec->catdir($FindBin::Bin, "save", "battle"));
    my $collection = $dir->list_tree;

    for my $file (@$collection)
    {
        if ($file->basename !~ /\.pvp\.yaml$/)
        {
            next;
        }
        if ($file->basename =~ /$id/)
        {
            my $name = $file->basename;
            $name =~ s/\.pvp\.yaml$//;
            my @tmp = split("_____", $name);

            return \@tmp;
        }
    }

    return undef;
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
