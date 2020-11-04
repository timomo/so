use utf8;

#----------------#
#   メイン画面   #
#----------------#
sub log_in
{
	$chara_flag = 1;

	$esex = "女";
	$esex = "男" if($ksex);

	my @select_menu = ();

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

	my @message = ();

	if($kspot == 0 && $kpst == 1)
	{
		push(@message, "<p>$movemsg</p><p>$kname は$town_name[$karea]郊外にいます。</p>");
		$spot = "$town_name[$karea]郊外";
	}
	elsif($kspot == 1)
	{
		push(@message, "<p>$movemsg</p><p>$kname は$area_name[$karea]を探索中です。</p>");
		$spot = "$area_name[$karea]最深部まで残り $kpst";
	}
	elsif($kspot == 2  && $kpst > 0)
	{
		push(@message, "<p>$movemsg</p><p>$kname は$town_name[$karea]から$town_name[$farea]に移動しています。</p>");
		$spot = "$town_name[$farea]まで残り $kpst";
	}
	elsif($kspot == 3  && $kpst > 0)
	{
		push(@message, "<p>$movemsg</p><p>$kname は$town_name[$karea]から$town_name[$rarea]に移動しています。</p>");
		$spot = "$town_name[$rarea]まで残り $kpst";
	}
	else
	{
		push(@message, "<p>$movemsg</p><p>$kname は$town_name[$karea]にいます。</p>");
		$spot = "町の中";
	}

	$rid = $kid;
	&read_battle;
	&read_bank;

	if($krgold > 0){
		$ggold = $krgold;
		$bflag = 0;
		&money_get;

		if($kmsg ne "")
		{
			push(@message, "<p>シマダ国営銀行より <b>$ggold</b> G が振り込まれました。明細は以下の通りです。<br>$kmsg</p>");
		}
		else
		{
			push(@message, "<p>シマダ国営銀行より <b>$ggold</b> G が振り込まれました。</p>");
		}

		$kgold = $tgold;
		&regist_bank;
	}

	&read_buff;

	if($rrsk > 100)
	{
		push(@message, "<p>動くのも苦痛なほど疲れてきました・・。</p>");
	}
	elsif($rrsk > 75)
	{
		push(@message, "<p>かなり疲れてきました・・。</p>");
	}
	elsif($rrsk > 50)
	{
		push(@message, "<p>少し疲れてきました・・。</p>");
	}

	my $description = $mt->render_file('templates/window/description.html.ep', {
		message => \@message,
	});

	my $status = $mt->render_file('templates/window/status.html.ep', {
		kname => $kname,
		klv => $klv,
		klp => $klp,
		max_lp => $max_lp,
		khp => $khp,
		kmaxhp => $kmaxhp,
		kex => $kex,
		rrsk => $rrsk,
		area => $town_name[$karea],
		spot => $spot,
		kgold => $kgold,
	});

	my $error_string = Encode::decode_utf8($error) if (! utf8::is_utf8($error));

	print <<"EOM";
$description
<b><font color="#FF9933">$error_string</font></b>
$status
EOM

	$error = "";

	if($kspot == 0 && $kpst == 0)
	{
		my $facilities = $mt->render_file('templates/window/facilities.html.ep', {
			script  => $script,
			kid     => $kid,
			kpass   => $kpass,
			karea   => $karea,
			area    => $town_name[$karea],
			t_inn   => $t_inn,
			t_shop => $t_shop,
		});

		push(@select_menu, sprintf('<p class="answer-menu">【%sの施設】</p>', $town_name[$karea]));
		push(@select_menu, sprintf('<p id="mode_town-select_%s" class="select-menu">%s</p>', "yado", "宿屋：".$t_inn));
		push(@select_menu, sprintf('<p id="mode_town-select_%s" class="select-menu">%s</p>', "item_shop", "ショップ：".$t_inn));
		push(@select_menu, sprintf('<p id="mode_town-select_%s" class="select-menu">%s</p>', "user_shop", "市場：チュパフリマ：". $town_name[$karea]));
		push(@select_menu, sprintf('<p id="mode_town-select_%s" class="select-menu">%s</p>', "bank", "銀行：シマダ国営銀行（". $town_name[$karea]. "店）"));

		print $facilities;
	}
	else
	{
		my $camp = $mt->render_file('templates/window/camp.html.ep', {
			script  => $script,
			kid     => $kid,
			kpass   => $kpass,
			karea   => $karea,
		});

		push(@select_menu, qw|<p class="answer-menu">【キャンプ】</p>|);
		push(@select_menu, qw|<p id="mode_camp-select_rest" class="blink-before select-menu">休憩する</p>|);
		push(@select_menu, qw|<p id="mode_camp-select_monster" class="select-menu">キャンピング</p>|);

		print $camp;
	}
	print <<"EOM";
<div id="town_text" class="text_detail">&nbsp;</div>
EOM

	my ( $label, $optionHTML ) = ( "", "" );
	my @options;

	if( $kspot == 0 && $kpst == 0 )
	{
		$label = "【$town_name[$karea]周辺】";
		push( @options, [ 0, sprintf( "%s郊外を探索する", $town_name[$karea] ) ] );
	}
	elsif( $kspot == 0 && $kpst == 1 )
	{
		$label = "【行動】";
		push( @options, [ 0, "探索する" ] );
	}
	else
	{
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

	my $move = $mt->render_file('templates/window/move.html.ep', {
		script      => $script,
		kid         => $kid,
		kpass       => $kpass,
		karea       => $karea,
		optionHTML => $optionHTML,
	});

	my $select_menu = $mt->render_file('templates/window/select_menu.html.ep', {
		select_menu => \@select_menu,
	});

	print $move;
	print $select_menu;

	if($kspot == 0 && $kpst == 0)
	{
		$rid = $kid;
		&read_battle;
		$rank = $krank;
		$todd=0;

		my @rid;

		foreach(@log_in)
		{
			my ($tid, $tpass, $tname, $tsex, $tchara, $tn_0, $tn_1, $tn_2, $tn_3, $tn_4, $tn_5, $tn_6, $thp, $tmaxhp, $tex, $tlv, $tap, $tgold, $tlp, $ttotal, $tkati, $thost, $tdate, $tarea, $tspot, $tpst, $titem) = split(/<>/);
			if($kid eq $tid)
			{
				next;
			}
			$rid = $tid;
			&read_battle;
			if($rank >= $krank){
				push(@rid, "<option value=$tid>$tname Lv$tlv（$sdrank[$krank]）</option>");
			}
		}

		my $shadow_duel = $mt->render_file('templates/window/shadow_duel.html.ep', {
			script      => $script,
			kid         => $kid,
			kpass       => $kpass,
			rid       => \@rid,
		});

		print $shadow_duel;
	}

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

	my @MESSAGE_LOG = &load_ini($message_file);

	my $hit = 0;
	my $i = 1;
	my @message_log;

	foreach(@MESSAGE_LOG)
	{
		my ($pid, $hid, $hname, $hmessage, $hhname, $htime) = split(/<>/);
		if($kid eq $pid)
		{
			if($max_gyo < $i)
			{
				last;
			}
			push(@message_log, "<hr size=0><small><b>$hname</b>　＞ 「<b>$hmessage</b>」($htime)</small><br>");
			$hit=1;
			$i++;
		}
		elsif($kid eq $hid)
		{
			push(@message_log, "<hr size=0><small>$kname から $hhname へ　＞ 「$hmessage」($htime)</small><br>");
		}
		elsif("Ａ" eq "$pid")
		{
			if($max_gyo < $i)
			{
				last;
			}
			push(@message_log, "<hr size=0><small><b>$hname (全員へ)</b>　＞ 「<b>$hmessage</b>」($htime)</small><br>");
			$hit=1;
			$i++;
		}
	}

	if(!$hit)
	{
		push(@message_log, "<hr size=0><p>$kname 宛てのメッセージはありません。</p>");
	}

	my $message = $mt->render_file('templates/window/message.html.ep', {
		script      => $script,
		kid         => $kid,
		kname       => $kname,
		kpass       => $kpass,
		mesid       => \@mesid,
		message_log => \@message_log,
		max_gyo     => $max_gyo,
	});

	print <<EOF;
$message
<hr size=0>
<form id="check_form" action="$script" method="post">
<select id="status-select" name="mode" onchange="javascript:selectTown(this);">
<option value="item_check">アイテム一覧</option>
<option value="status_check">ステータス詳細</option>
</select>
<input type="hidden" name="id" value="$kid" />
<input type="hidden" name="pass" value="$kpass" />
<input id="status-select-submit" type="submit" value="行動" />
</form>

<form id="pvp_form" action="$script" method="post">
<input type="hidden" name="mode" value="pvp" />
<input type="hidden" name="k2id" value="" />
<input type="hidden" name="k1id" value="$kid" />
<input type="hidden" name="id" value="$kid" />
<input type="hidden" name="pass" value="$kpass" />
<input id="pvp-select-submit" type="submit" value="行動" />
</form>

<script>
const spot = "$spot";
</script>
EOF

	&footer;

	&save_dat_append_1p;

	exit;
}

1;
