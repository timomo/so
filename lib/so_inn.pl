use utf8;
#--------#
#  宿屋  #
#--------#
sub yado
{
	my @inn_array = &load_ini($town_inn[$in{'area'}]);

	unless($kspot == 4 && $kpst == 0) { &error("不正なパラメータです。"); }

	#割引率の設定
	my $cut = 1 - $kn_6 / 200;

	&town_load;

	$get_area=$karea;$get_id="03";$get_cnt="0";
	&get_msg;

	my @rooms;

	foreach(@inn_array){
		my ($yno,$yname,$yfood,$yatc,$ydef,$yspd,$yrsk,$ygold) = split(/<>/);
		$ygold = int($ygold * $cut);
		# アイテム種別により処理変更
		my $ybuf = "";
		if ($yatc != 0) {
			$ybuf .= "攻撃：$yatc % ";
		}
		if ($ydef != 0) {
			$ybuf .= "防御：$ydef % ";
		}
		if ($yspd != 0) {
			$ybuf .= "先制：$yspd % ";
		}
		if ($yrsk != 0) {
			$ybuf .= "リスク低減：$yrsk % ";
		}
		if ($yatc == 0 && $ydef == 0 && $yspd == 0 && $yrsk == 0){
			$ybuf = "効果無し";
		}
		my $select = "";
		if($yno == 0){
			$select = "checked";
		}

		my $room = "<tr><td><input type=radio name=inn_no value=\"$yno\" $select></td><td>$yname</td><td>$yfood</td><td align=center>$ybuf</td><td align=center>$ygold</td></tr>";

		push(@rooms, $room);
	}

	my $html = $controller->render_to_string(
		template      => "yado",
		t_inn => $t_inn,
		get_msg => $get_msg,
		error => $error,
		script => $script,
		kgold => $kgold,
		rooms => \@rooms,
		kid => $kid,
		karea => $karea,
		spot => $spot,
	);

	print Encode::encode_utf8($html);

	$error = "";

	&save_dat_append;

	exit;
}

#------------#
#  体力回復  #
#------------#
sub yado_in
{
	if(! exists $in{inn_no})
	{
		$mode = "yado";
		$error = "部屋を選んでください。";
		&yado;
	}

	unless($kspot == 4 && $kpst == 0) { $mode = "yado"; &error("不正なパラメータです。"); }

	my @inn_array = &load_ini($town_inn[$in{'area'}]);
	my $yado_gold;
	my ($y_no,$y_name,$y_food,$y_atc,$y_def,$y_spd,$y_rsk,$y_gold);

	foreach(@inn_array){
		($y_no,$y_name,$y_food,$y_atc,$y_def,$y_spd,$y_rsk,$y_gold) = split(/<>/);
		if($in{'inn_no'} eq "$y_no") {
			$yado_gold = $y_gold;
			last;
		}
	}

	my $yn_6 = $kn_6;
	my $ygold = $kgold;
	my $ymaxhp = $kmaxhp;
	my $ylv = $klv;
	my $yn_3 = $kn_3;

	#割引率の設定
	my $cut = 1 - $yn_6 / 200;
	$yado_gold = int($yado_gold * $cut);

	if($ygold < $yado_gold) {
		$mode = "yado";
		$error = "所持金が足りません。";
		&yado;
	}
	else { $ygold = $ygold - $yado_gold; }
	$ymaxhp = int($ylv * 7.5 + $yn_3 * 7.5);

	our @kbuf = (100,100,100);
	our $krsk    = 0 - $y_rsk;
	$kbuf[0] = 100 + $y_atc;
	$kbuf[1] = 100 + $y_def;
	$kbuf[2] = 100 + $y_spd;
	our $buff_flg = 1;
	&regist_buff;

	$kgold = $ygold;
	$khp = $ymaxhp;
	$kmaxhp = $ymaxhp;

	&regist;

	our $get_area = $karea;
	our $get_id = "03";
	our $get_cnt = "1";
	&get_msg;

	&town_load;

	my $html = $controller->render_to_string(
		template => "yado_in",
		t_inn => $t_inn,
		get_msg => $get_msg,
		spot => $spot,
	);

	print Encode::encode_utf8($html);

	$mode = "yado";
	&save_dat_append;

	exit;
}

1;
