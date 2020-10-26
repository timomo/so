#----------------------#
#  イベントメッセージ  #
#----------------------#
sub event {

	&get_host;

	$date = time();

	# ファイルロック
	if ($lockkey == 1) { &lock1; }
	elsif ($lockkey == 2) { &lock2; }
	elsif ($lockkey == 3) { &file'lock; }

	open(IN,"$chara_file");
	@event = <IN>;
	close(IN);

	$hit=0;@event_new=();@sn=();
	foreach(@event){
		($sid,$spass,$sname,$ssex,$schara,$sn[0],$sn[1],$sn[2],$sn[3],$sn[4],$sn[5],$sn[6],$shp,$smaxhp,$sex,$slv,$sap,$sgold,$slp,$stotal,$skati,$shost,$sdate,$sarea,$sspot,$spst,$sitem) = split(/<>/);
		if($in{'id'} eq "$sid") {
			unshift(@event_new,"$sid<>$spass<>$sname<>$ssex<>$schara<>$sn[0]<>$sn[1]<>$sn[2]<>$sn[3]<>$sn[4]<>$sn[5]<>$sn[6]<>$khp<>$smaxhp<>$sex<>$slv<>$sap<>$sgold<>$slp<>$stotal<>$skati<>$khost<>$kdate<>$karea<>$kspot<>$kpst<>$sitem<>\n");
		}else{
			push(@event_new,"$_");
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
