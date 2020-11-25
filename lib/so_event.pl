use utf8;

#----------------------#
#  イベントメッセージ  #
#----------------------#

sub is_continue_event
{
	my $encounter = SO::Event->new(context => $controller, "system" => $system, id => $kid);
	my $event = $encounter->reserved;

	if (defined $event)
	{
		return 1;
	}
	return 0;
}

sub event_reserved
{
	warn "---------------->event_reserved";

	my $encounter = SO::Event->new(context => $controller, "system" => $system, id => $kid);
	my $event = $encounter->reserved;

	if (defined $event)
	{
		$event->encount;
		$event->select(\%in);
		$event->result;
		my $next = $event->next;

		if (defined $next)
		{
			$event = $next;
			my $utf8 = $event->render_to_string;
			$event->close;

			if (defined $utf8)
			{
				print $utf8;
				exit;
			}
		}
		if (defined $event->message)
		{
			my $utf8 = $event->render_to_string;
			$event->close;

			if (defined $utf8)
			{
				print $utf8;
				exit;
			}
		}
	}
}

sub event_encounter
{
	warn "---------------->event_encounter";
	my $encounter = SO::Event->new(context => $controller, "system" => $system, id => $kid);
	my $event = $encounter->encounter;

	if (! defined $event)
	{
		$encounter = SO::Event->new(context => $controller, "system" => $system, id => $kid, random => 1);
		$event = $encounter->encounter;
	}

	if (defined $event)
	{
		$event->encount;
		my $utf8 = $event->render_to_string;
		$event->close;

		if (defined $utf8)
		{
			print $utf8;
			exit;
		}
	}
}

sub event_choice
{
	warn "---------------->event_choice";
	my $event_id = $in{イベントid};
	my $select = $in{選択};

	for my $num (0 .. 10)
	{
		my $encounter = SO::Event->new(context => $controller, "system" => $system, id => $kid, event_id => $event_id);
		my $event = $encounter->load;

		if (! defined $event)
		{
			last;
		}
		if ($event_id == $event->id && defined $select)
		{
			$event->select(\%in);
			$select = undef;
			$event->result;
		}
		if ($event->continue_id != 0)
		{
			$event->event_end_time(time);
			$event->save;
			$event_id = $event->continue_id;
			next;
		}
		if (! defined $event->event_end_time)
		{
			my $utf8 = $event->render_to_string;

			if (defined $utf8)
			{
				print $utf8;
				$event->event_end_time(time);
				$event->save;
				exit;
			}
			$event->event_end_time(time);
			$event->save;
		}
		$event_id = $event->continue_id;
	}
}

sub event
{
	&get_host;
	$date = time();

	my $new = {};
	@$new{@{$config->{keys}}} = (
		$kid, $kpass, $kname, $ksex, $kchara,
		$kn_0, $kn_1, $kn_2, $kn_3, $kn_4, $kn_5, $kn_6,
		$khp, $kmaxhp, $kex, $klv, $kap, $kgold, $klp,
		$ktotal, $kkati, $host, $date,
		$karea, $kspot, $kpst,
		$kitem
	);

	$system->modify_chara_data($new);
	$system->save_chara($new);
}

sub _event {

	&get_host;

	$date = time();

	# ファイルロック
	if ($lockkey == 1) { &lock1; }
	elsif ($lockkey == 2) { &lock2; }
	elsif ($lockkey == 3) { &file'lock; }

	@event = &load_ini($chara_file);

	$hit=0;@event_new=();@sn=();
	foreach(@event){
		($sid,$spass,$sname,$ssex,$schara,$sn[0],$sn[1],$sn[2],$sn[3],$sn[4],$sn[5],$sn[6],$shp,$smaxhp,$sex,$slv,$sap,$sgold,$slp,$stotal,$skati,$shost,$sdate,$sarea,$sspot,$spst,$sitem) = split(/<>/);
		if($in{'id'} eq "$sid") {
			my $mes = "$sid<>$spass<>$sname<>$ssex<>$schara<>$sn[0]<>$sn[1]<>$sn[2]<>$sn[3]<>$sn[4]<>$sn[5]<>$sn[6]<>$khp<>$smaxhp<>$sex<>$slv<>$sap<>$sgold<>$slp<>$stotal<>$skati<>$khost<>$kdate<>$karea<>$kspot<>$kpst<>$sitem<>\n";
			my $utf8 = Encode::encode_utf8($mes);

			unshift(@event_new,$utf8);
		}else{
			push(@event_new,"$_\n");
		}
	}

	open(OUT,">$chara_file");
	print OUT @event_new;
	close(OUT);

	# ロック解除
	if ($lockkey == 3) { &file'unlock; }
	else { if(-e $lockfile) { unlink($lockfile); } }
}

1;
