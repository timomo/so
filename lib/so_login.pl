use utf8;

#-----------------#
#  TOPページ表示  #
#-----------------#
sub html_top {

	&get_cookie;

	# ヘッダー表示
	&header;

	# HTMLの表示
	print <<"EOM";
<form action="$script" method="POST">
<input type="hidden" name="mode" value="log_in" />
<table border=0 width='100%'>
<tr>
	<td align="center" valign="top"><img src="$titlegif" width="227" height="81"></td>
</tr>
<tr>
<td align="center" valign="top">

<div class="blackboard question">

	<table border=0>
	<tr>
	<td align=center colspan=5 class=b2>冒険中の方はこちら</td>
	</tr>
	<tr>
	<td class=b1>入国ＩＤ</td>
	<td><input type="text" size="11" name="id" value="$c_id" /></td>
	</tr><tr>
	<td class=b1>パスワード</td>
	<td><input type="password" size="11" name="pass" value="$c_pass" /></td>
	</tr><tr>
	<td colspan="2"><input type="submit" value="旅の続き" /></td>
	</tr>
	</table>

	</div>

</td>
</tr>
</table>
<p>
<hr size=0>
</form>
<BR>
[<B><FONT COLOR="#FF9933">お知らせ</FONT></B>]<BR>
$kanri_message
<BR>
EOM
	@battle = &load_ini($battle_file);
	$sousu = @battle;

	@tmp1 = @tmp2 = ();
	foreach(@battle){
		my ($aa,$bb,$point,$total,$win) = split(/<>/);
		if($total != 0 && $win != 0){
			$rate = int($win / $total * 1000);
		}else{
			$rate = 0;
		}
 		push(@tmp1, int($point * $rate));
 		push(@tmp2, $rate);
	}
	@battle = @battle[sort {$tmp1[$b] <=> $tmp1[$a] or
			$tmp2[$b] <=> $tmp2[$a]} 0 .. $#tmp1];

	print <<"EOM";
<BR>
[<B><FONT COLOR="#FF9933">ランキング</FONT></B>]<BR>
現在の Shadow Duel 参加者中ポイントTOP<b>$rank_top</b>を表\示しています。
<p>
<table border=1>
<tr>
<th></th><th>名前</th><th>SDP</th><th>Rate</th><th>Rank</th>
</tr>
EOM

	$i=1;
	foreach(@battle){
		($bid,$bname,$bpoint,$btotal,$bwin,$brank) = split(/<>/);
		if($i > $rank_top) { last; }
		if($btotal != 0 && $bwin != 0){
			$brate = int($bwin / $btotal * 1000) / 10;
		}else{
			$brate = 0;
		}
		print "<tr>\n";
		print "<td align=center>$i</td><td>$bname</td><td align=center>$bpoint</td><td align=center>$brate%</td><td align=center>$sdrank[$brank]</td>\n";
		print "</tr>\n";
		$i++;
	}

	print "</table>\n";
	print <<"EOM";
<form action="$script" method="post">
[<B><FONT COLOR="#FF9933">入国管理室</FONT></B>]<BR>
右手の入り口より入国手続きを行います。（新キャラ登録）&nbsp
<input type="hidden" name="mode" value="chara_make" />
<input type="submit" value="入国手続き" />
</form>
</td>
</tr>
</table>
<p>
EOM

	# フッター表示
	&footer;

	exit;
}

#------------------#
#   ログイン制御   #
#------------------#
sub access_ctrl {
	$ENV{'TZ'} = "JST-9";
	$times = time();
	($sec,$min,$hour,$mday,$mon,$year,$wday,$stime) = localtime($times);

	$log_time = sprintf("%04d\%02d\%02d", $year+1900,$mon+1,$mday);
	$log_time .= ".log";

	$time = sprintf("%04d\/%02d\/%02d %02d\:%02d\:%02d", $year+1900,$mon+1,$mday,$hour,$min,$sec);

	if($in{'id'} eq ""){
		if($kid eq ""){
			$user = "guest";
		} else {
			$user = $kid;
		}
	} else {
		$user = $in{'id'};
	}

	@BAN_USER = &load_ini($ban_file);

	foreach(@BAN_USER) {
		($bid,$bmess) = split(/<>/);
		if($in{'id'} eq "$bid"){
			&error("入力されたID:$bidは$bmessのため、入国管理局に指名手配されています。");
		}
	}

	&get_host;

	@access_log = &load_ini($log_path. $log_time);

	unshift(@access_log,"$time<>$host<>$user<>$mode<>\n");

	open(OUT,">$log_path$log_time");
	print OUT @access_log;
	close(OUT);
}

1;
