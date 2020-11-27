package SO::Event::DownStair;

use Mojo::Base 'SO::Event::rAthenaScript';

has event_type => 3; # イベント種別

sub _encount
{
    my $self = shift;
    my $parse = $self->parse_rathena_script(File::Spec->catfile($FindBin::Bin, "master", "down_stairs.txt"), 1);

    $self->paragraph_check($parse);
}

sub _choice
{
    my $self = shift;
    my $parse = $self->parse_rathena_script(File::Spec->catfile($FindBin::Bin, "master", "down_stairs.txt"), 1);

    $self->paragraph_check($parse);
}

1;
