package SO::Event::AreaRandomMessage;

# push @ISA, 'SO::Event::Base';
use Mojo::Base 'SO::Event::SimpleMessage';
use YAML::XS;

has messages => sub {
    [
        "./master/town/msg_matsushima.mst",
        "./master/town/msg_yukinoura.mst",
        "./master/town/msg_taira.mst",
        "./master/town/msg_seto.mst",
        "./master/town/msg_ikeshima.mst",
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
    my $path = File::Spec->catfile($FindBin::Bin, $self->messages->[$self->data->{エリア}]);
    my $system = $self->app->entity("system");
    my $rows = $system->load_raw_ini($path);
    my $rand2 = $system->range_rand(0, $#$rows);
    my $mes = $rows->[$rand2]->[2];
    $self->message($mes);
    $self->event_end_time(time);
    $self->save;
}

sub _choice
{
    my $self = shift;
}

sub _result1
{
    my $self = shift;
    my $args = shift;
}

1;
