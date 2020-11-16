use utf8;

#----------------#
#   メイン画面   #
#----------------#
sub log_in_frame
{
	my $html = $controller->render_to_string(
		template      => "log_in_frame",
		script        => $script,
		kid           => $kid,
		kname         => $kname,
		kpass         => $kpass,
		karea         => $karea,
		spot          => $spot,
		kspot         => $kspot,
		kpst          => $kpst,
		area          => $town_name[$karea],
		klv           => $klv,
		klp           => $klp,
		max_lp        => $max_lp,
		khp           => $khp,
		kmaxhp        => $kmaxhp,
		kex           => $kex,
		rrsk          => $rrsk,
		kgold         => $kgold,
	);

	&header;
	print Encode::encode_utf8($html);
	&footer;

	&save_dat_append;

	exit;
}

sub log_in
{
	my $esex = "女";
	$esex = "男" if($ksex);

	my @select_menu = ();
	$next_ex = $lv_up;

	my $town = &town_load;

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

	my $error_string = Encode::decode_utf8($error) if (! utf8::is_utf8($error));

	$error = "";

	if($kspot == 0 && $kpst == 0)
	{
		push(@select_menu, sprintf('<p class="answer-menu">【%sの施設】</p>', $town_name[$karea]));
		push(@select_menu, sprintf('<p id="mode_town-select_%s" class="select-menu">%s</p>', "yado", "宿屋：".$t_inn));
		push(@select_menu, sprintf('<p id="mode_town-select_%s" class="select-menu">%s</p>', "item_shop", "ショップ：".$t_inn));
		push(@select_menu, sprintf('<p id="mode_town-select_%s" class="select-menu">%s</p>', "user_shop", "市場：チュパフリマ：". $town_name[$karea]));
		push(@select_menu, sprintf('<p id="mode_town-select_%s" class="select-menu">%s</p>', "bank", "銀行：シマダ国営銀行（". $town_name[$karea]. "店）"));
	}
	else
	{
		push(@select_menu, qw|<p class="answer-menu">【キャンプ】</p>|);
		push(@select_menu, qw|<p id="mode_camp-select_rest" class="blink-before select-menu">休憩する</p>|);
		push(@select_menu, qw|<p id="mode_camp-select_monster" class="select-menu">キャンピング</p>|);
	}

	my ( $label, $optionHTML ) = ( "", "" );
	my @options;
	my $spot1 = $town_move[$karea][2];
	if ($kspot == 2)
	{
		$spot1 += $kpst;
	}
	elsif ($kspot == 3)
	{
		$spot1 -= $kpst;
	}
	else
	{
		$spot1 -= $kpst;
	}
	my $spot2 = $town_move[$karea][3];
	if ($kspot == 3)
	{
		$spot2 += $kpst;
	}
	elsif ($kspot == 2)
	{
		$spot2 -= $kpst;
	}
	else
	{
		$spot2 -= $kpst;
	}
	my $spot3 = $town_move[$karea][1];
	if ($kspot == 3)
	{
		$spot3 -= $kpst;
	}
	elsif ($kspot == 2)
	{
		$spot3 += $kpst;
	}
	else
	{
		$spot3 += $kpst;
	}


	$label = "【$town_name[$karea]周辺】";
	push( @options, [ "explore", sprintf( "%s郊外を探索する", $town_name[$karea] ) ] );
	push( @options, [ "field", sprintf( "%sへ向かう(距離 %s)", $town->{current}->{場所}, $spot3 ) ] );
	push( @options, [ "next", sprintf( "%s方面へ(距離 %s)", $town->{next}->{地名}, $spot1 ) ] );
	push( @options, [ "previous", sprintf( "%s方面へ(距離 %s)", $town->{previous}->{地名}, $spot2 ) ] );

	$label = "【行動】";
	push( @options, [ "explore", "探索する" ] );

	$label = "【行動】";
	push( @options, [ "forward", "先へ進む" ] );
	push( @options, [ "town", sprintf( "%sへ帰還する", $town_name[$karea] ) ] );

	push(@select_menu, qq|<p class="answer-menu">|. $label. qq|</p>|);
	push( @options, [ "backward", "引き返す" ] );

	for (@options)
	{
		push(@select_menu, sprintf('<p id="mode_monster-select_%s" class="select-menu">%s</p>', @$_));
		$optionHTML .= sprintf( "<option value=\"%s\">%s</option>\n", @$_);
	}

	my @rid;

	if($kspot == 0 && $kpst == 0)
	{
		$rid = $kid;
		&read_battle;
		$rank = $krank;
		$todd=0;

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
	}

	my $html = $controller->render_to_string(
		template      => "log_in",
		script        => $script,
		kid           => $kid,
		kname         => $kname,
		kpass         => $kpass,
		karea         => $karea,
		spot          => $spot,
		optionHTML    => $optionHTML,
		select_menu   => \@select_menu,
		kspot         => $kspot,
		kpst          => $kpst,
		rid           => \@rid,
		area          => $town_name[$karea],
		t_inn         => $t_inn,
		t_shop        => $t_shop,
		klv           => $klv,
		klp           => $klp,
		max_lp        => $max_lp,
		khp           => $khp,
		kmaxhp        => $kmaxhp,
		kex           => $kex,
		rrsk          => $rrsk,
		kgold         => $kgold,
		message       => \@message,
		error_string  => $error_string,
	);

	# &header;
	print Encode::encode_utf8($html);
	# &footer;

	&save_dat_append;

	exit;
}

1;
