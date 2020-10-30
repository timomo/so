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
	my $utf8 = Encode::encode_utf8($mes);
	$utf8 = $mes;

	unshift(@mes_regist, $utf8);

	open(OUT,">$message_file");
	print OUT join("\n", @mes_regist);
	close(OUT);

	# ロック解除
	if ($lockkey == 3) { &file'unlock; }
	else { if(-e $lockfile) { unlink($lockfile); } }

	$movemsg = "$dnameへメッセージを送りました。";
	$mode = "log_in";
	&log_in;

	exit;
}

1;
