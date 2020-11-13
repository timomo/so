use utf8;
#--------------#
#  メッセージ  #
#--------------#
sub message {
	if($in{'mes'} eq "") { $error = "メッセージが記入されていません。"; $mode = "log_in"; &log_in;}
	if($in{'mesid'} eq ""){ $error = "相手が指定されていません。"; $mode = "log_in"; &log_in;}

	&get_time;

	# ファイルロック
	if ($lockkey == 1) { &lock1; }
	elsif ($lockkey == 2) { &lock2; }
	elsif ($lockkey == 3) { &file'lock; }

	@mes_regist = &load_ini($message_file);
	@MESSAGE = &load_ini($chara_file);

	if($in{'mesid'} eq "Ａ"){
		$dname = "全員";
	} else{
		foreach(@MESSAGE) {
			($did,$dpass,$dname) = split(/<>/);
			if($in{'mesid'} eq "$did") { last; }
		}
	}
	$mes_max = @mes_regist;

	if($mes_max > $max) { pop(@mes_regist); }

	my $mes = "$in{'mesid'}<>$in{'id'}<>$in{'name'}<>$in{'mes'}<>$dname<>$gettime<>";

	unshift(@mes_regist, $mes);

	$mes_regist[$_] = Encode::encode_utf8($mes_regist[$_]) for 0 .. $#mes_regist;

	my $file = Mojo::File->new($message_file);
	$file->touch;
	$file->spurt(join("\n", @mes_regist));

	# ロック解除
	if ($lockkey == 3) { &file'unlock; }
	else { if(-e $lockfile) { unlink($lockfile); } }

	$movemsg = "$dname へメッセージを送りました。";
	$mode = "log_in";
	&log_in;

	exit;
}

sub message_check
{
	my @log_in = &load_ini($chara_file);
	my @mesid;

	for ( @log_in ) {
		my ( $did, $dpass, $dname, $dmy ) = split /<>/, $_, 4;
		if($kid eq $did)
		{
			next;
		}
		push(@mesid, "<option value=\"$did\">$dname</option>");
	}

	push(@mesid, "<option value=\"Ａ\">全員に送信（迷惑注意）</option>");

	my $html = $controller->render_to_string(
		template => "message_check",
		script   => "/window/message",
		kid      => $kid,
		kname    => $kname,
		kpass    => "******",
		mesid    => \@mesid,
		max_gyo  => $max_gyo,
	);

	return Encode::encode_utf8($html);
}

1;
