use utf8;
#------------------#
#  ステータス画面  #
#------------------#
sub status_check
{
	my $esex;
	if($ksex) { $esex = "男"; } else { $esex = "女"; }
	my $next_ex = $lv_up;

	our $rid = $kid;
	&read_buff;
	&town_load;
	&req_ap;

	our $k_eqp = 5;
	&get_equip;
	my $k_bid = $i_id;
	my $k_btype = $i_mode;
	my $k_batc = $i_dmg;
	my @equip;
	my $hit = 0;
	my $cnt = 1;

	foreach (1 .. 6) {
		$k_eqp = $cnt;
		&get_equip;
		if($cnt==1){
			&skill_load;
			$atc_skill1 = 0;
			$dmg1 = 0;
			$swg1 = 0;
			&get_attack;
			$k_par =int(10 + $avesk / 40);
		}elsif($cnt==2){
			$def1 += $i_dmg;
		}elsif($cnt==3){
			$def1 += $i_dmg;
		}elsif($cnt==4){
			if($i_dmg > 0){
				$k_blc =int($i_dmg + $ksk[21] / 40 + $kn_4 / 10);
				if($i_dmg * 2 < $k_blc){$k_blc = $i_dmg * 2;}
			} else {
				$k_blc = "-";
			}
		}
		# アイテム種別により処理変更
		if ($i_dmg == 0) {
			$i_name = "-";
			$i_dmg = "-";
		} elsif ($i_mode == 01) {
			$i_dmg = "<font color=$efcolor[2]>HP回復：$i_dmg</font>";
		} elsif ($i_mode == 07) {
			$i_dmg = "<font color=$efcolor[2]>治療：$i_dmg</font>";
		} elsif (10 <= $i_mode && $i_mode < 20) {
			$i_dmg = "<font color=$efcolor[0]>攻撃：$i_dmg</font>";
		} elsif (20 <= $i_mode && $i_mode < 30) {
			$i_dmg = "<font color=$efcolor[0]>攻撃：$i_dmg</font>";
		} elsif (30 <= $i_mode && $i_mode < 40) {
			$i_dmg = "<font color=$efcolor[1]>防御：$i_dmg</font>";
		} elsif (40 <= $i_mode && $i_mode < 50) {
			$i_dmg = "<font color=$efcolor[1]>防御：$i_dmg</font>";
		} elsif (50 <= $i_mode && $i_mode < 60) {
			$i_dmg = "<font color=$efcolor[1]>回避：$i_dmg</font>";
		} elsif (60 <= $i_mode && $i_mode < 70) {
			$i_dmg = "<font color=$efcolor[2]>補助：$i_dmg</font>";
		} elsif (70 <= $i_mode && $i_mode < 80) {
			$i_dmg = "<font color=$efcolor[0]>攻撃：$i_dmg</font>";
		} else {
			$i_dmg = "-";
		}
		my $mes = <<"EOM";
<tr>
<td class="b1" width='16%'>$item_eqp[$cnt]</td>
<td colspan="3" width='51%'><font color=$elmcolor[$i_eelm]>$i_name</font></td>
<td colspan="2" width='33%'>$i_dmg</td>
</tr>

EOM
		push(@equip, $mes);
		$cnt++;
	}

	my $def1 += int($kn_3 / 2);
	my $k_esc =int(5 + $kn_5  /2);
	my $spd1 =int($kn_5);
	my $clt1 = int(5 + $kn_4 / 4 + $avesk / 40);
	my $dmg1 = int($dmg1 * $rbuf[0]);
	$def1 = int($def1 * $rbuf[1]);
	$spd1 = int($spd1 * $rbuf[2]);

	my $atccol = $text;
	my $atcbuf = $rbuf[0] * 100 - 100;

	if($rbuf[0] > 1){
		$atccol = $gain;
		$atcbuf = "(+$atcbuf%)";
	} elsif($rbuf[0] < 1){
		$atccol = $down;
		$atcbuf = "($atcbuf%)";
	} else {
		$atcbuf = "";
	}

	my $defcol = $text;
	my $defbuf = $rbuf[1] * 100 - 100;

	if($rbuf[1] > 1){
		$defcol = $gain;
		$defbuf = "(+$defbuf%)";
	} elsif($rbuf[1] < 1){
		$defcol = $down;
		$defbuf = "($defbuf%)";
	} else {
		$defbuf = "";
	}

	my $spdbuf = "";
	my $spdcol = $text;
	my $spdbuf = $rbuf[2] * 100 - 100;

	if($rbuf[2] > 1){
		$spdcol = $gain;
		$spdbuf = "(+$spdbuf%)";
	} elsif($rbuf[2] < 1){
		$spdcol = $down;
		$spdbuf = "($spdbuf%)";
	} else {
		$spdbuf = "";
	}

	$error = "";
	$cnt = 0;
	my $cttl = 0;
	my $kmax= $kmax / 10;
	my @skills;

	foreach (0 .. @chara_skill) {
		if($ksk[$cnt] > 0){
			$sklcol = "COLOR=$text";
			if($ksk[$cnt] >= 300 && $ksk[$cnt] >= $kmx[$cnt]){
				$sklcol = "COLOR=#BB0000";
			}
			$kmx[$cnt] = $kmx[$cnt] / 10;
			$ksk[$cnt] = $ksk[$cnt] / 10;
			$cttl += $ksk[$cnt];
			my @select = ("","","");
			$select[$kmg[$cnt]] = "selected";

			my $mes = <<"EOM";
<tr>
<td class="b1">$chara_skill[$cnt]</td>
<td colspan="3"><font $sklcol>$ksk[$cnt] / $kmx[$cnt]</font></td>
<td colspan="1" align="center"><select name="kmg$cnt">
	<option value=0 $select[0]>上昇</option>
	<option value=1 $select[1]>下降</option>
	<option value=2 $select[2]>維持</option>
</select>
</td>
</tr>
EOM
			push(@skills, $mes);
		}
		$cnt++;
	}
	my $sklcol = "COLOR=$text";
	if($cttl >= $kmax){
		$sklcol = "COLOR=#BB0000";
	}

	my $html = $controller->render_to_string(
		template    => "status_check",
		script      => "/window/status",
		town_name   => \@town_name,
		spot        => $spot,
		karea       => $karea,
		kname       => $kname,
		esex        => $esex,
		klv         => $klv,
		kex         => $kex,
		khp         => $khp,
		kmaxhp      => $kmaxhp,
		klp         => $klp,
		max_lp      => $max_lp,
		rrsk        => $rrsk,
		kgold       => $kgold,
		kn_0        => $kn_0,
		kn_1        => $kn_1,
		kn_2        => $kn_2,
		kn_3        => $kn_3,
		kn_4        => $kn_4,
		kn_5        => $kn_5,
		kn_6        => $kn_6,
		kap         => $kap,
		kid         => $kid,
		dmg1        => $dmg1,
		swg1        => $swg1,
		atccol      => $atccol,
		atcbuf      => $atcbuf,
		def1        => $def1,
		defcol      => $defcol,
		spd1        => $spd1,
		spdcol      => $spdcol,
		spdbuf      => $spdbuf,
		clt1        => $clt1,
		k_par       => $k_par,
		k_blc       => $k_blc,
		k_esc       => $k_esc,
		chara_skill => \@chara_skill,
		sklcol      => $sklcol,
		ksk         => \@ksk,
		kmx         => \@kmax,
		cttl        => $cttl,
		kmax        => $kmax,
		req_ap      => \@req_ap,
		equip       => \@equip,
		skills      => \@skills,
		defbuf      => $defbuf,
	);

	return Encode::encode_utf8($html);
}

#------------------#
#  ステータス上昇  #
#------------------#
sub status_up
{
	my @sn = ();

	$sn[0] = $kn_0;
	$sn[1] = $kn_1;
	$sn[2] = $kn_2;
	$sn[3] = $kn_3;
	$sn[4] = $kn_4;
	$sn[5] = $kn_5;
	$sn[6] = $kn_6;
	$sap = $kap;

	if($sn[$in{'up'}] < 50){
		$reqap = 1;
	} elsif($sn[$in{'up'}] < 100){
		$reqap = 2;
	} else{
		$reqap = 3;
	}
	if($sap < $reqap) {
		$error = "APが$reqap 必要です。";
		&status_check;
	}
	else { $sap -= $reqap; }

	$sn[$in{'up'}]++;

	$kn_0 = $sn[0];
	$kn_1 = $sn[1];
	$kn_2 = $sn[2];
	$kn_3 = $sn[3];
	$kn_4 = $sn[4];
	$kn_5 = $sn[5];
	$kn_6 = $sn[6];
	$kap = $sap;

	&regist;

	print &status_check;

	exit;
}

#----------#
#  要求AP  #
#----------#
sub req_ap {
	@stt=();
	$stt[0] = $kn_0;$stt[1] = $kn_1;$stt[2] = $kn_2;$stt[3] = $kn_3;$stt[4] = $kn_4;$stt[5] = $kn_5;$stt[6] = $kn_6;
	@req_ap=();$cnt=0;
	foreach (0 .. @chara_skill) {
		if($stt[$cnt] < 50){
			$req_ap[$cnt] = 1;
		} elsif($stt[$cnt] < 100){
			$req_ap[$cnt] = 2;
		} else{
			$req_ap[$cnt] = 3;
		}
		$cnt++;
	}
}

1;
