use utf8;

#-----------------#
#  TOPページ表示  #
#-----------------#
sub html_top
{
	my @battle = &load_ini($battle_file);
	my $sousu = @battle;

	my @tmp1 = ();
	my @tmp2 = ();

	foreach(@battle)
	{
		my ($aa,$bb,$point,$total,$win) = split(/<>/);
		my $rate;
		if($total != 0 && $win != 0)
		{
			$rate = int($win / $total * 1000);
		}
		else
		{
			$rate = 0;
		}
		push(@tmp1, int($point * $rate));
		push(@tmp2, $rate);
	}

	@battle = @battle[sort {$tmp1[$b] <=> $tmp1[$a] or
		$tmp2[$b] <=> $tmp2[$a]} 0 .. $#tmp1];

	&get_cookie;

	# ヘッダー表示
	&header;

	my $i = 1;
	my @tr;

	foreach(@battle)
	{
		my ($bid, $bname, $bpoint, $btotal, $bwin, $brank) = split(/<>/);
		my $brate;

		if($i > $rank_top)
		{
			last;
		}
		if($btotal != 0 && $bwin != 0)
		{
			$brate = int($bwin / $btotal * 1000) / 10;
		}
		else
		{
			$brate = 0;
		}

		my $mes = "";
		$mes .= "<tr>\n";
		$mes .= "<td align=center>$i</td><td>$bname</td><td align=center>$bpoint</td><td align=center>$brate%</td><td align=center>$sdrank[$brank]</td>\n";
		$mes .= "</tr>\n";

		push(@tr, $mes);

		$i++;
	}

	my $html = $controller->render_to_string(
		template      => "chara_make",
		script        => $script,
		titlegif      => $titlegif,
		c_id          => $c_id,
		c_pass        => $c_pass,
		kanri_message => $kanri_message,
		rank_top      => $rank_top,
		tr            => \@tr,

	);

	print Encode::encode_utf8($html);

	exit;
}

#------------------#
#   ログイン制御   #
#------------------#
sub access_ctrl
{
	$ENV{'TZ'} = "JST-9";
	my $times = time();
	my ($sec, $min, $hour, $mday, $mon, $year, $wday, $stime) = localtime($times);

	my $log_time = sprintf("%04d\%02d\%02d", $year+1900,$mon+1,$mday);
	$log_time .= ".log";

	my $time = sprintf("%04d\/%02d\/%02d %02d\:%02d\:%02d", $year+1900,$mon+1,$mday,$hour,$min,$sec);

	if($in{'id'} eq ""){
		if($kid eq ""){
			$user = "guest";
		} else {
			$user = $kid;
		}
	} else {
		$user = $in{'id'};
	}

	my @BAN_USER = &load_ini($ban_file);

	foreach(@BAN_USER) {
		my ($bid,$bmess) = split(/<>/);
		if($in{'id'} eq "$bid")
		{
			&error("入力されたID:$bid は$bmess のため、入国管理局に指名手配されています。");
		}
	}

	&get_host;

	my @access_log = &load_ini($log_path. $log_time);

	unshift(@access_log,"$time<>$host<>$user<>$mode<>\n");

	open(OUT,">", $log_path. $log_time);
	print OUT @access_log;
	close(OUT);
}

1;
