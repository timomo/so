#----------------------#
#  モンスターとの戦闘  #
#----------------------#
sub monster {
	if($battle_flag) { &error("現在行動中です。お待ち下さい。"); }

	open(IN,"$chara_file");
	@battle = <IN>;
	close(IN);

	$hit=0;
	foreach(@battle){
		($kid,$kpass,$kname,$ksex,$kchara,$kn_0,$kn_1,$kn_2,$kn_3,$kn_4,$kn_5,$kn_6,$khp,$kmaxhp,$kex,$klv,$kap,$kgold,$klp,$ktotal,$kkati,$khost,$kdate,$karea,$kspot,$kpst,$kitem) = split(/<>/);
		if($in{'id'} eq "$kid" and $in{'pass'} eq "$kpass") {
			$hit=1;
			last;
		}
	}

	if(!$hit) { &error("入力されたIDは登録されていません。又はパスワードが違います。"); }

	&skill_load;

	$ltime = time();
	$ltime = $ltime - $kdate;
	$vtime = $b_time - $ltime;
	$mtime = $m_time - $ltime;

	if($ltime < $m_time and $ktotal) {
		$error = "$mtime秒後に行動できます。";
		$mode = "log_in";
		&log_in;
	}

	&add_risk;
	$wrsk = $krsk;

	if($wrsk > 100){
		$khp -= int($khp * $wrsk / 1000);
		if($khp < 1){
			$khp = 1;
		}
	}

	@kbuff = ($rbuf[0],$rbuf[1],$rbuf[2],0);
	@mbuff = (1,1,1,0);

	&move;

	$battle_flag=1;

	$bossflg=0;
	if($kspot == 0) {
		$pop_enemy = $town_enemy[$karea];
	} elsif($kspot == 1) {
		if($kpst < 1){
			$pop_enemy = $area_boss[$karea];
			$bossflg = 1;
		} else {
			$pop_enemy = $area_enemy[$karea];
		}
	} elsif($kspot == 2) {
		if($kpst > int($town_move[$karea][$kspot] / 2)){
			$pop_enemy = $town_enemy[$karea];
		} else {
			$pop_enemy = $town_enemy[$farea];
		}
	} elsif($kspot == 3) {
		if($kpst > int($town_move[$karea][$kspot] / 2)){
			$pop_enemy = $town_enemy[$karea];
		} else {
			$pop_enemy = $town_enemy[$rarea];
		}
	}

	open(IN,"$pop_enemy");
	@MONSTERNO = <IN>;
	close(IN);

	$r_no = int(rand(@MONSTERNO));

	open(IN,"$monster_file");
	@MONSTER = <IN>;
	close(IN);

	foreach(@MONSTER){
		($mno,$mname,$mlv,$mex,$mgold,$mhp,$msp,$mdmg,$mdef,$mspd,$mtec,$melm,$mtype,$mdrop) = split(/<>/);
		if(int($MONSTERNO[$r_no]) == $mno){ last; }
	}

	if($in{'c_name'}) { $kname = $in{'c_name'}; }
	$khp_flg = $khp;
	$kd_flg = 0;

	$mhp = int(rand($mhp)) + $msp;
	$mhp_flg = $mhp;
	$md_flg = 0;

	$i=1;$j=1;@battle_date=();
	foreach(1..$turn) {

		$k_par = 0;
		$k_blc = 0;
		$k_esc = 0;
		$m_par = 0;
		$m_esc = 0;

		$k_wnam = "";
		$k_anam = "";

		#補助
		$k_eqp = 5;
		&get_equip;
		$k_bid = $i_id;
		$k_bname = $i_name;
		$k_btype = $i_mode;
		$k_batc = $i_dmg;

		#武器
		$k_eqp = 1;
		&get_equip;
		$atc_skill1 = 0;
		$dmg1 = 0;
		$swg1 = 0;
		$com1 = "";
		$clit1 = "";
		@efct1 = (0,0,0,0,0,0,0,0);
		&get_attack;
		$k_bflg = $bflg;

		$k_wid = $i_id;
		$k_wdef = $i_def;
		$elm1 = $i_eelm;
		@kbuf = (1,1,1,0);
		@mbuf = (1,1,1,0);
		$kskl = $avesk;
		$mskl = $mlv;
		&get_tech;
		@kbuftmp1 = @kbuf;
		@kbuftmp2 = @mbuf;

		$k_wnam = $i_name;
		$k_welm = $i_eelm;

		$dhp = 0;
		if($k_btype eq "60" && $kbuff[3] == 0){
			if(($ksk[13] / 50 + $k_batc) > rand(100)){
				if($atc_skill1 <= 5){
					$k_welm = 6;
					$dmg1 += $ksk[13] / 10;
				}
				$dhp = int($khp_flg * (rand(5) + 1) / 100 + 1);
			}

		}

		$com1 .= "<font color=$elmcolor[$k_welm]>$knameは$k_wnam$sklmsg</font>";

		#防具
		$k_eqp = 2;
		&get_equip;
		$kdef = $i_dmg;
		$k_aelm = $i_eelm;

		$k_eqp = 3;
		&get_equip;
		$kdef += $i_dmg;

		$k_eqp = 4;
		&get_equip;
		$k_blc = $i_dmg;
		$k_anam = $i_name;
		$k_sid = $i_id;
		$k_sdef = $i_def;

		$kred = int($kdef / 2);

		$k_eqp = 6;
		&get_equip;
		$k_rid = $i_id;
		$k_no = $i_mode;
		$k_rcv = $i_dmg;
		$k_rnam = $i_name;

		$com2  = "";
		$clit2 = "";
		$clit3 = "";

		$display = "none";

		$katcv = int($kbuff[0] * 100);
		$kdefv = int($kbuff[1] * 100);
		$kspdv = int($kbuff[2] * 100);
		$kstpv = "";
		if($kbuff[3] < 0){
			$kstpv = "行動不能";
		}

		$matcv = int($mbuff[0] * 100);
		$mdefv = int($mbuff[1] * 100);
		$mspdv = int($mbuff[2] * 100);
		$mstpv = "";
		if($mbuff[3] < 0){
			$mstpv = "行動不能";
		}

		$kefv = "<font color=$efcolor[0]>$katcv%</font> / <font color=$efcolor[1]>$kdefv%</font> / <font color=$efcolor[2]>$kspdv%</font> $kstpv";
		$mefv = "<font color=$efcolor[0]>$matcv%</font> / <font color=$efcolor[1]>$mdefv%</font> / <font color=$efcolor[2]>$mspdv%</font> $mstpv";

		$battle_date[$j] .= <<"EOM";
<TR>
	<TD CLASS="b2" COLSPAN="3" ALIGN="center">
	$iターン
	</TD>
</TR>
<TR>
<TD>
<TABLE BORDER=1>
<TR>
	<TD CLASS="b1">
	LV
	</TD>
	<TD CLASS="b1">
	名前
	</TD>
	<TD CLASS="b1">
	HP
	</TD>
</TR>
<TR>
	<TD>
	$klv
	</TD>
	<TD>
	<font color=$elmcolor[$k_aelm]>$kname</font>
	</TD>
	<TD>
	$khp_flg/$kmaxhp
	</TD>
</TR>
<TR>
	<TD CLASS="b1" COLSPAN="3" ALIGN="center">
	効果 攻/防/速
	</TD>
</TR>
<TR>
	<TD COLSPAN="3" ALIGN="center">
	$kefv
	</TD>
</TR>
</TABLE>
</TD>
<TD>
<FONT COLOR="#9999DD">VS</FONT>
</TD>
<TD>
<TABLE BORDER=1>
<TR>
	<TD CLASS="b1">
	LV
	</TD>
	<TD CLASS="b1">
	名前
	</TD>
	<TD CLASS="b1">
	HP
	</TD>
</TR>
<TR>
	<TD>
	$mlv
	</TD>
	<TD>
	<font color=$elmcolor[$melm]>$mname</font>
	</TD>
	<TD>
	$mhp/$mhp_flg
	</TD>
</TR>
<TR>
	<TD CLASS="b1" COLSPAN="3" ALIGN="center">
	効果 攻/防/速
	</TD>
</TR>
<TR>
	<TD COLSPAN="3" ALIGN="center">
	$mefv
	</TD>
</TR>
</TABLE>
</TD>
<TR>
<TD COLSPAN="3">
<BR>
EOM

	if($k_btype eq "60" && $dhp > 0){
		&skill_up(13,$mlv);
		$battle_date[$j] .= "<font color=$elmcolor[6]>$knameはHPを$dhp消費し、黒いオーラを噴き出した・・</font><p>$kskm";
		$kskm = "";
		$khp_flg -= $dhp;
		if($khp_flg < 1){
			$khp_flg = 1;
		}
		$k_aelm = 6;
	}

	$dcut = 0;$drtn = 0;
	if($k_btype eq "61" && $kbuff[3] == 0){
		if(($ksk[15] / 50 + $k_batc) > rand(100)){
			&skill_up(14,$mlv);
			$battle_date[$j] .= "$knameは相手を見据えて身構えた！<p>$kskm";
			$kskm = "";
			$dcut = 1;
		}
	}

	$dup1 = 0;
	if($k_btype eq "62" && $kbuff[3] == 0 ){
		if(($ksk[15] / 50 + $k_batc) > rand(100)){
			&skill_up(15,$mlv);
			$dup1 = int(rand($ksk[15] / 100) + 1);
			$battle_date[$j] .= "$knameは印を結んだ・・・影分身が$dup1体現れた！<p>$kskm";
			$kskm = "";
		}

	}

	$fst_flg = int($kn_5 * $kbuff[2] - $mspd * $mbuff[2] + rand(30));
	if($dcut == 1){
		$fst_flg = 0;
	}elsif($efct1[0]){
		$fst_flg = 30;
		$com1 = "$knameの先制攻撃！<br>$com1";
	}
	$turnflg = 0;
	foreach(1..2) {

		if(($fst_flg > 15 && $turnflg == 0) ||($fst_flg <= 15 && $turnflg == 1)){
		if($efct1[1]){
			$dmg1 = $dmg1 - int($mdef * $mbuff[1] * (1 - $efct1[1] / 4) );
		} else {
			$dmg1 = $dmg1 - int($mdef * $mbuff[1]);
		}

		if($efct1[2]){
			$swg1 = $swg1 * $efct1[2];
		}

		#属性計算
		$aelm = $k_welm;
		$delm = $melm;
		&elm_judge;
		$kefe = $eefe;
		if($kefe > 100){
			$clit1 = "<br><b><font color=$elmcolor[$k_welm]>効果は抜群だ！</font></b><br>";
			$efct1[7] += 1;
		}elsif($kefe < 100){
			$clit1 = "<br><b><font color=$elmcolor[$k_welm]>効果は今ひとつのようだ・・</font></b><br>";
			$efct1[7] -= 1;
		}

		$swg1 = int(($swg1 + rand($swg1)) / 2 + 1);
		$dmg1 = int((($dmg1 + rand($dmg1)) / 3) * $kefe / 100 * $kbuff[0]);
		if($dmg1 < 0){$dmg1 = 0}

		if($k_btype eq "61" && $dcut == 2){
				$com1 = "相手の勢いを利用してカウンターを繰り出す・・<br>$com1";
				$dmg1 += int($drtn * ($ksk[15] + 1000) / 3000);
		}

		if($k_btype eq "62" && $dup1 > 0 && $atc_skill1 <= 5){
				$com1 .= "影分身が$dup1体攻撃に参加した！<br>";
				$swg1 += $dup1;
		}

		$dmgcnt = 5;$tmpdmg = $dmg1;$hitdmg=0;
		foreach (1 .. $swg1) {
			$hitdmg = int($tmpdmg / $dmgcnt);
			if($hitdmg < 1){$hitdmg = 1;}
			$dmg1 += $hitdmg;
			$dmgcnt++;
			if($dmgcnt > 20){$dmgcnt = 20;}
		}

		$m_esc =(5 + $mspd - $ksk[$atc_skill1] / 40 - rand(100));

		if($kbuff[3] < 0 ){
			$dmg1 = 0;
			$com1 = "$knameは動けない！<br>";
			$kbuff[3]+= 1;
		} elsif($m_esc > 0 && $clit1 eq "" && $dmg1 > 0) {
		  $dmg1 = 0;
		  $com1 .= "$mnameはかわした！<br>";
		}

		$btl_flg = 0;
		if($kmaxhp / 3 > $khp_flg && $k_rcv > 0 && $k_no eq "01"){
			$btl_flg = 1;
			$k_id = $k_rid;
			&item_sell;
			$kitem = $item_count;
			$khp_flg = $khp_flg + $k_rcv;
			if($khp_flg > $kmaxhp){$khp_flg = $kmaxhp;}
			$com1 = "$kname は $k_rnam を使用した！ HPが<font class=\"dmg\"><b>$k_rcv</b></font> 回復！";
			$dmg1 = 0;
			&add_risk;
		} elsif($kmaxhp / 3 > $khp_flg && $k_rcv > 0 && $k_no eq "07"){
			$btl_flg = 1;
			$k_id = $k_rid;
			&item_sell;
			$kitem = $item_count;
			$rcvhp = int($k_rcv * ($ksk[20]/ 1000 + rand(2) / 5 + 1) / 2);
			&skill_up(20,($kmaxhp - $khp_flg) / 10);
			if($kskm ne ""){ $kskm = "<p>$kskm"; }
			$khp_flg = $khp_flg + $rcvhp;
			if($khp_flg > $kmaxhp){$khp_flg = $kmaxhp;}
			$com1 = "$kname は $k_rnam を使用した！ HPが<font class=\"dmg\"><b>$rcvhp</b></font> 回復！$kskm";
			$dmg1 = 0;
			&add_risk;
		}

		if($dmg1 > 0){
		  $kbuff[0] = $kbuff[0] * $kbuftmp1[0];
		if($kbuff[0] < 0.5){$kbuff[0] = 0.5;}
		if($kbuff[0] > 1.5){$kbuff[0] = 1.5;}

		  $kbuff[1] = $kbuff[1] * $kbuftmp1[1];
		if($kbuff[1] < 0.5){$kbuff[1] = 0.5;}
		if($kbuff[1] > 1.5){$kbuff[1] = 1.5;}

		  $kbuff[2] = $kbuff[2] * $kbuftmp1[2];
		if($kbuff[2] < 0.5){$kbuff[2] = 0.5;}
		if($kbuff[2] > 1.5){$kbuff[2] = 1.5;}

		  $kbuff[3] += $kbuftmp1[3];

		  $mbuff[0] = $mbuff[0] * $kbuftmp2[0];
		if($mbuff[0] < 0.5){$mbuff[0] = 0.5;}
		if($mbuff[0] > 1.5){$mbuff[0] = 1.5;}

		  $mbuff[1] = $mbuff[1] * $kbuftmp2[1];
		if($mbuff[1] < 0.5){$mbuff[1] = 0.5;}
		if($mbuff[1] > 1.5){$mbuff[1] = 1.5;}

		  $mbuff[2] = $mbuff[2] * $kbuftmp2[2];
		if($mbuff[2] < 0.5){$mbuff[2] = 0.5;}
		if($mbuff[2] > 1.5){$mbuff[2] = 1.5;}

		  $mbuff[3] += $kbuftmp2[3];
		}

		if($efct1[7] * 5 + $kn_4 / 16 + $ksk[$atc_skill1] / 80 - $mlv / 4 > int(rand(100)) && $dmg1 > 0 && $efct1[7] > 0){
			$clit1 .= "<br><b class=\"clit\">$mname$death_msg[$atc_skill1][$k_welm]</b><br>";
			$md_flg=1;
		}

		$kskm = "";
		if($dmg1 > 0){
			$battle_date[$j] .= "$com1そして<b>$swg1</b>回 ヒットし、 $mname に <font class=\"dmg\"><b>$dmg1</b></font> のダメージ！$efcmsg$clit1<p>";
			&skill_up($atc_skill1,$mlv);
			if($kskm ne ""){
				$battle_date[$j] .= $kskm;
				$kskm = "";
			}

			if($k_bflg > 0){
				$btl_flg = 1;
				$k_id = $k_bid;
				&item_sell;
				$kitem = $item_count;
				$battle_date[$j] .= "$knameは素早く次の$k_bnameを準備した！<p>";
			}


			if($atc_skill1 > 5){
				&skill_up(12,$mlv);
			}elsif($atc_skill1 == 3 ||$atc_skill1 == 4 ){
				&skill_up(11,$mlv);
			} else {
				&skill_up(10,$mlv);
			}
			if($kskm ne ""){
				$battle_date[$j] .= $kskm;
				$kskm = "";
			}
		} else {
			$battle_date[$j] .= "$com1<p>";
		}
		$mhp = $mhp - $dmg1;
		if($mhp <= 0 || $md_flg) { $win = 1; last; }

		} else {
		($mwatc,$mwclt,$mwelm,$mwefct,$mwmsg) = split(/<>/,$enemy_msg[$mtype][int(rand(3))]);
		$com2 = "<font color=$elmcolor[$mwelm]>$mnameは$mwmsg</font><br>";

		#属性計算
		$aelm = $mwelm;
		$delm = $k_aelm;
		&elm_judge;
		$mefe = $eefe;
		if($mefe > 100){
			$clit3 = "<br><b><font color=$elmcolor[$mwelm]>効果は抜群だ！</font></b><br>";
		}elsif($mefe < 100){
			$clit3 = "<br><b><font color=$elmcolor[$mwelm]>効果は今ひとつのようだ・・</font></b><br>";
		}

		$dmg2 = int($mlv + (rand($mdmg) + $mdmg) / 2 * $mefe / 100 * $mbuff[0] * (100 - $kred) / 100 * $mwatc / 100) - int(($kn_3 / 2 + $kdef) * $kbuff[1]);

		if($atc_skill1 <= 5){
			$k_par =int(10 + $ksk[$atc_skill1] / 40 - $mlv / 2 - rand(100));
		}

		if($k_blc > 0){
			$tmpblc = $k_blc + $kn_4 / 10 + $ksk[21] / 40;
			if($k_blc * 2 < $tmpblc){$tmpblc = $k_blc * 2;}
			if($k_btype eq "61" && $dcut == 1){
				$tmpblc += $ksk[14] / 100;
			}
			$k_blc =int($tmpblc - $mlv / 2 - rand(100));
		}

		$k_esc = int(5 + $kn_5 / 2 + $ksk[$atc_skill1] / 20 - $mlv - rand(100));

		if($dmg2 < 1){$dmg2 = 1}

		if($mbuff[3] < 0 ){
			$dmg2 = 0;
			$com2 = "$mnameは動けない！<br>";
			$mbuff[3]+= 1;
		} elsif($k_blc > 0 && $dmg2 > 0 && $k_btype eq "61" && $dcut == 1 && ($atc_skill1 <= 2 || $atc_skill1 == 5)){
		  $com2 .= "$knameは$k_anamで弾くと同時に踏み込んだ！<br>$kskm";
		  $dcut = 2;
		  $drtn = $dmg2;
		  $dmg2 = 0;
		} elsif($k_btype eq "62" && $dmg2 > 0 && $dup1 > 0){
		  $duphp = int($khp_flg / ($dup1 * 4));
		  $dupd=0;
		  foreach(1..$dup1) {
		    $dupd++;
		    $dmg2 -= $duphp;
		    if($dmg2 <= 0) {$dmg2=0;last; }
		  }
		  $com2 .= "影分身が$dupd人身代わりになった！<br>";
		  $dup1 -= $dupd;
		  if($dup1 < 1) {$dup1=0;}
		} elsif($k_par > 0 && $dmg2 > 0){
		  $com2 .= "$knameは$k_wnamで受け流した！<br>";
		  $dmg2 = 0;
		} elsif($k_blc > 0 && $dmg2 > 0) {
		  $kskm = "";
		  &skill_up(21,$mlv);
		  if($kskm ne ""){ $kskm = "<p>$kskm"; }
		  $com2 .= "$knameは$k_anamで防いだ！<br>$kskm";
		  $dmg2 = 0;
		} elsif($k_esc > 0 && $dmg2 > 0) {
		  $com2 .= "$knameはかわした！<br>";
		  $dmg2 = 0;
		}

		$mefcmsg = "";
		if($mtec + $mwclt > int(rand(100)) && $dmg2 > 0) {
			$clit2 = "<b class=\"clit\">クリティカル！！</b>";
			$dmg2 = int($dmg2 * 1.25);
			@kbuf = (1,1,1,0);
			@mbuf = (1,1,1,0);
			&get_mefc;
			@mbuftmp1 = @kbuf;
			@mbuftmp2 = @mbuf;

			  $kbuff[0] = $kbuff[0] * $mbuftmp1[0];
			if($kbuff[0] < 0.5){$kbuff[0] = 0.5;}
			if($kbuff[0] > 1.5){$kbuff[0] = 1.5;}

			  $kbuff[1] = $kbuff[1] * $mbuftmp1[1];
			if($kbuff[1] < 0.5){$kbuff[1] = 0.5;}
			if($kbuff[1] > 1.5){$kbuff[1] = 1.5;}

			  $kbuff[2] = $kbuff[2] * $mbuftmp1[2];
			if($kbuff[2] < 0.5){$kbuff[2] = 0.5;}
			if($kbuff[2] > 1.5){$kbuff[2] = 1.5;}

			  $kbuff[3] += $mbuftmp1[3];

			  $mbuff[0] = $mbuff[0] * $mbuftmp2[0];
			if($mbuff[0] < 0.5){$mbuff[0] = 0.5;}
			if($mbuff[0] > 1.5){$mbuff[0] = 1.5;}

			  $mbuff[1] = $mbuff[1] * $mbuftmp2[1];
			if($mbuff[1] < 0.5){$mbuff[1] = 0.5;}
			if($mbuff[1] > 1.5){$mbuff[1] = 1.5;}

			  $mbuff[2] = $mbuff[2] * $mbuftmp2[2];
			if($mbuff[2] < 0.5){$mbuff[2] = 0.5;}
			if($mbuff[2] > 1.5){$mbuff[2] = 1.5;}

			  $mbuff[3] += $mbuftmp2[3];
		}

		if($mtec / 2 - $ksk[$atc_skill1] / 80 > int(rand(100)) && $dmg2 > 0 && $clit2 ne "") {
			$clit3 = "<br><b class=\"clit\">$knameは気絶した・・</b>";
			$kd_flg=1;
		}

		if($dmg2 > 0){
			$battle_date[$j] .= "$com2 $clit2  $kname は <font class=\"dmg\"><b>$dmg2</b></font> のダメージ！$mefcmsg$clit3<p>";
		} else {
			$battle_date[$j] .= "$com2<p>";
		}
		$khp_flg = $khp_flg - $dmg2;
		if($khp_flg <= 0 || $kd_flg) { $win = 2; last; }

		}
		$turnflg = 1;
		}

		if($win > 0) {
			$nextlink ="次へ>&nbsp;&nbsp;最後>>";
		} else {
			$nextlink ="<a href=\"javascript:page(3)\">次へ></a>&nbsp;&nbsp;<a href=\"javascript:page(4)\">最後>></a>";
		}

		if($i == 1) {
			$backlink ="<<最初&nbsp;&nbsp;<戻る";
		} else {
			$backlink ="<a href=\"javascript:page(1)\"><<最初</a>&nbsp;&nbsp;<a href=\"javascript:page(2)\"><戻る</a>";
		}

		$battle_date[$j] = <<"EOM";
<DIV id="sel$i" style="display: $display">
<TABLE BORDER=0>
<TR>
	<TD COLSPAN="3" ALIGN="right">
	$backlink&nbsp;&nbsp;$nextlink
	</TD>
</TR>
$battle_date[$j]
EOM

		if($win > 0) {last; }

		$battle_date[$j] .= <<"EOM";
</TD>
</TR>
</TABLE>
</DIV>
EOM

		$i++;
		$j++;
		if($i > 10){
			&add_risk;
			$wrsk = $krsk;
		}
	}

	$move_flag = 0;
	$drop_flag = 0;
	if($win == 1) {
		$ktotal += 1;
		$kkati += 1;
		$lvhandy = $mlv - $klv + 15;
		if($lvhandy < 0){$lvhandy = 0; }
		if($lvhandy > 30){$lvhandy = 30; }

		$mex = int(($lvhandy * 10) / 15 * ((100 - $klv) / 100)) * $mex / 10;

		if($mex == 0 && $lvhandy > 0){
			$mex = 0.1;
		}

		if($mex > 100){ $mex = 100; }

		$kex = $kex + $mex;
		$gold = $mgold;
		$kgold = $kgold + $gold;
		$comment = "<b>$mnameは倒れた・・。</b><p>";

		if(int(rand(20)) == 1){
			if($kitem < $max_item) {
				&stone_drop;
				$kitem = $u_cnt;
				$dmsg = "<b>$knameは不思議な輝きを放つ石を見つけた！</b><p>";
				$drop_flag = 1;
			} else {
				$dmsg = "<b>$knameは不思議な輝きを放つ石を見つけたが、持ちきれなかった！</b><p>";
			}
		}

		if(int(rand(20)) == 1){
			if($kitem < $max_item) {
				&item_drop;
				$kitem = $u_cnt;
				$dmsg .= "<b>$knameは使えそうなものを拾った！</b><p>";
				$drop_flag = 1;
			} else {
				$dmsg .= "<b>$knameは使えそうなものを見つけたが、持ちきれなかった！</b><p>";
			}
		}

		$move_flag = 2;
	}else{
		$ktotal += 1;
		$mex = int($kex * ((100 - $klv) / 100) + 1) / 10;

		$kex = $kex - $mex;

		if($kd_flg){
			$klp -= 1 + int($wrsk / 100);
		} else {
			$klp -= 1;
		}

		if($klp < 1){
			$comment = "<b>$knameは力尽きた・・。</b><p>";
			$comment .= "<b>$town_name[$karea]の警備隊に救助され、$town_name[$karea]に運ばれた・・。</b><p>";
			if($kgold) { $kgold = int($kgold / 2); }
			else { $kgold = 0; }
			$comment .= "手数料として、<b>$kgold</b>G支払い、";
			$kspot = 0;
			$kpst  = 0;
			$klp = $max_lp;
		} elsif($wrsk > 100 && int(rand(100)) < $wrsk - 100){
			$btl_flg = 1;
			$tmp = 0;
			foreach(0..int($wrsk / 100)) {
				$k_id = int(rand($kitem));
				&item_sell;
				$kitem = $item_count;
				$tmp++;
			}
			$comment = "<b>$knameが起き上がれない隙に、$mnameが何かを持ち去っていった・・。</b><p>";
			$move_flag = 1;
			if($kspot > 0){
				$kpst++;
			}
		} else {
			$comment = "<b>$knameは傷を負ったが、何とか逃げ延びた・・。</b><p>";
			$move_flag = 1;
			if($kspot > 0){
				$kpst++;
			}
		}
	}

	if($k_wdef > 0 && $wrsk > $k_wdef * 25 && int(rand(100)) < $wrsk - $k_wdef * 25){
		$btl_flg = 1;
		$k_id = $k_wid;
		&item_sell;
		$kitem = $item_count;
		$dmsg .= "<b>$k_wnamが使い物にならなくなった！</b><p>";
	}

	if($k_sdef > 0 && $wrsk > $k_sdef * 25 && int(rand(100)) < $wrsk - $k_sdef * 25){
		$btl_flg = 1;
		$k_id = $k_sid;
		&item_sell;
		$kitem = $item_count;
		$dmsg .= "<b>$k_anamが使い物にならなくなった！</b><p>";
	}

	if($kex > ($lv_up)) {
		$comment .= "レベルアップ！<p>";
		$klv += 1;
		$tmphp = $kmaxhp;
		$kmaxhp = int($klv * 7.5 + $kn_3 * 7.5);
		$tmphp = $kmaxhp - $tmphp;
		$comment .= "HPが<b>$tmphp</b>上昇！ <b>3</b>APを入手！";
		$khp = $kmaxhp;
		$kex = 0;
		$kap += 3 + int($klv / 25);
	}

	$khp = $khp_flg;
	if($khp > $kmaxhp) { $khp = $kmaxhp; }
	if($khp <= 0) { $khp = int($kmaxhp / 2); }

	if($kpst < 1){
		if($kspot == 1){
			if($move_flag == 2){
				$mdrop = $t_drop;
				$bgold = int(($t_prize + rand($t_prize)) /2);
				$kgold = $kgold + $bgold;
				if($kitem < $max_item) {
					&item_drop;
					$kitem = $u_cnt;
					$dmsg .= "<b>$knameは宝箱を発見した！$bgold</b>Gとアイテムを入手した！<p>";
				} else {
					$dmsg .= "<b>$knameは宝箱を発見した！$bgold</b>Gを入手した！<p>";
				}

				$get_area=$karea;$get_id="06";$get_cnt="1";
				&get_msg;

				$lastmsg = "$get_msg<p>$town_name[$karea]に帰還しました。";
				$kspot = 0;
				$kpst = 0;
			} else {
				$kpst = 1;
			}
		} elsif($kspot == 2){
			if($move_flag > 0){
				$get_area=$farea;$get_id="01";$get_cnt="0";
				&get_msg;
				$lastmsg = "$town_name[$farea]に到着しました。<p>$get_msg";
				$karea = $farea;
				$kspot = 0;
				$kpst = 0;
			}
		} elsif($kspot == 3){
			if($move_flag > 0){
				$get_area=$rarea;$get_id="01";$get_cnt="0";
				&get_msg;
				$lastmsg = "$town_name[$rarea]に到着しました。<p>$get_msg";
				$karea = $rarea;
				$kspot = 0;
				$kpst = 0;
			}
		}
	} elsif($kpst > $town_move[$karea][$kspot]) {
		if($kspot > 0){
			if($move_flag > 0){
				$lastmsg = "$town_name[$karea]に到着しました。";
				$karea = $karea;
				$kspot = 0;
				$kpst = 0;
			}
		}
	}

	&regist;

	&header;

	my @battle_header;
	my @battle_footer;

	push @battle_header, "$movemsg<br><hr size=0><br>";
	push @battle_header, "$knameは、$mnameに遭遇した！";
	push @battle_header, "$knameは、$area_name[$karea]の支配者、$mnameに遭遇した！" if ($bossflg);
	push @battle_footer, "$comment<b>$mex%</b>の経験値を失った。<p>$dmsg\n";
	push @battle_footer, "$comment<p><b>$mex%</b>の経験値を取得！<b>$gold</b>G入手！<p>$dmsg\n" if($win == 1);
	push @battle_footer, $lastmsg;

	$tt->process(
		'battle.tmpl',
		{
			'battle_header' => \@battle_header,
			'battle_date'   => \@battle_date,
			'battle_footer' => \@battle_footer,
		},
		\my $out,
	);

	print $out;

	print <<"EOM";
<form name=data >
<input type="hidden" name=backid value="0">
<input type="hidden" name=nextid value="1">
<input type="hidden" name=lastid value="$j">
</form>
EOM
	&footer;

	$battle_flag=0;

	exit;
}

#----------------------#
#  リスク積み上げ      #
#----------------------#
sub add_risk {
	$rid = $kid;
	&read_buff;

	$buff_flg = 0;
	$krsk = $rrsk + 1;
	&regist_buff;
}

1;
