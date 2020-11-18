package SO::Event::SimpleMessage;

use SO::Event::Base -base;
use YAML::XS;

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

    if (! defined $self->event_id)
    {
        $self->insert($self->event);
    }
}

sub _choice
{
    my $self = shift;

    warn "_choice";
}

sub _result1
{
    my $self = shift;
    my $args = shift;

    warn "_result1";
}

1;
