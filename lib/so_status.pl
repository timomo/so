use utf8;
#------------------#
#  ステータス画面  #
#------------------#
sub status_check
{
	if($ksex) { $esex = "男"; } else { $esex = "女"; }
	$next_ex = $lv_up;

	$rid = $kid;
	&read_buff;

	&town_load;

	&header;

	if($kspot == 0 && $kpst == 1){
		$spot = "$town_name[$karea]郊外";
	} elsif($kspot == 1){
		$spot = "$area_name[$karea]最深部まで残り $kpst";
	} elsif($kspot == 2  && $kpst > 0){
		$spot = "$town_name[$farea]まで残り $kpst";
	} elsif($kspot == 3  && $kpst > 0){
		$spot = "$town_name[$rarea]まで残り $kpst";
	} else {
		$spot = "町の中";
	}

	print <<"EOM";
<b>$kname のステータス詳細</b>
<hr size=0>
<B><FONT COLOR="#FF9933">$error</FONT></B>
<form action="$script" method="post">

<div class="blackboard question">

<table border=0 width='100%'>
<tr>
<td valign=top width='40%'>
<table border=0 width='100%'>
<tr>
<td colspan="10" class="b2" align="center">現在地</td>
</tr>
<tr>
<td class="b1" width='25%'>地名</td>
<td colspan="9" width='75%'>$town_name[$karea]</td>
</tr>
<tr>
<td class="b1" width='25%'>場所</td>
<td colspan="9" width='75%'>$spot</td>
</tr>
<tr>
<td colspan="10" class="b2" align="center">状態</td>
</tr>
<tr>
<td class="b1" width='20%'>名前</td>
<td colspan="4" width='30%'>$kname</td>
<td class="b1" width='20%'>性別</td>
<td colspan="4" width='30%'>$esex</td>
</tr>
<tr>
<td class="b1">レベル</td>
<td colspan="4">$klv</td>
<td class="b1">経験値</td>
<td colspan="4">$kex%</td>
</tr>
<tr>
<td class="b1">HP</td>
<td colspan="4">$khp\/$kmaxhp</td>
<td class="b1">LP</td>
<td colspan="4">$klp\/$max_lp</td>
</tr>
<tr>
<td class="b1">リスク</td>
<td colspan="4">$rrsk%</td>
<td class="b1">所持金</td>
<td colspan="4">$kgold</td>
</tr>
<tr>
<td colspan="10" class="b2" align="center">能力値</td>
</tr>
<tr>
<td class="b1">力</td>
<td colspan="4">$kn_0</td>
<td class="b1">賢さ</td>
<td colspan="4">$kn_1</td>
</tr>
<tr>
<td class="b1">信仰心</td>
<td colspan="4">$kn_2</td>
<td class="b1">体力</td>
<td colspan="4">$kn_3</td>
</tr>
<tr>
<td class="b1">器用さ</td>
<td colspan="4">$kn_4</td>
<td class="b1">素早さ</td>
<td colspan="4">$kn_5</td>
</tr>
<tr>
<td class="b1">魅力</td>
<td colspan="4">$kn_6</td>
<td class="b1">残りAP</td>
<td colspan="4">$kap</td>
</tr>
<tr>
<td colspan="5" align="center">能力値上昇(要求AP)</td>
<td align="center"><select name=up>
EOM
	&req_ap;
	$select[$in{'up'}] = "selected";
	print <<"EOM";
	<option value=0 $select[0]>力($req_ap[0])
	<option value=1 $select[1]>賢さ($req_ap[1])
	<option value=2 $select[2]>信仰心($req_ap[2])
	<option value=3 $select[3]>体力($req_ap[3])
	<option value=4 $select[4]>器用さ($req_ap[4])
	<option value=5 $select[5]>素早さ($req_ap[5])
	<option value=6 $select[6]>魅力($req_ap[6])
</select></td>
<td colspan="4" align="center">
<input type=hidden name=id value="$in{'id'}">
<input type=hidden name=pass value="$in{'pass'}">
<input type=hidden name=mode value=status_up>
<input type=submit value="上昇する">
</td>
</table>
</form>
</td>
</tr><tr>
<td valign="top" width='30%'>
<table border=0 width='100%'>
<tr>
<td colspan="6" class="b2" align="center">装備</td>
</tr>
EOM
	$k_eqp = 5;
	&get_equip;
	$k_bid = $i_id;
	$k_btype = $i_mode;
	$k_batc = $i_dmg;

	$hit = 0;
	$cnt = 1;
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
			print <<"EOM";
<tr>
<td class="b1" width='16%'>$item_eqp[$cnt]</td>
<td colspan="3" width='51%'><font color=$elmcolor[$i_eelm]>$i_name</font></td>
<td colspan="2" width='33%'>$i_dmg</td>
</tr>

EOM
		$cnt++;
	}

	$def1 += int($kn_3 / 2);
	$k_esc =int(5 + $kn_5  /2);
	$spd1 =int($kn_5);

	$clt1 = int(5 + $kn_4 / 4 + $avesk / 40);

	$dmg1 = int($dmg1 * $rbuf[0]);
	$def1 = int($def1 * $rbuf[1]);
	$spd1 = int($spd1 * $rbuf[2]);

	$atccol = $text;
	$atcbuf = $rbuf[0] * 100 - 100;
	if($rbuf[0] > 1){
		$atccol = $gain;
		$atcbuf = "(+$atcbuf%)";
	} elsif($rbuf[0] < 1){
		$atccol = $down;
		$atcbuf = "($atcbuf%)";
	} else {
		$atcbuf = "";
	}

	$defcol = $text;
	$defbuf = $rbuf[1] * 100 - 100;
	if($rbuf[1] > 1){
		$defcol = $gain;
		$defbuf = "(+$defbuf%)";
	} elsif($rbuf[1] < 1){
		$defcol = $down;
		$defbuf = "($defbuf%)";
	} else {
		$defbuf = "";
	}

	$spdbuf = "";
	$spdcol = $text;
	$spdbuf = $rbuf[2] * 100 - 100;
	if($rbuf[2] > 1){
		$spdcol = $gain;
		$spdbuf = "(+$spdbuf%)";
	} elsif($rbuf[2] < 1){
		$spdcol = $down;
		$spdbuf = "($spdbuf%)";
	} else {
		$spdbuf = "";
	}

	print <<"EOM";
<tr>
<td colspan="6" class="b2" align="center">効果</td>
</tr>
<tr>
<td class="b1" width='25%'>攻撃力</td>
<td colspan="2" width='25%'>$dmg1 × $swg1 &nbsp;<font COLOR=$atccol>$atcbuf</font></td>
<td class="b1" width='25%'>防御力</td>
<td colspan="2" width='25%'>$def1 &nbsp;<font COLOR=$defcol>$defbuf</font></td>
</tr>
<tr>
<td class="b1">先制補正</td>
<td colspan="2">$spd1 % &nbsp;<font COLOR=$spdcol>$spdbuf</font></td>
<td class="b1">技発動</td>
<td colspan="2">$clt1 %</td>
</tr>
<tr>
<td class="b1">受け流し</td>
<td colspan="2">$k_par %</td>
<td class="b1">ブロック</td>
<td colspan="2">$k_blc %</td>
</tr>
<tr>
<td class="b1">回避</td>
<td colspan="2">$k_esc %</td>
<td class="b1">&nbsp;</td>
<td colspan="2">&nbsp;</td>
</tr>
<tr>
<td colspan="6">※修正後の数値を表示しています</td>
</tr>
</table>
</td>

</tr><tr>

<td valign="top" width='30%'>
<form action="$script" method="post">
<table border=0 width='100%'>
<tr>
<td colspan="5" class="b2" align="center">スキル</td>
</tr>
EOM
	$error = "";
	$cnt = 0;
	$cttl = 0;
	$kmax= $kmax / 10;
	foreach (0 .. @chara_skill) {
		if($ksk[$cnt] > 0){
			$sklcol = "COLOR=$text";
			if($ksk[$cnt] >= 300 && $ksk[$cnt] >= $kmx[$cnt]){
				$sklcol = "COLOR=#BB0000";
			}
			$kmx[$cnt] = $kmx[$cnt] / 10;
			$ksk[$cnt] = $ksk[$cnt] / 10;
			$cttl += $ksk[$cnt];
			print <<"EOM";
<tr>
<td class="b1">$chara_skill[$cnt]</td>
<td colspan="3"><font $sklcol>$ksk[$cnt] / $kmx[$cnt]</font></td>
<td colspan="1" align="center"><select name=kmg$cnt>
EOM
	@select = ("","","");
	$select[$kmg[$cnt]] = "selected";
	print <<"EOM";
	<option value=0 $select[0]>上昇
	<option value=1 $select[1]>下降
	<option value=2 $select[2]>維持
</select>
</td>
</tr>
EOM
		}
		$cnt++;
	}
	$sklcol = "COLOR=$text";
	if($cttl >= $kmax){
		$sklcol = "COLOR=#BB0000";
	}
	print <<"EOM";
<tr>
<td class="b1">合計</td>
<td colspan="3"><font $sklcol>$cttl / $kmax</font></td>
<td colspan="1" align="center">
<input type=hidden name=id value="$in{'id'}">
<input type=hidden name=pass value="$in{'pass'}">
<input type=hidden name=mode value=skill_manage>
<input type=submit value="登録する">
</td>
</tr>
</td>
</table>
</form>
</tr>
</table>

</div>

<hr size=0><p>
			<script>
const spot = "$spot";
</script>
EOM

	&footer;
	&save_dat_append;

	exit;
}

#------------------#
#  ステータス上昇  #
#------------------#
sub status_up {

	# ファイルロック
	if ($lockkey == 1) { &lock1; }
	elsif ($lockkey == 2) { &lock2; }
	elsif ($lockkey == 3) { &file'lock; }

	@status = &load_ini($chara_file);

	$hit=0;@status_new=();@sn=();
	foreach(@status){
		($sid,$spass,$sname,$ssex,$schara,$sn[0],$sn[1],$sn[2],$sn[3],$sn[4],$sn[5],$sn[6],$shp,$smaxhp,$sex,$slv,$sap,$sgold,$slp,$stotal,$skati,$shost,$sdate,$sarea,$sspot,$spst,$sitem) = split(/<>/);
		if($in{'id'} eq "$sid" and $in{'pass'} eq "$spass") {
			$hit=1;
			if($sn[$in{'up'}] < 50){
				$reqap = 1;
			} elsif($sn[$in{'up'}] < 100){
				$reqap = 2;
			} else{
				$reqap = 3;
			}
			if($sap < $reqap) {
				$error = "APが$reqap必要です。";
				&status_check;
			}
			else { $sap -= $reqap; }
			$sn[$in{'up'}]++;

			my $mes = "$sid<>$spass<>$sname<>$ssex<>$schara<>$sn[0]<>$sn[1]<>$sn[2]<>$sn[3]<>$sn[4]<>$sn[5]<>$sn[6]<>$shp<>$smaxhp<>$sex<>$slv<>$sap<>$sgold<>$slp<>$stotal<>$skati<>$shost<>$sdate<>$sarea<>$sspot<>$spst<>$sitem<>\n";
			my $utf8 = Encode::encode_utf8($mes);

			unshift(@status_new,$utf8);
		}else{
			push(@status_new,"$_\n");
		}
	}

	if(!$hit) { &error("入力されたIDは登録されていません。又はパスワードが違います。"); }

	open(OUT,">$chara_file");
	print OUT @status_new;
	close(OUT);

	# ロック解除
	if ($lockkey == 3) { &file'unlock; }
	else { if(-e $lockfile) { unlink($lockfile); } }

	&status_check;
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
