use utf8;
#----------------------#
#  モンスターとの戦闘  #
#----------------------#
# 1ターン毎
sub pvp_step_run
{
	##Ｐ１武器防具読み込み
	$k1_par = 0;
	$k1_blc = 0;
	$k1_esc = 0;

	$k1_wnam = "";
	$k1_anam = "";

	$kid = $k1id;$klv = $k1lv;$kn_0 = $k1n_0;$kn_1 = $k1n_1;$kn_2 = $k1n_2;
	$kn_3 = $k1n_3;$kn_4 = $k1n_4;$kn_5 = $k1n_5;$kn_6 = $k1n_6;@ksk=@k1sk;

	#矢弾
	$k_eqp = 5;
	&get_equip;
	$k_bid = $i_id;
	$k_btype = $i_mode;
	$k_batc = int($i_dmg / 2);

	$k1_batc = $i_dmg;
	$k1_btype = $i_mode;
	$k1_bname = $i_name;

	#武器
	$k_eqp = 1;
	&get_equip;
	$atc_skill1 = 0;
	$dmg1 = 0;
	$swg1 = 0;
	$kdef = 0;
	$com1 = "";
	$clit1 = "";
	@efct1 = (0,0,0,0,0,0,0,0);

	&get_attack;
	$k1_bflg = $bflg;

	$elm1 = $i_eelm;
	@kbuf = (1,1,1,0);
	@mbuf = (1,1,1,0);
	$kskl = $avesk;
	$mskl = $k2lv;
	&get_tech;
	@k1buftmp1 = @kbuf;
	@k1buftmp2 = @mbuf;
	$k1efcmsg = $efcmsg;

	$k1_wnam = $i_name;
	$k1_welm = $i_eelm;
	$atc_skillk1 = $atc_skill1;
	$sklmsgk1 = $sklmsg;

	$dmgk1 = $dmg1;
	$swgk1 = $swg1;
	@efctk1 = @efct1;

	$d1hp = 0;
	if($k1_btype eq "60" && $k1buf[3] == 0){
		if(($k1sk[13] / 50 + $k1_batc) > rand(100)){
			if($atc_skillk1 <= 5){
				$k1_welm = 6;
				$dmgk1 += $k1sk[13] / 10;
			}
			$d1hp = int($k1hp_flg * (rand(5) + 1) / 100 + 1);
		}
	}

	$com1 = "<font color=$elmcolor[$k1_welm]>$k1nameは$k1_wnam$sklmsgk1</font>";

	#防具
	$k_eqp = 2;
	&get_equip;
	$kdef = $i_dmg;
	$k1_aelm = $i_eelm;

	$k_eqp = 3;
	&get_equip;
	$kdef += $i_dmg;
	$k_eqp = 4;
	&get_equip;

	$k1def = int($kdef + $k1n_3 / 2);
	$k1red = int($kdef / 2);
	$k1blc = $i_dmg;
	$k1_anam = $i_name;

	##Ｐ２武器防具読み込み
	$k2_par = 0;
	$k2_blc = 0;
	$k2_esc = 0;

	$k2_wnam = "";
	$k2_anam = "";

	$kid = $k2id;$klv = $k2lv;$kn_0 = $k2n_0;$kn_1 = $k2n_1;$kn_2 = $k2n_2;
	$kn_3 = $k2n_3;$kn_4 = $k2n_4;$kn_5 = $k2n_5;$kn_6 = $k2n_6;@ksk=@k2sk;

	#矢弾
	$k_eqp = 5;
	&get_equip;
	$k_bid = $i_id;
	$k_btype = $i_mode;
	$k_batc = int($i_dmg / 2);

	$k2_batc = $i_dmg;
	$k2_btype = $i_mode;
	$k2_bname = $i_name;

	#武器
	$k_eqp = 1;
	&get_equip;
	$atc_skill1 = 0;
	$dmg1 = 0;
	$kdef = 0;
	$swg1 = 0;
	$com2 = "";
	$clit2 = "";
	@efct1 = (0,0,0,0,0,0,0,0);

	&get_attack;
	$k2_bflg = $bflg;

	$elm1 = $i_eelm;
	@kbuf = (1,1,1,0);
	@mbuf = (1,1,1,0);
	$kskl = $avesk;
	$mskl = $k1lv;
	&get_tech;
	@k2buftmp2 = @kbuf;
	@k2buftmp1 = @mbuf;
	$k2efcmsg = $efcmsg;

	$k2_wnam = $i_name;
	$k2_welm = $i_eelm;
	$atc_skillk2 = $atc_skill1;
	$sklmsgk2 = $sklmsg;

	$dmgk2 = $dmg1;
	$swgk2 = $swg1;
	@efctk2 = @efct1;

	$d2hp = 0;
	if($k2_btype eq "60" && $k2buf[3] == 0){
		if(($k2sk[13] / 50 + $k2_batc) > rand(100)){
			if($atc_skillk2 <= 5){
				$k2_welm = 6;
				$dmgk2 += $k2sk[13] / 10;
			}
			$d2hp = int($k2hp_flg * (rand(5) + 1) / 100 + 1);
		}
	}

	$com2 = "<font color=$elmcolor[$k2_welm]>$k2nameは$k2_wnam$sklmsgk2</font>";

	#防具
	$k_eqp = 2;
	&get_equip;
	$kdef = $i_dmg;
	$k2_aelm = $i_eelm;

	$k_eqp = 3;
	&get_equip;
	$kdef += $i_dmg;
	$k_eqp = 4;
	&get_equip;

	$k2def = int($kdef + $k2n_3 / 2);
	$k2red = int($kdef / 2);
	$k2blc = $i_dmg;
	$k2_anam = $i_name;

	$display = "none";
	if($i == 1){$display = "block";}

	$k1atcv = int($k1buf[0] * 100);
	$k1defv = int($k1buf[1] * 100);
	$k1spdv = int($k1buf[2] * 100);
	$k1stpv = "";
	if($k1buf[3] < 0){
		$k1stpv = "行動不能";
	}

	$k2atcv = int($k2buf[0] * 100);
	$k2defv = int($k2buf[1] * 100);
	$k2spdv = int($k2buf[2] * 100);
	$k2stpv = "";
	if($k2buf[3] < 0){
		$k2stpv = "行動不能";
	}

	$k1efv = "<font color=$efcolor[0]>$k1atcv%</font> / <font color=$efcolor[1]>$k1defv%</font> / <font color=$efcolor[2]>$k1spdv%</font> $k1stpv";
	$k2efv = "<font color=$efcolor[0]>$k2atcv%</font> / <font color=$efcolor[1]>$k2defv%</font> / <font color=$efcolor[2]>$k2spdv%</font> $k2stpv";

	$battle_date[$j] .= <<"EOM";
<TR>
	<TD CLASS="b2" COLSPAN="3" ALIGN="center">
	$iターン
	</TD>
</TR>
<TR>
<TD>

<div class="blackboard question">

<TABLE BORDER=0>
<TR>
	<TD CLASS="b1">
	名前
	</TD>
	<TD CLASS="b1">
	HP
	</TD>
	<TD CLASS="b1">
	LV
	</TD>
</TR>
<TR>
	<TD>
	<font color=$elmcolor[$k1_aelm]>$k1name</font>
	</TD>
	<TD>
	$k1hp_flg\/$k1maxhp
	</TD>
	<TD>
	$k1lv
	</TD>
</TR>
<TR>
	<TD CLASS="b1" COLSPAN="3" ALIGN="center">
	効果 攻/防/速
	</TD>
</TR>
<TR>
	<TD COLSPAN="3" ALIGN="center">
	$k1efv
	</TD>
</TR>
</TABLE>

</div>

</TD>
<TD>
<FONT COLOR="#9999DD">VS</FONT>
</TD>
<TD>

<div class="blackboard question">

<TABLE BORDER=0>
<TR>
	<TD CLASS="b1">
	名前
	</TD>
	<TD CLASS="b1">
	HP
	</TD>
	<TD CLASS="b1">
	LV
	</TD>
</TR>
<TR>
	<TD>
	<font color=$elmcolor[$k2_aelm]>$k2name</font>
	</TD>
	<TD>
	$k2hp_flg\/$k2maxhp
	</TD>
	<TD>
	$k2lv
	</TD>
</TR>
<TR>
	<TD CLASS="b1" COLSPAN="3" ALIGN="center">
	効果 攻/防/速
	</TD>
</TR>
<TR>
	<TD COLSPAN="3" ALIGN="center">
	$k2efv
	</TD>
</TR>
</TABLE>

</div>

</TD>
<TR>
<TD COLSPAN="3">
	<div class="blackboard question">
		<p>
EOM

	if($k1_btype eq "60" && $d1hp > 0){
		$battle_date[$j] .= "<font color=$elmcolor[6]>$k1name はHPを$d1hp 消費し、黒いオーラを噴き出した・・</font><p>";
		$k1hp_flg -= $d1hp;
		if($k1hp_flg < 1){
			$k1hp_flg = 1;
		}
		$k1_aelm = 6;
	}

	$d1cut = 0;$d1rtn = 0;
	if($k1_btype eq "61" && $k1buf[3] == 0){
		if(($k1sk[15] / 50 + $k1_batc) > rand(100)){
			$battle_date[$j] .= "$k1name は相手を見据えて身構えた！<p>";
			$d1cut = 1;
		}
	}

	$d1up1 = 0;
	if($k1_btype eq "62" && $k1buf[3] == 0 ){
		if(($k1sk[15] / 50 + $k1_batc) > rand(100)){
			$d1up1 = int(rand($k1sk[15] / 100) + 1);
			$battle_date[$j] .= "$k1name は印を結んだ・・・影分身が$d1up1 体現れた！<p>";
		}
	}

	if($k2_btype eq "60" && $d2hp > 0){
		$battle_date[$j] .= "<font color=$elmcolor[6]>$k2name はHPを$d2hp 消費し、黒いオーラを噴き出した・・</font><p>";
		$k2hp_flg -= $d2hp;
		if($k2hp_flg < 1){
			$k2hp_flg = 1;
		}
		$k2_aelm = 6;
	}

	$d2cut = 0;$d2rtn = 0;
	if($k2_btype eq "61" && $k2buf[3] == 0){
		if(($k2sk[15] / 50 + $k2_batc) > rand(100)){
			$battle_date[$j] .= "$k2name は相手を見据えて身構えた！<p>";
			$d2cut = 1;
		}
	}

	$d2up1 = 0;
	if($k2_btype eq "62" && $k2buf[3] == 0 ){
		if(($k2sk[15] / 50 + $k2_batc) > rand(100)){
			$d2up1 = int(rand($k2sk[15] / 100) + 1);
			$battle_date[$j] .= "$k2name は印を結んだ・・・影分身が$d2up1 体現れた！<p>";
		}
	}

	$fst_flg = int($k1n_5 * $k1buf[2] - $k2n_5 * $k2buf[2] + rand(30));
	if($d1cut == 1 && $d2cut == 0){
		$fst_flg = 0;
	}elsif($d1cut == 0 && $d2cut == 1){
		$fst_flg = 30;
	}elsif($efctk1[0] && !$efctk2[0]){
		$fst_flg = 30;
		$com1 = "$k1name の先制攻撃！<br>$com1";
	}elsif(!$efctk1[0] && $efctk2[0]){
		$fst_flg = 0;
		$com2 = "$k2name の先制攻撃！<br>$com2";
	}
	$turnflg = 0;
	foreach(1..2) {
		if(($fst_flg > 15 && $turnflg == 0) ||($fst_flg <= 15 && $turnflg == 1)){
			if($k1buf[3] < 0 ){
				$dmgk1 = 0;
				$com1 = "$k1name は動けない！<br>";
				$k1buf[3]+= 1;
			} else {
				##Ｐ１ダメージ・命中判定
				if($efctk1[1]){
					$dmgk1 = int(($dmgk1 * $k1buf[0] - $k2def * $k2buf[1] * (1 - $efctk1[1] / 4)) * (100 - $k2red) / 100);
				} else {
					$dmgk1 = int(($dmgk1 * $k1buf[0] - $k2def * $k2buf[1]) * (100 - $k2red) / 100);
				}
				if($efctk1[2]){
					$swgk1 = $swgk1 * $efctk1[2];
				}

				#属性計算
				$aelm = $k1_welm;
				$delm = $k2_aelm;
				&elm_judge;
				$k1efe = $eefe;
				if($k1efe > 100){
					$clit1 = "<br><b><font color=$elmcolor[$k1_welm]>効果は抜群だ！</font></b><br>";
					$efctk1[7] += 1;
				}elsif($k1efe < 100){
					$clit1 = "<br><b><font color=$elmcolor[$k1_welm]>効果は今ひとつのようだ・・</font></b><br>";
					$efctk1[7] -= 1;
				}

				$swgk1 = int(($swgk1 + rand($swgk1)) / 2 + 1);
				$dmgk1 = int((($dmgk1 + rand($dmgk1)) / 3) * $k1efe /100);
				if($dmgk1 < 0){$dmgk1 = 0}

				if($k1_btype eq "61" && $d1cut == 2){
					$com1 = "相手の勢いを利用してカウンターを繰り出す・・<br>$com1";
					$dmgk1 += int($d1rtn * ($k1sk[15] + 1000) / 3000);
				}

				if($k1_btype eq "62" && $d1up1 > 0 && $atc_skillk1 <= 5){
					$com1 .= "影分身が$d1up1 体攻撃に参加した！<br>";
					$swgk1 += $d1up1;
				}

				$dmgcnt = 5;$tmpdmg = $dmgk1;$hitdmg=0;
				$swgcnt = 0;$k2blccnt = 0;$k2parcnt = 0;$k2esccnt = 0;$d2upd=0;
				foreach (1 .. $swgk1) {
					if(($par_efc[$atc_skillk2] == 2 && $par_efc[$atc_skillk1] == 2 ) ||
						($par_efc[$atc_skillk2] < 2 && $par_efc[$atc_skillk1] < 2 )){
						$k2_par =int(10 + $k2sk[$atc_skillk2] / 40 - $k1sk[$atc_skillk1] / 40 - rand(100));
					}
					if($k2blc > 0){
						$tmpblc = $k2blc + $k2n_4 / 10 + $k2sk[21] / 40;
						if($k2blc * 2 < $tmpblc){$tmpblc = $k2blc * 2;}
						if($k2_btype eq "61" && $d2cut == 1){
							$tmpblc += $k2sk[14] / 100;
						}
						$k2_blc =int($tmpblc - $k1sk[$atc_skillk1] / 40 - rand(100));
					}
					$k2_esc =(5 + $k2n_5 * $k2buf[2] / 2 + $k2sk[$atc_skillk2] / 20 - $k1sk[$atc_skillk1] / 20 - rand(100));

					if($k2_blc > 0 && $k2_btype eq "61" && $d2cut == 1 && ($atc_skillk2 <= 2 || $atc_skillk2 == 5)){
						$d2cut = 2;
						$d2rtn = $dmgk1;
						last;
					} elsif($d2up1 > 0){
						$d2upd++;
						$d2up1 -= $d2up1;
					} elsif($k2_par > 0){
						$k2parcnt++;
					} elsif($k2_blc > 0){
						$k2blccnt++;
					} elsif($k2_esc > 0){
						$k2esccnt++;
					} else {
						$swgcnt++;
					}

					$hitdmg = int($tmpdmg / $dmgcnt);
					if($hitdmg < 1){$hitdmg = 1;}
					$dmgk1 += $hitdmg;
					$dmgcnt++;
					if($dmgcnt > 20){$dmgcnt = 20;}
				}
				$dmgk1 = int($dmgk1 * $swgcnt / $swgk1);
				$swgk1 = $swgcnt;
				if($d2upd > 0){
					$com1 .= "影分身が$d2upd 人身代わりになった！<br>";
				}
				if($k2parcnt > 0){
					$com1 .= "$k2name は$k2parcnt 回$par_msg[$atc_skillk2][$par_efc[$atc_skillk1]]<br>";
				}
				if($k2blccnt > 0) {
					$com1 .= "$k2name は$k2blccnt 回$k2_anam で防いだ！<br>";
				}
				if($k2esccnt> 0) {
					$com1 .= "$k2name は$k2esccnt 回かわした！<br>";
				}

				$cutmsg1 = "";
				if($d2cut == 2 && $turnflg == 0){
					$cutmsg1 = "$k2name は$k2_anam で弾くと同時に踏み込んだ！<br>";
				} elsif($d2cut == 2){
					$cutmsg1 = "$k2name は$k2_anam で弾き飛ばした！<br>";
				}
				if($dmgk1 > 0){
					$k1buf[0] = $k1buf[0] * $k1buftmp1[0];
					if($k1buf[0] < 0.5){$k1buf[0] = 0.5;}
					if($k1buf[0] > 1.5){$k1buf[0] = 1.5;}

					$k1buf[1] = $k1buf[1] * $k1buftmp1[1];
					if($k1buf[1] < 0.5){$k1buf[1] = 0.5;}
					if($k1buf[1] > 1.5){$k1buf[1] = 1.5;}

					$k1buf[2] = $k1buf[2] * $k1buftmp1[2];
					if($k1buf[2] < 0.5){$k1buf[2] = 0.5;}
					if($k1buf[2] > 1.5){$k1buf[2] = 1.5;}

					$k1buf[3] += $k1buftmp1[3];

					$k2buf[0] = $k2buf[0] * $k1buftmp2[0];
					if($k2buf[0] < 0.5){$k2buf[0] = 0.5;}
					if($k2buf[0] > 1.5){$k2buf[0] = 1.5;}

					$k2buf[1] = $k2buf[1] * $k1buftmp2[1];
					if($k2buf[1] < 0.5){$k2buf[1] = 0.5;}
					if($k2buf[1] > 1.5){$k2buf[1] = 1.5;}

					$k2buf[2] = $k2buf[2] * $k1buftmp2[2];
					if($k2buf[2] < 0.5){$k2buf[2] = 0.5;}
					if($k2buf[2] > 1.5){$k2buf[2] = 1.5;}

					$k2buf[3] += $k1buftmp2[3];
				}

				if($efctk1[7] * 5 + $k1n_4 / 16 + $k1sk[$atc_skillk1] / 80 - $k2n_4 / 16 - $k2sk[$atc_skillk2] / 80 > int(rand(100)) && $dmgk1 > 0 && $efctk1[7] > 0){
					$clit1 .= "<br><b class=\"clit\">$k2name $death_msg[$atc_skillk1][$k1_welm]</b><br>";
					$k2d_flg = 1;
					$bonus1 += 10;
				}

			}

			if($dmgk1 > 0){
				$battle_date[$j] .= "$com1 そして<b>$swgk1</b>回 ヒットし、 $k2name に <font class=\"dmg\"><b>$dmgk1</b></font> のダメージ！$k1efcmsg$clit1<p>";
				$bonus1 += 1;
				if($k1_bflg > 0){
					$battle_date[$j] .= "$k1name は素早く次の$k1_bname を準備した！<p>";
				}
			} else {
				$battle_date[$j] .= "$com1<p>";
			}
			if($k2buf[3] == 0){
				$battle_date[$j] .= $cutmsg1;
			}
			$k2hp_flg = $k2hp_flg - $dmgk1;
			if($k2hp_flg <= 0 || $k2d_flg) { $win = 1; last; }

		} else {
			if($k2buf[3] < 0 ){
				$dmgk2 = 0;
				$com2 = "$k2name は動けない！<br>";
				$k2buf[3]+= 1;
			} else {
				##Ｐ２ダメージ・命中判定
				if($efctk2[1]){
					$dmgk2 = int(($dmgk2 * $k2buf[0] - $k1def * $k1buf[1] * (1 - $efctk2[1] / 4)) * (100 - $k1red) / 100);
				} else {
					$dmgk2 = int(($dmgk2 * $k2buf[0] - $k1def * $k1buf[1]) * (100 - $k1red) / 100);
				}
				if($efctk2[2]){
					$swgk2 = $swgk2 * $efctk2[2];
				}

				#属性計算
				$aelm = $k2_welm;
				$delm = $k1_aelm;
				&elm_judge;
				$k2efe = $eefe;
				if($k2efe > 100){
					$clit2 = "<br><b><font color=$elmcolor[$k2_welm]>効果は抜群だ！</font></b><br>";
					$efctk2[7] += 1;
				}elsif($k2efe < 100){
					$clit2 = "<br><b><font color=$elmcolor[$k2_welm]>効果は今ひとつのようだ・・</font></b><br>";
					$efctk2[7] -= 1;
				}

				$swgk2 = int(($swgk2 + rand($swgk2)) / 2 + 1);
				$dmgk2 = int((($dmgk2 + rand($dmgk2)) / 3) * $k2efe /100);
				if($dmgk2 < 0){$dmgk2 = 0}

				if($k2_btype eq "61" && $d2cut == 2){
					$com2 = "相手の勢いを利用してカウンターを繰り出す・・<br>$com2";
					$dmgk2 += int($d2rtn * ($k2sk[15] + 1000) / 3000);
				}

				if($k2_btype eq "62" && $d2up1 > 0 && $atc_skillk2 <= 5){
					$com2 .= "影分身が$d2up1 体攻撃に参加した！<br>";
					$swgk2 += $d2up1;
				}

				$dmgcnt = 5;$tmpdmg = $dmgk2;$hitdmg=0;
				$swgcnt = 0;$k1blccnt = 0;$k1parcnt = 0;$k1esccnt = 0;$d1upd=0;
				foreach (1 .. $swgk2) {
					if(($par_efc[$atc_skillk1] == 2 && $par_efc[$atc_skillk2] == 2 ) ||
						($par_efc[$atc_skillk1] < 2 && $par_efc[$atc_skillk2] < 2 )){
						$k1_par =int(10 + $k1sk[$atc_skillk1] / 40 - $k2sk[$atc_skillk2] / 40 - rand(100));
					}
					if($k1blc > 0){
						$tmpblc = $k1blc + $k1n_4 / 10 + $k1sk[21] / 40;
						if($k1blc * 2 < $tmpblc){$tmpblc = $k1blc * 2;}
						if($k1_btype eq "61" && $d1cut == 1){
							$tmpblc += $k1sk[14] / 100;
						}
						$k1_blc =int($tmpblc - $k2sk[$atc_skillk2] / 40 - rand(100));
					}
					$k1_esc =(5 + $k1n_5 * $k1buf[2] / 2 + $k1sk[$atc_skillk1] / 20 - $k2sk[$atc_skillk2] / 20 - rand(100));

					if($k1_blc > 0 && $k1_btype eq "61" && $d1cut == 1 && ($atc_skillk1 <= 2 || $atc_skillk1 == 5)){
						$d1cut = 2;
						$d1rtn = $dmgk2;
						last;
					} elsif($d1up1 > 0){
						$d1upd++;
						$d1up1 -= 1;
					} elsif($k1_par > 0){
						$k1parcnt++;
					} elsif($k1_blc > 0){
						$k1blccnt++;
					} elsif($k1_esc > 0){
						$k1esccnt++;
					} else {
						$swgcnt++;
					}

					$hitdmg = int($tmpdmg / $dmgcnt);
					if($hitdmg < 1){$hitdmg = 1;}
					$dmgk2 += $hitdmg;
					$dmgcnt++;
					if($dmgcnt > 20){$dmgcnt = 20;}
				}
				$dmgk2 = int($dmgk2 * $swgcnt / $swgk2);
				$swgk2 = $swgcnt;

				if($d1upd > 0){
					$com2 .= "影分身が$d1upd 人身代わりになった！<br>";
				}
				if($k1parcnt > 0){
					$com2 .= "$k1name は$k1parcnt 回$par_msg[$atc_skillk1][$par_efc[$atc_skillk2]]<br>";
				}
				if($k1blccnt > 0) {
					$com2 .= "$k1name は$k1blccnt 回$k1_anam で防いだ！<br>";
				}
				if($k1esccnt> 0) {
					$com2 .= "$k1name は$k1esccnt 回かわした！<br>";
				}

				$cutmsg2 = "";
				if($d1cut == 2 && $turnflg == 0){
					$cutmsg2 = "$k1name は$k1_anam で弾くと同時に踏み込んだ！<br>";
				} elsif($d1cut == 2){
					$cutmsg2 = "$k1name は$k1_anam で弾き飛ばした！<br>";
				}

				if($dmgk2 > 0){
					$k1buf[0] = $k1buf[0] * $k2buftmp1[0];
					if($k1buf[0] < 0.5){$k1buf[0] = 0.5;}
					if($k1buf[0] > 1.5){$k1buf[0] = 1.5;}

					$k1buf[1] = $k1buf[1] * $k2buftmp1[1];
					if($k1buf[1] < 0.5){$k1buf[1] = 0.5;}
					if($k1buf[1] > 1.5){$k1buf[1] = 1.5;}

					$k1buf[2] = $k1buf[2] * $k2buftmp1[2];
					if($k1buf[2] < 0.5){$k1buf[2] = 0.5;}
					if($k1buf[2] > 1.5){$k1buf[2] = 1.5;}

					$k1buf[3] += $k2buftmp1[3];

					$k2buf[0] = $k2buf[0] * $k2buftmp2[0];
					if($k2buf[0] < 0.5){$k2buf[0] = 0.5;}
					if($k2buf[0] > 1.5){$k2buf[0] = 1.5;}

					$k2buf[1] = $k2buf[1] * $k2buftmp2[1];
					if($k2buf[1] < 0.5){$k2buf[1] = 0.5;}
					if($k2buf[1] > 1.5){$k2buf[1] = 1.5;}

					$k2buf[2] = $k2buf[2] * $k2buftmp2[2];
					if($k2buf[2] < 0.5){$k2buf[2] = 0.5;}
					if($k2buf[2] > 1.5){$k2buf[2] = 1.5;}

					$k2buf[3] += $k2buftmp2[3];

				}

				if($efct2[7] * 5 + $k2n_4 / 16 + $k2sk[$atc_skillk2] / 80 - $k1n_4 / 16 - $k1sk[$atc_skillk1] / 80 > int(rand(100)) && $dmgk2 > 0 && $efctk2[7] > 0){
					$clit2 .= "<br><b class=\"clit\">$k1name$death_msg[$atc_skillk2][$k2_welm]</b><br>";
					$k1d_flg = 1;
					$bonus2 += 10;
				}
			}

			if($dmgk2 > 0){
				$battle_date[$j] .= "$com2 そして<b>$swgk2</b>回 ヒットし、 $k1name に <font class=\"dmg\"><b>$dmgk2</b></font> のダメージ！$k2efcmsg$clit2<p>";
				$bonus2 += 1;

				if($k2_bflg > 0){
					$battle_date[$j] .= "$k2name は素早く次の$k2_bname を準備した！<p>";
				}
			} else {
				$battle_date[$j] .= "$com2<p>";
			}
			if($k1buf[3] == 0){
				$battle_date[$j] .= $cutmsg2;
			}
			$k1hp_flg = $k1hp_flg - $dmgk2;
			if($k1hp_flg <= 0 || $k1d_flg) { $win = 2; last; }

		}
		$turnflg = 1;
	}

	$battle_date[$j] .= "</p>\n</div>\n";

	$battle_date[$j] = <<"EOM";
<DIV id="sel$i">
<TABLE BORDER=0>
$battle_date[$j]
	</TD>
</TR>
</TABLE>
</DIV>
EOM

	if($win > 0)
	{
		return 1;
	}

	return 0;
}

sub pvp_initialize
{
	##１Ｐデータ
	@battle_k1 = &load_ini($chara_file);

	$hit=0;
	foreach(@battle_k1){
		($k1id,$k1pass,$k1name,$k1sex,$k1chara,$k1n_0,$k1n_1,$k1n_2,$k1n_3,$k1n_4,$k1n_5,$k1n_6,$k1hp,$k1maxhp,$k1ex,$k1lv,$k1ap,$k1gold,$k1lp,$k1total,$k1kati,$k1host,$k1date,$k1area,$k1spot,$k1pst,$k1item) = split(/<>/);
		if($in{'k1id'} eq "$k1id" and $in{'pass'} eq "$k1pass") {
			$hit=1;
			last;
		}
	}

	if(!$hit) { &error("入力されたIDは登録されていません。又はパスワードが違います。"); }

	$kid = $k1id;
	&skill_load;
	@k1sk = @ksk;

	# if($k1spot != 0 || $k1pst != 0) { &error("不正なパラメータです。"); }

	$k1hp_flg = $k1maxhp;
	$k1d_flg = 0;
	$bonus1 = 0;

	##２Ｐデータ
	@battle_k2 = &load_ini($chara_file);

	foreach(@battle_k2){
		($k2id,$k2pass,$k2name,$k2sex,$k2chara,$k2n_0,$k2n_1,$k2n_2,$k2n_3,$k2n_4,$k2n_5,$k2n_6,$k2hp,$k2maxhp,$k2ex,$k2lv,$k2ap,$k2gold,$k2lp,$k2total,$k2kati,$k2host,$k2date,$k2area,$k2spot,$k2pst,$k2item) = split(/<>/);
		if($in{'k2id'} eq "$k2id") { last; }
	}

	if($in{'k1id'} eq $in{'k2id'}) { &error("不正なパラメータです。"); }

	$kid = $k2id;
	&skill_load;
	@k2sk = @ksk;

	$k2hp_flg = $k2maxhp;
	$k2d_flg = 0;
	$bonus2 = 0;

	$rid = $k1id;
	&read_battle;

	if ($kwin != 0 && $ktotal != 0)
	{
		$k1odd = $kwin / $ktotal;
	}
	else
	{
		$k1odd = 0;
	}

	$k1rank = $krank;

	$rid = $k2id;
	&read_battle;

	if ($kwin != 0 && $ktotal != 0)
	{
		$k2odd = $kwin / $ktotal;
	}
	else
	{
		$k2odd = 0;
	}

	$k2rank = $krank;

	@k1buf = (1,1,1,0);
	@k2buf = (1,1,1,0);

	$i=1;$j=0;@battle_date=();

	# push @battle_header, "$movemsg<br>";
	@battle_header = ();
	@battle_footer = ();
	push @battle_header, "$k1name は、$k2name に遭遇した！";
}

sub pvp_finalize
{
	&pvp_stage_save;

	my $battle = File::Spec->catfile($FindBin::Bin, "save", "battle", $k1id. "_____". $k2id. ".pvp.yaml");
	my $file = Mojo::File->new($battle);
	my $move = File::Spec->catfile($FindBin::Bin, "save", "archive", &gettimeofday. ".pvp.yaml");
	$file->move_to($move);
}

sub pvp_stage_save
{
	my $data = {
		"ステージデータ" => {
			k1hp_flg => $k1hp_flg,
			k1d_flg  => $k1d_flg,
			bonus1   => $bonus1,
			k2hp_flg => $k2hp_flg,
			k2d_flg  => $k2d_flg,
			bonus2   => $bonus2,
			"ターン"   => $turn,
			header => \@battle_header,
			footer => \@battle_footer,
			"ログ"    => \@battle_date,
			"フラグ"   => $win,
			i       => $i,
			j       => $j,
		},
		"プレイヤー1" => {
			id     => $k1id,
			"パスワード"  => $k1pass,
			"名前"     => $k1name,
			"性別"     => $k1sex,
			"画像"     => $k1chara,
			"力"      => $k1n_0,
			"賢さ"     => $k1n_1,
			"信仰心"    => $k1n_2,
			"体力"     => $k1n_3,
			"器用さ"    => $k1n_4,
			"素早さ"    => $k1n_5,
			"魅力"     => $k1n_6,
			HP     => $k1hp,
			"最大HP"   => $k1maxhp,
			"経験値"    => $k1ex,
			"レベル"    => $k1lv,
			"残りAP"   => $k1ap,
			"所持金"    => $k1gold,
			LP     => $k1lp,
			"戦闘数"    => $k1total,
			"勝利数"    => $k1kati,
			"ホスト"    => $k1host,
			"最終アクセス" => $k1date,
			"エリア"    => $k1area,
			"スポット"   => $k1spot,
			"距離"     => $k1pst,
			"アイテム"   => $k1item,
			"バフ"     => \@k1buff,
		},
		"プレイヤー2" => {
			id     => $k2id,
			"パスワード"  => $k2pass,
			"名前"     => $k2name,
			"性別"     => $k2sex,
			"画像"     => $k2chara,
			"力"      => $k2n_0,
			"賢さ"     => $k2n_1,
			"信仰心"    => $k2n_2,
			"体力"     => $k2n_3,
			"器用さ"    => $k2n_4,
			"素早さ"    => $k2n_5,
			"魅力"     => $k2n_6,
			HP     => $k2hp,
			"最大HP"   => $k2maxhp,
			"経験値"    => $k2ex,
			"レベル"    => $k2lv,
			"残りAP"   => $k2ap,
			"所持金"    => $k2gold,
			LP     => $k2lp,
			"戦闘数"    => $k2total,
			"勝利数"    => $k2kati,
			"ホスト"    => $k2host,
			"最終アクセス" => $k2date,
			"エリア"    => $k2area,
			"スポット"   => $k2spot,
			"距離"     => $k2pst,
			"アイテム"   => $k2item,
			"バフ"     => \@k2buff,
		},
	};

	my $battle = File::Spec->catfile($FindBin::Bin, "save", "battle", $k1id. "_____". $k2id. ".pvp.yaml");
	my $file = Mojo::File->new($battle);
	my $newData = {};

	for my $key1 (keys %$data)
	{
		my $newKey1 = $key1;
		for my $key2 (keys %{ $data->{$key1} })
		{
			my $newKey2 = Encode::encode_utf8($key2);
			$newData->{$newKey1} ||= {};
			if ($newKey2 eq "名前")
			{
				# $data->{$key1}->{$key2} = Encode::encode_utf8($data->{$key1}->{$key2});
			}
			elsif ($newKey2 eq "ログ" || $newKey2 eq "header" || $newKey2 eq "footer")
			{
				my $log = $data->{$key1}->{$key2};

				for my $no (0 .. $#$log)
				{
					my @strings = split(//, $log->[$no]);
					$strings[$_] = utf8::is_utf8($strings[$_]) ? Encode::encode_utf8($strings[$_]) : $strings[$_] for 0 .. $#string;
					# $log->[$no] = join("", @strings);

					# warn $log->[$no];
				}
			}
			$newData->{$key1}->{$key2} = $data->{$key1}->{$key2};
		}
	}

	my $str =  YAML::XS::Dump($newData);

	$file->spurt($str);
}

sub pvp_stage_apply
{
	my $data = shift;

	$i = $data->{"ステージデータ"}->{i};
	$j = $data->{"ステージデータ"}->{j};
	$win = $data->{"ステージデータ"}->{"フラグ"};
	@battle_date = @{$data->{"ステージデータ"}->{"ログ"}};
	@battle_header = @{$data->{"ステージデータ"}->{header}};
	@battle_fotter = @{$data->{"ステージデータ"}->{footer}};

	$turn = $data->{"ステージデータ"}->{"ターン"};
	$k1hp_flg = $data->{"ステージデータ"}->{k1hp_flg};
	$k1d_flg = $data->{"ステージデータ"}->{k1d_flg};
	$k2hp_flg = $data->{"ステージデータ"}->{k2hp_flg};
	$k2d_flg = $data->{"ステージデータ"}->{k2d_flg};

	$k1id = $data->{"プレイヤー1"}->{id};
	$k1pass = $data->{"プレイヤー1"}->{"パスワード"};
	$k1name = $data->{"プレイヤー1"}->{"名前"};
	$k1sex = $data->{"プレイヤー1"}->{"性別"};
	$k1chara = $data->{"プレイヤー1"}->{"画像"};
	$k1n_0 = $data->{"プレイヤー1"}->{"力"};
	$k1n_1 = $data->{"プレイヤー1"}->{"賢さ"};
	$k1n_2 = $data->{"プレイヤー1"}->{"信仰心"};
	$k1n_3 = $data->{"プレイヤー1"}->{"体力"};
	$k1n_4 = $data->{"プレイヤー1"}->{"器用さ"};
	$k1n_5 = $data->{"プレイヤー1"}->{"素早さ"};
	$k1n_6 = $data->{"プレイヤー1"}->{"魅力"};
	$k1hp = $data->{"プレイヤー1"}->{HP};
	$k1maxhp = $data->{"プレイヤー1"}->{"最大HP"};
	$k1ex = $data->{"プレイヤー1"}->{"経験値"};
	$k1lv = $data->{"プレイヤー1"}->{"レベル"};
	$k1ap = $data->{"プレイヤー1"}->{"残りAP"};
	$k1gold = $data->{"プレイヤー1"}->{"所持金"};
	$k1lp = $data->{"プレイヤー1"}->{LP};
	$k1total = $data->{"プレイヤー1"}->{"戦闘数"};
	$k1kati = $data->{"プレイヤー1"}->{"勝利数"};
	$k1host = $data->{"プレイヤー1"}->{"ホスト"};
	$k1date = $data->{"プレイヤー1"}->{"最終アクセス"};
	$k1area = $data->{"プレイヤー1"}->{"エリア"};
	$k1spot = $data->{"プレイヤー1"}->{"スポット"};
	$k1pst = $data->{"プレイヤー1"}->{"距離"};
	$k1item = $data->{"プレイヤー1"}->{"アイテム"};
	@k1buff = @{$data->{"プレイヤー1"}->{"バフ"}};

	$k2id = $data->{"プレイヤー2"}->{id};
	$k2pass = $data->{"プレイヤー2"}->{"パスワード"};
	$k2name = $data->{"プレイヤー2"}->{"名前"};
	$k2sex = $data->{"プレイヤー2"}->{"性別"};
	$k2chara = $data->{"プレイヤー2"}->{"画像"};
	$k2n_0 = $data->{"プレイヤー2"}->{"力"};
	$k2n_1 = $data->{"プレイヤー2"}->{"賢さ"};
	$k2n_2 = $data->{"プレイヤー2"}->{"信仰心"};
	$k2n_3 = $data->{"プレイヤー2"}->{"体力"};
	$k2n_4 = $data->{"プレイヤー2"}->{"器用さ"};
	$k2n_5 = $data->{"プレイヤー2"}->{"素早さ"};
	$k2n_6 = $data->{"プレイヤー2"}->{"魅力"};
	$k2hp = $data->{"プレイヤー2"}->{HP};
	$k2maxhp = $data->{"プレイヤー2"}->{"最大HP"};
	$k2ex = $data->{"プレイヤー2"}->{"経験値"};
	$k2lv = $data->{"プレイヤー2"}->{"レベル"};
	$k2ap = $data->{"プレイヤー2"}->{"残りAP"};
	$k2gold = $data->{"プレイヤー2"}->{"所持金"};
	$k2lp = $data->{"プレイヤー2"}->{LP};
	$k2total = $data->{"プレイヤー2"}->{"戦闘数"};
	$k2kati = $data->{"プレイヤー2"}->{"勝利数"};
	$k2host = $data->{"プレイヤー2"}->{"ホスト"};
	$k2date = $data->{"プレイヤー2"}->{"最終アクセス"};
	$k2area = $data->{"プレイヤー2"}->{"エリア"};
	$k2spot = $data->{"プレイヤー2"}->{"スポット"};
	$k2pst = $data->{"プレイヤー2"}->{"距離"};
	$k2item = $data->{"プレイヤー2"}->{"アイテム"};
	@k2buff = @{$data->{"プレイヤー2"}->{"バフ"}};
}

sub pvp_stage_load
{
	my $battle = &get_pvp_file_path;
	my $file = Mojo::File->new($battle);
	my $str = $file->slurp;
	my $data = YAML::XS::Load($str);

	my $newData = {};

	for my $key1 (keys %$data)
	{
		$newData->{$key1} ||= {};

		for my $key2 (keys %{ $data->{$key1} })
		{
			if ($key2 eq "名前")
			{
				# $data->{$key1}->{$key2} = Encode::encode_utf8($data->{$key1}->{$key2});
			}
			elsif ($key2 eq "ログ" || $key2 eq "header" || $key2 eq "footer")
			{
				my $log = $data->{$key1}->{$key2};
				# $log->[$_] = Encode::encode_utf8($log->[$_]) for 0 .. $#$log;
			}
			$newData->{$key1}->{$key2} = $data->{$key1}->{$key2};
		}
	}

	$data = $newData;

	return $data;
}

sub get_pvp_file_path
{
	my $dir = Mojo::File->new(File::Spec->catdir($FindBin::Bin, "save", "battle"));
	my $collection = $dir->list_tree;

	for my $file (@$collection)
	{
		if ($file->basename !~ /\.pvp\.yaml$/)
		{
			next;
		}
		if ($file->basename =~ /$kid/)
		{
			return $file->realpath;
		}
	}
}

sub is_continue_pvp
{
	# my $battle = File::Spec->catfile($FindBin::Bin, "save", "battle", $k1id. "_____". $k2id. ".pvp.yaml");
	my $dir = Mojo::File->new(File::Spec->catdir($FindBin::Bin, "save", "battle"));
	my $collection = $dir->list_tree;

	for my $file (@$collection)
	{
		# warn $file->basename;

		if ($file->basename !~ /\.pvp\.yaml$/)
		{
			next;
		}
		if ($file->basename =~ /$kid/)
		{
			return 1;
		}
	}

    return 0;
}

sub pvp
{
	$battle_flag=1;

	&save_dat_append;

	# 途中データ確認
	my $data;
	if (&is_continue_pvp)
	{
		$data = &pvp_stage_load;
		&pvp_stage_apply($data);
	}
	else
	{
		&pvp_initialize;
		&pvp_stage_save;
		&display_pvp_battle;
		exit;
	}

	my $res = &pvp_step_run; # 1...終了,0...継続

	if ($res == 0)
	{
		$turn++;
		$i++;
		$j++;
		$battle_flag=0;
		&pvp_stage_save;
		&display_pvp_battle;
		exit;
	}

	if($win == 1) {
		$comment = "<b>$k2name に勝利した！</b><p>";
		$award1 = 1;
		$award2 = 0;
		$win1   = 1;
		$win2   = 0;
	}else{
		$comment = "<b>$k1name は敗北した・・</b><p>";
		$award1 = 0;
		$award2 = 1;
		$win1   = 0;
		$win2   = 1;
	}

	&calc_pvp_handicap;
	&calc_pvp_bonus;

	# &regist;
	&pvp_finalize;
	&display_pvp_battle;

	$battle_flag=0;

	exit;
}

sub calc_pvp_bonus
{
	#ボーナス・賞金登録
	$kid = $k2id;
	$kname = $k2name;
	$kpoint = int($award2 * $k1lv * 1 * $bonus2 / 100 * $tech2 * $odds2);
	if($kpoint > $k2lv){
		$kpoint = $k2lv;
	} elsif($kpoint < 1 && $win2 == 1) {
		$kpoint = 1;
	}
}

sub calc_pvp_handicap
{
	#ハンディキャップ計算（10～200)
	$handy1 = $k2lv -$k1lv + 10;
	if($handy1 > 20){
		$handy1 = 20;
	} elsif($handy1 < 1) {
		$handy1 = 1;
	}

	$bonus1 += $handy1 * 10;

	if($k1sk[$atc_skillk1] == 0){
		$tech1 = 0;
	} else {
		$tech1 = $k2sk[$atc_skillk2]/$k1sk[$atc_skillk1];
		if($tech1 > 2){$tech1 = 2;}
	}

	if($k1odd == 0){
		$odds1 = 0;
	} else {
		$odds1 = $k2odd /$k1odd;
		if($odds1 > 2){$odds1 = 2;}
	}

	$handy2 = $k1lv -$k2lv + 10;
	if($handy2 > 20){
		$handy2 = 20;
	} elsif($handy2 < 1) {
		$handy2 = 1;
	}
	$bonus2 += $handy2 * 10;

	if($k2sk[$atc_skillk2] == 0){
		$tech2 = 0;
	} else {
		$tech2 = $k1sk[$atc_skillk1]/$k2sk[$atc_skillk2];
		if($tech2 > 2){$tech2 = 2;}
	}

	if($k2odd == 0){
		$odds2 = 0;
	} else {
		$odds2 = $k1odd /$k2odd;
		if($odds2 > 2){$odds2 = 2;}
	}
}

sub display_pvp_battle
{
	&header;

	# $battle_header[$_] = Encode::decode_utf8($battle_header[$_]) for 0 .. $#battle_header;
	# $battle_footer[$_] = Encode::decode_utf8($battle_footer[$_]) for 0 .. $#battle_footer;

	$tt->process(
		'battle.tmpl',
		{
			'battle_header' => \@battle_header,
			'battle_date'   => \@battle_date,
			'battle_footer' => \@battle_footer,
			j               => $j,
			is_continue     => &is_continue_pvp ? 1 : 0,
			is_finished     => $win == 0 ? 0 : 1,
			kid             => $kid,
			kpass           => $kpass,
			sel             => $in{sel} || -1,
			spot            => "PVP",
			mode            => "pvp",
			k1id             => $k1id,
			k2id             => $k2id,
		},
		\my $out,
		binmode => ':encoding(utf8)'
	);

	print $out;

	&footer;
}

1;
