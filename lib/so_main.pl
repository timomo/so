use utf8;
#----------------#
#   メイン画面   #
#----------------#

sub file_load
{
   	our %USER = ();
	my @lines = &load_ini($chara_file);

	for my $line (@lines)
	{
		chomp $line;
		my @tmp = split(/<>/, $line);
		$USER{$tmp[0]} = \@tmp;
	}
}

sub log_in {
	$chara_flag=1;

        &file_load;

	$esex = "女";

	if ( exists $in{'id'} ) {
		unless ( exists $USER{ $in{'id'} } && $USER{ $in{'id'} }->[1] eq $in{'pass'} ) {
			&error("入力されたIDは登録されていません。又はパスワードが違います。");
		} else {
			($kid,$kpass,$kname,$ksex,$kchara,$kn_0,$kn_1,$kn_2,$kn_3,$kn_4,$kn_5,$kn_6,$khp,$kmaxhp,$kex,$klv,$kap,$kgold,$klp,$ktotal,$kkati,$khost,$kdate,$karea,$kspot,$kpst,$kitem) = @{ $USER{ $in{'id'} } };
			$esex = "男" if($ksex);
		}
	}

	my @select_menu = ();

	$pc = $USER{ $in{'id'} };

	# ファイルロック
	if ($lockkey == 1) { &lock1; }
	elsif ($lockkey == 2) { &lock2; }
	elsif ($lockkey == 3) { &file'lock; }

	# load-char-data start

	@log_in = &load_ini($chara_file);

	# load-char-data end

	$ltime = time();
	$ltime = $ltime - $kdate;
	$vtime = $b_time - $ltime;
	$mtime = $m_time - $ltime;

	$next_ex = $lv_up;

	&town_load;

	&header;

	print <<"EOM";
	<div class="blackboard question">
EOM

	if($kspot == 0 && $kpst == 1){
		print "<p>$movemsg</p><p>$kname は$town_name[$karea]郊外にいます。</p>\n";
		$spot = "$town_name[$karea]郊外";
	} elsif($kspot == 1){
		print "<p>$movemsg</p><p>$kname は$area_name[$karea]を探索中です。</p>\n";
		$spot = "$area_name[$karea]最深部まで残り $kpst";
	} elsif($kspot == 2  && $kpst > 0){
		print "<p>$movemsg</p><p>$kname は$town_name[$karea]から$town_name[$farea]に移動しています。</p>\n";
		$spot = "$town_name[$farea]まで残り $kpst";
	} elsif($kspot == 3  && $kpst > 0){
		print "<p>$movemsg</p><p>$kname は$town_name[$karea]から$town_name[$rarea]に移動しています。</p>\n";
		$spot = "$town_name[$rarea]まで残り $kpst";
	} else {
		print "<p>$movemsg</p><p>$kname は$town_name[$karea]にいます。</p>\n";
		$spot = "町の中";
	}
	$rid = $kid;
	&read_battle;

	&read_bank;
	if($krgold > 0){
		$ggold = $krgold;
		$bflag = 0;
		&money_get;
		if($kmsg ne ""){
			print "<p>シマダ国営銀行より <b>$ggold</b> G が振り込まれました。明細は以下の通りです。<br>$kmsg</p>";
		} else {
			print "<p>シマダ国営銀行より <b>$ggold</b> G が振り込まれました。</p>";
		}
		$kgold = $tgold;
		&regist_bank;
	}
	&read_buff;
	if($rrsk > 100) {
		print "<p>動くのも苦痛なほど疲れてきました・・。</p>\n";
	} elsif($rrsk > 75) {
		print "<p>かなり疲れてきました・・。</p>\n";
	} elsif($rrsk > 50) {
		print "<p>少し疲れてきました・・。</p>\n";
	}
	print <<"EOM";
</div>
<B><FONT COLOR="#FF9933">$error</FONT></B>
EOM
	$error="";

	my %per = ();

	@per{qw|hp  exp risk|} = ( ( ( $khp / $kmaxhp ) * 100 ), $kex, $rrsk );
	map{ $per{$_} = $per{$_} < 0 ? 0 : $per{$_} } keys %per;

	print <<"EOM";
<div class="blackboard question">

<table border=0>
<tr>
<td>
<table border="0" style="width: 100%">
<tr><td rowspan="3" class="b2">$kname<br />LV$klv<br />LP $klp\/$max_lp</td><td colspan="2" class="b2" align="center">HP:<div style="float: right; background-color: #000; padding: 2px; width: 160px;"><div style="background-color: red; width: $per{hp}%; text-align: right;">&nbsp;</div></div></td></tr>
<tr><td colspan="2" class="b2" align="center">EXP:<div style="float: right; background-color: #000; padding: 2px; width: 160px;"><div style="background-color: orange; width: $per{exp}%; text-align: right;">&nbsp;</div></div></td></tr>
<tr><td colspan="2" class="b2" align="center">Risk:<div style="float: right; background-color: #000; padding: 2px; width: 160px;"><div style="background-color: yellow; width: $per{risk}%; text-align: right;">&nbsp;</div></div></td></tr>
<tr><td colspan="2" class="b2" align="center">【現在地】</td></tr>
<tr>
<td class="b1" width='25%'>地名</td>
<td width='75%'>$town_name[$karea]</td>
</tr>
<tr>
<td class="b1">場所</td>
<td>$spot</td>
</tr>
<tr>
<td colspan="2" class="b2" align="center">【状態】</td>
</tr>
<tr>
<td class="b1">所持金</td>
<td>$kgold</td>
</tr>
</table>
</td>
</tr>
</table>

</div>

<form name="town" action="$script" method="post">
<input type="hidden" name="id" value="$kid" />
<input type="hidden" name="pass" value="$kpass" />
<input type="hidden" name="area" value="$karea" />
EOM

	if($kspot == 0 && $kpst == 0){

		push(@select_menu, sprintf('<p class="answer-menu">【%sの施設】</p>', $town_name[$karea]));
		push(@select_menu, sprintf('<p id="mode_town-select_%s" class="select-menu">%s</p>', "yado", "宿屋：".$t_inn));
		push(@select_menu, sprintf('<p id="mode_town-select_%s" class="select-menu">%s</p>', "item_shop", "ショップ：".$t_inn));
		push(@select_menu, sprintf('<p id="mode_town-select_%s" class="select-menu">%s</p>', "user_shop", "市場：チュパフリマ：". $town_name[$karea]));
		push(@select_menu, sprintf('<p id="mode_town-select_%s" class="select-menu">%s</p>', "bank", "銀行：シマダ国営銀行（". $town_name[$karea]. "店）"));

		print <<"EOM";
<!--
【$town_name[$karea]の施設】<br>
-->
<select id="town-select" name="mode" onchange="javascript:selectTown(this);">
<option value="yado">宿屋：$t_inn</option>
<option value="item_shop">ショップ：$t_shop</option>
<option value="user_shop">市場：チュパフリマ $town_name[$karea]</option>
<option value="bank">銀行：シマダ国営銀行（$town_name[$karea]店）</option>
</select>
<input id="town-select-submit" type="submit" value="入店" /><br>
EOM
	} else {
		print <<"EOM";
		<!--
【キャンプ】<br>
-->
<input type="hidden" name="spot" value="2" />
EOM

		if(1) {
			push(@select_menu, qw|<p class="answer-menu">【キャンプ】</p>|);
			push(@select_menu, qw|<p id="mode_camp-select_rest" class="blink-before select-menu">休憩する</p>|);
			push(@select_menu, qw|<p id="mode_camp-select_monster" class="select-menu">キャンピング</p>|);
			print <<"EOM";
<select id="camp-select" name="mode" onchange="javascript:selectTown(this);">
<option value="rest">休憩する</option>
<option value="monster">キャンピング</option>
</select>
<input id="camp-select-submit" type="submit" value="休む" />
EOM
		}
	}
	print <<"EOM";
</form>
<div id="town_text" class="text_detail">&nbsp;</div>
<form name="move" action="$script" method="post">
<input type="hidden" name="id" value="$kid" />
<input type="hidden" name="pass" value="$kpass" />
<input type="hidden" name="area" value="$karea" />
<input type="hidden" name="mode" value="monster" />
EOM
	if(1) {
		my ( $label, $optionHTML ) = ( "", "" );
		my @options;

		if( $kspot == 0 && $kpst == 0 ) {
			$label = "【$town_name[$karea]周辺】";
			push( @options, [ 0, sprintf( "%s郊外を探索する", $town_name[$karea] ) ] );
		} elsif( $kspot == 0 && $kpst == 1 ){
			$label = "【行動】";
			push( @options, [ 0, "探索する" ] );
		} else {
			$label = "【行動】";
			push( @options, [ 0, "先へ進む" ] );
		}

		push(@select_menu, qq|<p class="answer-menu">|. $label. qq|</p>|);

		if( $kspot == 0 && $kpst == 0 ){
			push( @options, [ 1, sprintf( "%sへ向かう", $area_name[$karea] ) ] );
			push( @options, [ 3, sprintf( "%s方面へ(距離 %s)", $town_name[$rarea], $town_move[$karea][3] ) ] );
			push( @options, [ 2, sprintf( "%s方面へ(距離 %s)", $town_name[$farea], $town_move[$karea][2] ) ] );
		} elsif( $kspot == 0 && $kpst == 1 ){
			push( @options, [ 1, sprintf( "%sへ帰還する", $town_name[$karea] ) ] );
		} else {
			push( @options, [ 1, "引き返す" ] );
		}

		for (@options) {
			push(@select_menu, sprintf('<p id="mode_monster-select_%s" class="select-menu">%s</p>', @$_));
			$optionHTML .= sprintf( "<option value=\"%s\">%s</option>\n", @$_);
		}

		print <<"EOM";
<!--
$label<br>
-->
&nbsp;<select id="monster-select" name="spot" onchange="javascript:selectMove(this);">
$optionHTML
</select>
<input id="monster-select-submit" type="submit" value="行動" />
<div id="move_text" class="text_detail">&nbsp;</div>
EOM
	}else{
			# print "$mtime秒後に行動できます。<br>\n";
	}
	print <<"EOM";
</form>
EOM

	print <<"EOM";
<div class="clearfix">
	<div class="blackboard answer float-l">
EOM
	print join("\n", @select_menu);

	if (scalar @select_menu == 0)
	{
		print "&nbsp;";
	}

	print <<"EOM";
	</div>
</div>

<div class="blackboard question" id="select-description">
&nbsp;
</div>
EOM

	if($kspot == 0 && $kpst == 0){
		if(1) {
			print <<"EOM";
<form action="$script" method="post">
【Shadow Duel 管理局】<br>
<input type="hidden" name="mode" value="battle" />
<input type="hidden" name="id" value="$kid" />
<input type="hidden" name="pass" value="$kpass" />
&nbsp;<select name="rid">
<option value="">挑戦相手を選択(強さ)</option>
EOM
			$rid = $kid;
			&read_battle;
			$rank = $krank;

			$todd=0;
			foreach(@log_in) {
				($tid,$tpass,$tname,$tsex,$tchara,$tn_0,$tn_1,$tn_2,$tn_3,$tn_4,$tn_5,$tn_6,$thp,$tmaxhp,$tex,$tlv,$tap,$tgold,$tlp,$ttotal,$tkati,$thost,$tdate,$tarea,$tspot,$tpst,$titem) = split(/<>/);
				if($kid eq $tid) { next; }
				$rid = $tid;
				&read_battle;
				if($rank >= $krank){
					print "<option value=$tid>$tname Lv$tlv（$sdrank[$krank]）</option>\n";
				}
			}

			print <<"EOM";
</select>
<input type="submit" value="決闘" />
<div class="text_detail">自分の分身と他人の分身を戦わせることができます。</div>
</form>
EOM
		}
	}

	print <<"EOM";
<form action="$script" method="post">
【メッセージ送信】<br>
<input type="hidden" name="id" value="$kid" />
<input type="hidden" name="name" value="$kname" />
<input type="hidden" name="pass" value="$kpass" />
<input type="hidden" name="mode" value="message" />
&nbsp;
<select name="mesid">
<option value="">送る相手を選択</option>
EOM

	for ( @log_in ) {
		my ( $did, $dpass, $dname, $dmy ) = split /<>/, $_, 4;
		next if($kid eq $did);
		print "<option value=\"$did\">$dname</option>\n";
	}
	print "<option value=\"Ａ\">全員に送信（迷惑注意）</option>\n";
	print <<"EOM";
</select>
<input type="submit" value="送信" /><br>
<input type="text" name="mes" size="25" />
<div class="text_detail">他のキャラクターへメッセージを送ることができます。</div>
</form>
<!--
</td>
</tr>
</table>
-->
【届いているメッセージ】表示数<b>$max_gyo</b>件まで<br>
EOM

	@MESSAGE_LOG = &load_ini($message_file);

	$hit=0;$i=1;
	foreach(@MESSAGE_LOG){
		($pid,$hid,$hname,$hmessage,$hhname,$htime) = split(/<>/);
		if($kid eq $pid){
			if($max_gyo < $i) { last; }
			print "<hr size=0><small><b>$hname</b>　＞ 「<b>$hmessage</b>」($htime)</small><br>\n";
			$hit=1;$i++;
		}elsif($kid eq $hid){
			print "<hr size=0><small>$kname から $hhname へ　＞ 「$hmessage」($htime)</small><br>\n";
		}elsif("Ａ" eq "$pid"){
			if($max_gyo < $i) { last; }
			print "<hr size=0><small><b>$hname (全員へ)</b>　＞ 「<b>$hmessage</b>」($htime)</small><br>\n";
			$hit=1;$i++;
		}
	}
	if(!$hit){ print "<hr size=0>$kname 宛てのメッセージはありません。<p>\n"; }
	print "<hr size=0><p>";

print <<EOF;
<form id="check_form" action="$script" method="post">
<select id="status-select" name="mode" onchange="javascript:selectTown(this);">
<option value="item_check">アイテム一覧</option>
<option value="status_check">ステータス詳細</option>
</select>
<input type="hidden" name="id" value="$kid" />
<input type="hidden" name="pass" value="$kpass" />
<input id="status-select-submit" type="submit" value="行動" />
</form>
<script>
const spot = "$spot";
</script>
EOF

	&footer;

	exit;
}

1;
