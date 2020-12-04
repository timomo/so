use utf8;
#----------------------#
#  モンスターとの戦闘  #
#----------------------#
# 1ターン毎
sub monster_step_run2
{
	my $data = shift;

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

	$com1 .= "<font color=$elmcolor[$k_welm]>$kname は$k_wnam $sklmsg</font>";

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

	$kefv = "<font color=$efcolor[0]>$katcv %</font> / <font color=$efcolor[1]>$kdefv %</font> / <font color=$efcolor[2]>$kspdv %</font> $kstpv";
	$mefv = "<font color=$efcolor[0]>$matcv %</font> / <font color=$efcolor[1]>$mdefv %</font> / <font color=$efcolor[2]>$mspdv %</font> $mstpv";

	my $party1 = &display_monster_player_status($data->{"プレイヤー:1"});
	my $party2 = &display_monster_player_status($data->{"プレイヤー:2"});
	my $party3 = &display_monster_player_status($data->{"プレイヤー:3"});
	my $party4 = &display_monster_player_status($data->{"プレイヤー:4"});
	my $party5 = &display_monster_player_status($data->{"プレイヤー:5"});
	my $enemy1 = &display_monster_player_status($data->{"エネミー:1"});
	my $enemy2 = &display_monster_player_status($data->{"エネミー:2"});
	my $enemy3 = &display_monster_player_status($data->{"エネミー:3"});
	my $enemy4 = &display_monster_player_status($data->{"エネミー:4"});
	my $enemy5 = &display_monster_player_status($data->{"エネミー:5"});

	$battle_date[$j] .= <<"EOM";
<TR>
	<TD CLASS="b2" COLSPAN="3" ALIGN="center">
	$i ターン
	</TD>
</TR>
<TR>
<TD colspan="3">
<div class="battle_stage">
<div class="enemy">
  	<div class="enemy1 non">
    	<span class="name">$data->{"エネミー:1"}->{名前}</span>
    	<span class="hp">HP: $data->{"エネミー:1"}->{HP}</span>
    	<img src="/img/enemy/mon_129r.gif" class="">
    </div>
  	<div class="enemy2 non">
    	<span class="name">$data->{"エネミー:2"}->{名前}</span>
    	<span class="hp">HP: $data->{"エネミー:2"}->{HP}</span>
    	<img src="/img/enemy/mon_281.gif" class="">
    </div>
  	<div class="enemy3 non">
    	<span class="name">$data->{"エネミー:3"}->{名前}</span>
    	<span class="hp">HP: $data->{"エネミー:3"}->{HP}</span>
    	<img src="/img/enemy/mon_282.gif" class="">
    </div>
  	<div class="enemy4 non">
    	<span class="name">$data->{"エネミー:4"}->{名前}</span>
    	<span class="hp">HP: $data->{"エネミー:4"}->{HP}</span>
    	<img src="/img/enemy/mon_283.gif" class="">
    </div>
  	<div class="enemy5 non">
    	<span class="name">$data->{"エネミー:5"}->{名前}</span>
    	<span class="hp">HP: $data->{"エネミー:5"}->{HP}</span>
    	<img src="/img/enemy/mon_284.gif" class="">
    </div>
</div>
<div class="player">
	<div class="player1 non">
		<span class="name">$data->{"プレイヤー:1"}->{名前}</span>
  		<span class="hp">HP: $data->{"プレイヤー:1"}->{HP}</span>
  		<img src="/img/face/1008010101.png" class="mini" width="48">
  	</div>
	<div class="player2 non">
		<span class="name">$data->{"プレイヤー:2"}->{名前}</span>
  		<span class="hp">HP: $data->{"プレイヤー:2"}->{HP}</span>
  		<img src="/img/face/1009010101.png" class="mini" width="48">
  	</div>
	<div class="player3 non">
		<span class="name">$data->{"プレイヤー:3"}->{名前}</span>
  		<span class="hp">HP: $data->{"プレイヤー:3"}->{HP}</span>
  		<img src="/img/face/1010010101.png" class="mini" width="48">
  	</div>
	<div class="player4 non">
		<span class="name">$data->{"プレイヤー:4"}->{名前}</span>
  		<span class="hp">HP: $data->{"プレイヤー:4"}->{HP}</span>
  		<img src="/img/face/1011010101.png" class="mini" width="48">
  	</div>
	<div class="player5 non">
		<span class="name">$data->{"プレイヤー:5"}->{名前}</span>
  		<span class="hp">HP: $data->{"プレイヤー:5"}->{HP}</span>
  		<img src="/img/face/1011010102.png" class="mini" width="48">
  	</div>
</div>
</div>
</td>
</tr>

<TR>
<TD>

<div class="blackboard question position-relative status-player1 non">
<div class="menu-close" style="float: right; cursor: pointer">×</div>
$party1
</div>
<div class="blackboard question position-relative status-player2 non">
<div class="menu-close" style="float: right; cursor: pointer">×</div>
$party2
</div>
<div class="blackboard question position-relative status-player3 non">
<div class="menu-close" style="float: right; cursor: pointer">×</div>
$party3
</div>
<div class="blackboard question position-relative status-player4 non">
<div class="menu-close" style="float: right; cursor: pointer">×</div>
$party4
</div>
<div class="blackboard question position-relative status-player5 non">
<div class="menu-close" style="float: right; cursor: pointer">×</div>
$party5
</div>

</TD>
<TD>
<FONT COLOR="#9999DD">VS</FONT>
</TD>
<TD>

<div class="blackboard question position-relative status-enemy1 non">
<div class="menu-close" style="float: right; cursor: pointer">×</div>
$enemy1
</div>
<div class="blackboard question position-relative status-enemy2 non">
<div class="menu-close" style="float: right; cursor: pointer">×</div>
$enemy2
</div>
<div class="blackboard question position-relative status-enemy3 non">
<div class="menu-close" style="float: right; cursor: pointer">×</div>
$enemy3
</div>
<div class="blackboard question position-relative status-enemy4 non">
<div class="menu-close" style="float: right; cursor: pointer">×</div>
$enemy4
</div>
<div class="blackboard question position-relative status-enemy5 non">
<div class="menu-close" style="float: right; cursor: pointer">×</div>
$enemy5
</div>

</TD>
<TR>
<TD COLSPAN="3">

<div class="blackboard question">
	<p>
EOM

	if($k_btype eq "60" && $dhp > 0){
		&skill_up(13,$mlv);
		$battle_date[$j] .= "<font color=$elmcolor[6]>$kname はHPを$dhp 消費し、黒いオーラを噴き出した・・</font><p>$kskm";
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
			$battle_date[$j] .= "$kname は相手を見据えて身構えた！<p>$kskm";
			$kskm = "";
			$dcut = 1;
		}
	}

	$dup1 = 0;
	if($k_btype eq "62" && $kbuff[3] == 0 ){
		if(($ksk[15] / 50 + $k_batc) > rand(100)){
			&skill_up(15,$mlv);
			$dup1 = int(rand($ksk[15] / 100) + 1);
			$battle_date[$j] .= "$kname は印を結んだ・・・影分身が$dup1 体現れた！<p>$kskm";
			$kskm = "";
		}

	}

	$fst_flg = int($kn_5 * $kbuff[2] - $mspd * $mbuff[2] + rand(30));
	if($dcut == 1){
		$fst_flg = 0;
	}elsif($efct1[0]){
		$fst_flg = 30;
		$com1 = "$kname の先制攻撃！<br>$com1";
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
				$com1 .= "影分身が$dup1 体攻撃に参加した！<br>";
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
				$com1 = "$kname は動けない！<br>";
				$kbuff[3]+= 1;
			} elsif($m_esc > 0 && $clit1 eq "" && $dmg1 > 0) {
				$dmg1 = 0;
				$com1 .= "$mname はかわした！<br>";
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
				&add_risk2;
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
				&add_risk2;
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
				$clit1 .= "<br><b class=\"clit\">$mname $death_msg[$atc_skill1][$k_welm]</b><br>";
				$md_flg=1;
			}

			$kskm = "";
			if($dmg1 > 0){
				$battle_date[$j] .= "$com1 そして<b>$swg1</b>回 ヒットし、 $mname に <font class=\"dmg\"><b>$dmg1</b></font> のダメージ！$efcmsg $clit1<p>";
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
					$battle_date[$j] .= "$kname は素早く次の$k_bname を準備した！<p>";
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
			$com2 = "<font color=$elmcolor[$mwelm]>$mname は$mwmsg</font><br>";

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
				$com2 = "$mname は動けない！<br>";
				$mbuff[3]+= 1;
			} elsif($k_blc > 0 && $dmg2 > 0 && $k_btype eq "61" && $dcut == 1 && ($atc_skill1 <= 2 || $atc_skill1 == 5)){
				$com2 .= "$kname は$k_anam で弾くと同時に踏み込んだ！<br>$kskm";
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
				$com2 .= "影分身が$dupd 人身代わりになった！<br>";
				$dup1 -= $dupd;
				if($dup1 < 1) {$dup1=0;}
			} elsif($k_par > 0 && $dmg2 > 0){
				$com2 .= "$kname は$k_wnam で受け流した！<br>";
				$dmg2 = 0;
			} elsif($k_blc > 0 && $dmg2 > 0) {
				$kskm = "";
				&skill_up(21,$mlv);
				if($kskm ne ""){ $kskm = "<p>$kskm"; }
				$com2 .= "$kname は$k_anam で防いだ！<br>$kskm";
				$dmg2 = 0;
			} elsif($k_esc > 0 && $dmg2 > 0) {
				$com2 .= "$kname はかわした！<br>";
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
				$clit3 = "<br><b class=\"clit\">$kname は気絶した・・</b>";
				$kd_flg=1;
			}

			if($dmg2 > 0){
				$battle_date[$j] .= "$com2 $clit2 $kname は <font class=\"dmg\"><b>$dmg2</b></font> のダメージ！$mefcmsg$clit3<p>";
			} else {
				$battle_date[$j] .= "$com2<p>";
			}
			$khp_flg = $khp_flg - $dmg2;
			if($khp_flg <= 0 || $kd_flg) { $win = 2; last; }

		}
		$turnflg = 1;
	}

	$battle_date[$j] .= "</p>\n</div>\n";

	my $sel_no = &monster_get_sel_number(\@battle_date);

	$battle_date[$j] = <<"EOM";
<DIV id="sel$sel_no">
<TABLE BORDER=0 class="layer_table">
$battle_date[$j]
	</TD>
</TR>
</TABLE>
</DIV>
EOM

	# $battle_date[$j] = Encode::decode_utf8($battle_date[$j]);

	$j++;

	if($win > 0)
	{
		return 1;
	}

	return 0;
}

sub monster_get_sel_number
{
	my $battle_date = shift;
	my $sel = 0;

	for my $line (@$battle_date)
	{
		if ($line =~ /\sid="sel(\d+)"/s)
		{
			$sel = int($1);
		}
	}

	return $sel + 1;
}

sub monster_rename_dup_chara_name
{
}

sub monster_initialize2
{
	# キャラ読み出し

	for my $no (1 .. 5)
	{
		my $k = &chara_load($kid);
		$k_party->[$no - 1] = $k;

		if ($no != 1)
		{
			$k_party->[$no - 1]->{名前} .= $no;
		}
	}

	&monster_rename_dup_chara_name();

	$turn = 1;
	$win = 0;

	&skill_load;

	$ltime = time();
	$ltime = $ltime - $kdate;
	$vtime = $b_time - $ltime;
	$mtime = $m_time - $ltime;

	&add_risk2;
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

	# モンスター読み出し

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

	my @MONSTERNO = &load_ini($pop_enemy);

	for my $no (1 .. 5)
	{
		my $r_no = int(rand(@MONSTERNO));
		my $mid = $MONSTERNO[$r_no];
		my $m = &monster_load($mid);
		$m_party->[$no - 1] = $m;

		if ($no != 1)
		{
			$m_party->[$no - 1]->{名前} .= $no;
		}
	}

	if($in{'c_name'}) { $kname = $in{'c_name'}; }
	$khp_flg = $khp;
	$kd_flg = 0;

	
	$mhp_flg = $mhp;
	$md_flg = 0;

	$i=1;$j=1;@battle_date=();

	@battle_header = ();
	@battle_footer = ();

	push @battle_header, "$movemsg<br>";
	push @battle_header, "$kname は、$mname に遭遇した！" if (! $bossflg);
	push @battle_header, "$kname は、$area_name[$karea] の支配者、$mname に遭遇した！" if ($bossflg);

	# $battle_header[$_] = Encode::decode_utf8($battle_header[$_]) for 0 .. $#battle_header;
}

sub monster_load
{
	my $id = shift;

	my @MONSTER = &load_ini($monster_file);
	my $m = {};
	my @keys = (qw|NO 名前 レベル 経験値 所持金 HP SP 攻撃力 防御力 素早さ 器用さ 属性 タイプ ドロップ|);
	
	foreach(@MONSTER)
	{
		my @tmp = split(/<>/);
		if(int($tmp[0]) == $id)
		{
			@$m{@keys} = @tmp;
			last;
		}
	}
	
	if (defined $m)
	{
		($mno,$mname,$mlv,$mex,$mgold,$mhp,$msp,$mdmg,$mdef,$mspd,$mtec,$melm,$mtype,$mdrop) = @$m{@keys};
	}

	$m->{HP} = int(rand($m->{HP})) + $m->{SP};
	$m->{最大HP} = $m->{HP};
	$m->{バフ} = [];
	
	return $m;
}

sub monster_finalize2
{
	&monster_stage_save2;

	my $battle = File::Spec->catfile($FindBin::Bin, "save", "battle", $kid. ".monster.yaml");
	my $file = Mojo::File->new($battle);
	my $move = File::Spec->catfile($FindBin::Bin, "save", "archive", &gettimeofday. ".monster.yaml");
	$file->move_to($move);
}

sub gettimeofday2
{
	my @tmp = Time::HiRes::gettimeofday;
	return join(".", @tmp);
}

sub monster_stage_save2
{
	my $data = {
		"ステージデータ" => {
			khp_flg => $khp_flg,
			kd_flg  => $kd_flg,
			mhp_flg => $mhp_flg,
			md_flg  => $md_flg,
			ltime   => $ltime,
			vtime   => $vtime,
			mtime   => $mtime,
			"ターン"   => $turn,
			header => \@battle_header,
			footer => \@battle_footer,
			"ログ"    => \@battle_date,
			"フラグ"   => $win,
			i       => $i,
			j       => $j,
		},
		"プレイヤー" => {
			id     => $kid,
			"パスワード"  => $kpass,
			"名前"     => $kname,
			"性別"     => $ksex,
			"画像"     => $kchara,
			"力"      => $kn_0,
			"賢さ"     => $kn_1,
			"信仰心"    => $kn_2,
			"体力"     => $kn_3,
			"器用さ"    => $kn_4,
			"素早さ"    => $kn_5,
			"魅力"     => $kn_6,
			HP     => $khp,
			"最大HP"   => $kmaxhp,
			"経験値"    => $kex,
			"レベル"    => $klv,
			"残りAP"   => $kap,
			"所持金"    => $kgold,
			LP     => $klp,
			"戦闘数"    => $ktotal,
			"勝利数"    => $kkati,
			"ホスト"    => $khost,
			"最終アクセス" => $kdate,
			"エリア"    => $karea,
			"スポット"   => $kspot,
			"距離"     => $kpst,
			"アイテム"   => $kitem,
			"リスク"    => $wrsk,
			"バフ"     => \@kbuff,
		},
		"エネミー"  => {
			NO   => $mno,
			"名前"   => $mname,
			"レベル"  => $mlv,
			"経験値"  => $mex,
			"所持金"  => $mgold,
			HP   => $mhp,
			SP   => $msp,
			"攻撃力"  => $mdmg,
			"防御力"  => $mdef,
			"素早さ"  => $mspd,
			"器用さ"  => $mtec,
			"属性"   => $melm,
			"ドロップ" => $mdrop,
			"タイプ"  => $mtype,
			"バフ"     => \@mbuff,
		},
	};

	for my $no (1.. 5)
	{
		$data->{"プレイヤー:". $no} = $k_party->[$no - 1];
	}
	for my $no (1.. 5)
	{
		$data->{"エネミー:". $no} = $m_party->[$no - 1];
	}

	my $battle = File::Spec->catfile($FindBin::Bin, "save", "battle", $kid. ".monster.yaml");
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

sub monster_data_apply_select_player
{
	my $data = shift;
	my $no = shift;

	$data->{"プレイヤー:". $no}->{id} = $kid;
	$data->{"プレイヤー:". $no}->{"パスワード"} = $kpass;
	$data->{"プレイヤー:". $no}->{"名前"} = $kname;
	$data->{"プレイヤー:". $no}->{"性別"} = $ksex;
	$data->{"プレイヤー:". $no}->{"画像"} = $kchara;
	$data->{"プレイヤー:". $no}->{"力"} = $kn_0;
	$data->{"プレイヤー:". $no}->{"賢さ"} = $kn_1;
	$data->{"プレイヤー:". $no}->{"信仰心"} = $kn_2;
	$data->{"プレイヤー:". $no}->{"体力"} = $kn_3;
	$data->{"プレイヤー:". $no}->{"器用さ"} = $kn_4;
	$data->{"プレイヤー:". $no}->{"素早さ"} = $kn_5;
	$data->{"プレイヤー:". $no}->{"魅力"} = $kn_6;
	$data->{"プレイヤー:". $no}->{HP} = $khp;
	$data->{"プレイヤー:". $no}->{"最大HP"} = $kmaxhp;
	$data->{"プレイヤー:". $no}->{"経験値"} = $kex;
	$data->{"プレイヤー:". $no}->{"レベル"} = $klv;
	$data->{"プレイヤー:". $no}->{"残りAP"} = $kap;
	$data->{"プレイヤー:". $no}->{"所持金"} = $kgold;
	$data->{"プレイヤー:". $no}->{LP} = $klp;
	$data->{"プレイヤー:". $no}->{"戦闘数"} = $ktotal;
	$data->{"プレイヤー:". $no}->{"勝利数"} = $kkati;
	$data->{"プレイヤー:". $no}->{"ホスト"} = $khost;
	$data->{"プレイヤー:". $no}->{"最終アクセス"} = $kdate;
	$data->{"プレイヤー:". $no}->{"エリア"} = $karea;
	$data->{"プレイヤー:". $no}->{"スポット"} = $kspot;
	$data->{"プレイヤー:". $no}->{"距離"} = $kpst;
	$data->{"プレイヤー:". $no}->{"アイテム"} = $kitem;
	$data->{"プレイヤー:". $no}->{"リスク"} = $wrsk;
	@{$data->{"プレイヤー:". $no}->{"バフ"}} = @kbuff;
}

sub monster_stage_apply_select_player
{
	my $data = shift;
	my $no = shift;

	$kid = $data->{"プレイヤー:". $no}->{id};
	$kpass = $data->{"プレイヤー:". $no}->{"パスワード"};
	$kname = $data->{"プレイヤー:". $no}->{"名前"};
	$ksex = $data->{"プレイヤー:". $no}->{"性別"};
	$kchara = $data->{"プレイヤー:". $no}->{"画像"};
	$kn_0 = $data->{"プレイヤー:". $no}->{"力"};
	$kn_1 = $data->{"プレイヤー:". $no}->{"賢さ"};
	$kn_2 = $data->{"プレイヤー:". $no}->{"信仰心"};
	$kn_3 = $data->{"プレイヤー:". $no}->{"体力"};
	$kn_4 = $data->{"プレイヤー:". $no}->{"器用さ"};
	$kn_5 = $data->{"プレイヤー:". $no}->{"素早さ"};
	$kn_6 = $data->{"プレイヤー:". $no}->{"魅力"};
	$khp = $data->{"プレイヤー:". $no}->{HP};
	$kmaxhp = $data->{"プレイヤー:". $no}->{"最大HP"};
	$kex = $data->{"プレイヤー:". $no}->{"経験値"};
	$klv = $data->{"プレイヤー:". $no}->{"レベル"};
	$kap = $data->{"プレイヤー:". $no}->{"残りAP"};
	$kgold = $data->{"プレイヤー:". $no}->{"所持金"};
	$klp = $data->{"プレイヤー:". $no}->{LP};
	$ktotal = $data->{"プレイヤー:". $no}->{"戦闘数"};
	$kkati = $data->{"プレイヤー:". $no}->{"勝利数"};
	$khost = $data->{"プレイヤー:". $no}->{"ホスト"};
	$kdate = $data->{"プレイヤー:". $no}->{"最終アクセス"};
	$karea = $data->{"プレイヤー:". $no}->{"エリア"};
	$kspot = $data->{"プレイヤー:". $no}->{"スポット"};
	$kpst = $data->{"プレイヤー:". $no}->{"距離"};
	$kitem = $data->{"プレイヤー:". $no}->{"アイテム"};
	$wrsk = $data->{"プレイヤー:". $no}->{"リスク"};
	@kbuff = @{$data->{"プレイヤー:". $no}->{"バフ"}};
}

sub monster_data_apply_select_monster
{
	my $data = shift;
	my $no = shift;

	$data->{"エネミー:". $no}->{NO} = $mno;
	$data->{"エネミー:". $no}->{"名前"} = $mname;
	$data->{"エネミー:". $no}->{"レベル"} = $mlv;
	$data->{"エネミー:". $no}->{"経験値"} = $mex;
	$data->{"エネミー:". $no}->{"所持金"} = $mgold;
	$data->{"エネミー:". $no}->{HP} = $mhp;
	$data->{"エネミー:". $no}->{SP} = $msp;
	$data->{"エネミー:". $no}->{"攻撃力"} = $mdmg;
	$data->{"エネミー:". $no}->{"防御力"} = $mdef;
	$data->{"エネミー:". $no}->{"素早さ"} = $mspd;
	$data->{"エネミー:". $no}->{"器用さ"} = $mtec;
	$data->{"エネミー:". $no}->{"属性"} = $melm;
	$data->{"エネミー:". $no}->{"ドロップ"} = $mdrop;
	$data->{"エネミー:". $no}->{"タイプ"} = $mtype;
	@{$data->{"エネミー:". $no}->{"バフ"}} = @mbuff;
}

sub monster_stage_apply_select_monster
{
	my $data = shift;
	my $no = shift;

	$mno = $data->{"エネミー:". $no}->{NO};
	$mname = $data->{"エネミー:". $no}->{"名前"};
	$mlv = $data->{"エネミー:". $no}->{"レベル"};
	$mex = $data->{"エネミー:". $no}->{"経験値"};
	$mgold = $data->{"エネミー:". $no}->{"所持金"};
	$mhp = $data->{"エネミー:". $no}->{HP};
	$msp = $data->{"エネミー:". $no}->{SP};
	$mdmg = $data->{"エネミー:". $no}->{"攻撃力"};
	$mdef = $data->{"エネミー:". $no}->{"防御力"};
	$mspd = $data->{"エネミー:". $no}->{"素早さ"};
	$mtec = $data->{"エネミー:". $no}->{"器用さ"};
	$melm = $data->{"エネミー:". $no}->{"属性"};
	$mdrop = $data->{"エネミー:". $no}->{"ドロップ"};
	$mtype = $data->{"エネミー:". $no}->{"タイプ"};
	@mbuff = @{$data->{"エネミー:". $no}->{"バフ"}};
}

sub monster_stage_apply2
{
	my $data = shift;

	$i = $data->{"ステージデータ"}->{i};
	$j = $data->{"ステージデータ"}->{j};
	$win = $data->{"ステージデータ"}->{"フラグ"};
	@battle_date = @{$data->{"ステージデータ"}->{"ログ"}};
	@battle_header = @{$data->{"ステージデータ"}->{header}};
	@battle_fotter = @{$data->{"ステージデータ"}->{footer}};

	$turn = $data->{"ステージデータ"}->{"ターン"};
	$khp_flg = $data->{"ステージデータ"}->{khp_flg};
	$kd_flg = $data->{"ステージデータ"}->{kd_flg};
	$mhp_flg = $data->{"ステージデータ"}->{mhp_flg};
	$md_flg = $data->{"ステージデータ"}->{md_flg};
	$ltime = $data->{"ステージデータ"}->{ltime};
	$vtime = $data->{"ステージデータ"}->{vtime};
	$mtime = $data->{"ステージデータ"}->{mtime};

	$mno = $data->{"エネミー"}->{NO};
	$mname = $data->{"エネミー"}->{"名前"};
	$mlv = $data->{"エネミー"}->{"レベル"};
	$mex = $data->{"エネミー"}->{"経験値"};
	$mgold = $data->{"エネミー"}->{"所持金"};
	$mhp = $data->{"エネミー"}->{HP};
	$msp = $data->{"エネミー"}->{SP};
	$mdmg = $data->{"エネミー"}->{"攻撃力"};
	$mdef = $data->{"エネミー"}->{"防御力"};
	$mspd = $data->{"エネミー"}->{"素早さ"};
	$mtec = $data->{"エネミー"}->{"器用さ"};
	$melm = $data->{"エネミー"}->{"属性"};
	$mdrop = $data->{"エネミー"}->{"ドロップ"};
	$mtype = $data->{"エネミー"}->{"タイプ"};
	@mbuff = @{$data->{"エネミー"}->{"バフ"}};

	$kid = $data->{"プレイヤー"}->{id};
	$kpass = $data->{"プレイヤー"}->{"パスワード"};
	$kname = $data->{"プレイヤー"}->{"名前"};
	$ksex = $data->{"プレイヤー"}->{"性別"};
	$kchara = $data->{"プレイヤー"}->{"画像"};
	$kn_0 = $data->{"プレイヤー"}->{"力"};
	$kn_1 = $data->{"プレイヤー"}->{"賢さ"};
	$kn_2 = $data->{"プレイヤー"}->{"信仰心"};
	$kn_3 = $data->{"プレイヤー"}->{"体力"};
	$kn_4 = $data->{"プレイヤー"}->{"器用さ"};
	$kn_5 = $data->{"プレイヤー"}->{"素早さ"};
	$kn_6 = $data->{"プレイヤー"}->{"魅力"};
	$khp = $data->{"プレイヤー"}->{HP};
	$kmaxhp = $data->{"プレイヤー"}->{"最大HP"};
	$kex = $data->{"プレイヤー"}->{"経験値"};
	$klv = $data->{"プレイヤー"}->{"レベル"};
	$kap = $data->{"プレイヤー"}->{"残りAP"};
	$kgold = $data->{"プレイヤー"}->{"所持金"};
	$klp = $data->{"プレイヤー"}->{LP};
	$ktotal = $data->{"プレイヤー"}->{"戦闘数"};
	$kkati = $data->{"プレイヤー"}->{"勝利数"};
	$khost = $data->{"プレイヤー"}->{"ホスト"};
	$kdate = $data->{"プレイヤー"}->{"最終アクセス"};
	$karea = $data->{"プレイヤー"}->{"エリア"};
	$kspot = $data->{"プレイヤー"}->{"スポット"};
	$kpst = $data->{"プレイヤー"}->{"距離"};
	$kitem = $data->{"プレイヤー"}->{"アイテム"};
	$wrsk = $data->{"プレイヤー"}->{"リスク"};
	@kbuff = @{$data->{"プレイヤー"}->{"バフ"}};

	for my $no (1.. 5)
	{
		$k_party->[$no - 1] = $data->{"プレイヤー:". $no};
		$m_party->[$no - 1] = $data->{"エネミー:". $no};
	}
}

sub monster_stage_load2
{
	my $battle = File::Spec->catfile($FindBin::Bin, "save", "battle", $kid. ".monster.yaml");
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

sub is_continue_monster2
{
	my $data = shift;
	my $battle = File::Spec->catfile($FindBin::Bin, "save", "battle", $kid. ".monster.yaml");

	if (! -f $battle)
	{
		return 0;
	}
	else
	{
		$data = &monster_stage_load2;
		my $bool1 = &monster_judge_battle($data);
		return $bool1 == 0 ? 1 : 0;
	}
}

sub monster_select_target_random_player
{
	my $data = shift;
	my @ret;

	for my $key (keys %$data)
	{
		if ($key !~ /^プレイヤー:(\d+)$/)
		{
			next;
		}
		if ($data->{$key}->{HP} <= 0)
		{
			$data->{$key}->{HP} = 0;
			next;
		}
		push(@ret, $1);
	}

	my $system = $mojo->entity("system");

	if (scalar(@ret) == 0)
	{
		return undef;
	}

	return $ret[$system->range_rand(0, $#ret)];
}

sub monster_select_target_random_enemy
{
	my $data = shift;
	my @ret;

	for my $key (keys %$data)
	{
		if ($key !~ /^エネミー:(\d+)$/)
		{
			next;
		}
		if ($data->{$key}->{HP} <= 0)
		{
			$data->{$key}->{HP} = 0;
			next;
		}
		push(@ret, $1);
	}

	my $system = $mojo->entity("system");

	if (scalar(@ret) == 0)
	{
		return undef;
	}

	return $ret[$system->range_rand(0, $#ret)];
}

sub monster_attack_order
{
	my $data = shift;
	my @ret;

	for my $key (keys %$data)
	{
		if ($key !~ /^エネミー:(\d+)$/ && $key !~ /^プレイヤー:(\d+)$/)
		{
			next;
		}
		if ($data->{$key}->{HP} <= 0)
		{
			$data->{$key}->{HP} = 0;
			next;
		}
		push(@ret, $key);
	}

	return Mojo::Collection->new(@ret)->shuffle;
}

sub monster_judge_battle # 0 .. 戦闘続行、1...プレイヤー勝利、2...モンスター勝利、3...相討ち
{
	my $data = shift;
	my $pid = &monster_select_target_random_player($data);
	my $eid = &monster_select_target_random_enemy($data);

	if (defined $pid && defined $eid)
	{
		return 0;
	}
	elsif (defined $pid && ! defined $eid)
	{
		return 1;
	}
	elsif (! defined $pid && defined $eid)
	{
		return 2;
	}
	elsif (! defined $pid && ! defined $eid)
	{
		return 3;
	}
	else
	{
		die "pe";
	}
}

sub monster2
{
	$battle_flag=1;

	our $k_party = [];
	our $m_party = [];

	&save_dat_append;

	# 途中データ確認
	my $data;
	if (&is_continue_monster2($data))
	{
		$data = &monster_stage_load2;
		&monster_stage_apply2($data);
	}
	else
	{
		&monster_initialize2;
		&monster_stage_save2;
		&display_monster_battle2;
		$khp = $khp_flg;
		&regist;
		exit;
	}

	# ここでユーザーを変えて疑似的に多人数バトルを試してみる
	my @order = @{&monster_attack_order($data)->to_array};

	for my $num (0 .. $#order)
	{
		if (&monster_judge_battle($data) == 0)
		{
			if ($data->{$order[$num]}->{HP} <= 0)
			{
				next;
			}
			my $key = $order[$num];
			my $pid;
			my $eid;

			if ($key =~ /^プレイヤー:(\d+)$/)
			{
				$pid = int($1);
				$eid = &monster_select_target_random_enemy($data);
			}
			elsif ($key =~ /^エネミー:(\d+)$/)
			{
				$eid = int($1);
				$pid = &monster_select_target_random_player($data);
			}

			if (defined $eid && defined $pid)
			{
				&monster_stage_apply_select_player($data, $pid);
				&monster_stage_apply_select_monster($data, $eid);

				my $res = &monster_step_run2($data); # 1...終了,0...継続
				$khp = $khp_flg;
				# $mhp = $mhp_flg;

				&monster_data_apply_select_player($data, $pid);
				&monster_data_apply_select_monster($data, $eid);

				if($j > 10)
				{
					&add_risk2;
					$wrsk = $krsk;
				}
			}
		}
		else
		{
			last;
		}
	}

	&monster_stage_apply_select_player($data, 1);
	&monster_data_apply_select_player($data, 1);

	$win = &monster_judge_battle($data);

	if ($win == 0)
	{
		$turn++;
		$i++;
		$j++;
		$battle_flag=0;
		&monster_stage_save2;
		&display_monster_battle2($data);
		$khp = $khp_flg;
		&regist;
		exit;
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
		$comment = "<b>$mname は倒れた・・。</b><p>";

		if(int(rand(20)) == 1){
			if($kitem < $max_item) {
				&stone_drop;
				$kitem = $u_cnt;
				$dmsg = "<b>$kname は不思議な輝きを放つ石を見つけた！</b><p>";
				$drop_flag = 1;
			} else {
				$dmsg = "<b>$kname は不思議な輝きを放つ石を見つけたが、持ちきれなかった！</b><p>";
			}
		}

		if(int(rand(20)) == 1){
			if($kitem < $max_item) {
				&item_drop;
				$kitem = $u_cnt;
				$dmsg .= "<b>$kname は使えそうなものを拾った！</b><p>";
				$drop_flag = 1;
			} else {
				$dmsg .= "<b>$kname は使えそうなものを見つけたが、持ちきれなかった！</b><p>";
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
			$comment = "<b>$kname は力尽きた・・。</b><p>";
			$comment .= "<b>$town_name[$karea] の警備隊に救助され、$town_name[$karea] に運ばれた・・。</b><p>";
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
			$comment = "<b>$kname が起き上がれない隙に、$mname が何かを持ち去っていった・・。</b><p>";
			$move_flag = 1;
			if($kspot > 0){
				$kpst++;
			}
		} else {
			$comment = "<b>$kname は傷を負ったが、何とか逃げ延びた・・。</b><p>";
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
		$dmsg .= "<b>$k_wnam が使い物にならなくなった！</b><p>";
	}

	if($k_sdef > 0 && $wrsk > $k_sdef * 25 && int(rand(100)) < $wrsk - $k_sdef * 25){
		$btl_flg = 1;
		$k_id = $k_sid;
		&item_sell;
		$kitem = $item_count;
		$dmsg .= "<b>$k_anam が使い物にならなくなった！</b><p>";
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
					$dmsg .= "<b>$kname は宝箱を発見した！$bgold</b>Gとアイテムを入手した！<p>";
				} else {
					$dmsg .= "<b>$kname は宝箱を発見した！$bgold</b>Gを入手した！<p>";
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
				$lastmsg = "$town_name[$farea] に到着しました。<p>$get_msg";
				$karea = $farea;
				$kspot = 0;
				$kpst = 0;
			}
		} elsif($kspot == 3){
			if($move_flag > 0){
				$get_area=$rarea;$get_id="01";$get_cnt="0";
				&get_msg;
				$lastmsg = "$town_name[$rarea] に到着しました。<p>$get_msg";
				$karea = $rarea;
				$kspot = 0;
				$kpst = 0;
			}
		}
	} elsif($kpst > $town_move[$karea][$kspot]) {
		if($kspot > 0){
			if($move_flag > 0){
				$lastmsg = "$town_name[$karea] に到着しました。";
				$karea = $karea;
				$kspot = 0;
				$kpst = 0;
			}
		}
	}

	push @battle_footer, "$comment<b>$mex%</b>の経験値を失った。<p>$dmsg\n" if ($win == 2);
	push @battle_footer, "$comment<p><b>$mex%</b>の経験値を取得！<b>$gold</b>G入手！<p>$dmsg\n" if($win == 1);
	push @battle_footer, $lastmsg if ($lastmsg);

	&regist;
	&monster_finalize2;
	&display_monster_battle2($data);

	$battle_flag=0;

	exit;
}

sub display_monster_status
{
	my $m = shift;
	my $matcv = int($mbuff[0] * 100);
	my $mdefv = int($mbuff[1] * 100);
	my $mspdv = int($mbuff[2] * 100);
	my $mstpv = "";
	
	if($mbuff[3] < 0){
		$mstpv = "行動不能";
	}

	my $out = $controller->render_to_string(inline => <<EOF, m => $m, matcv => $matcv, mdefv => $mdefv, mspdv => $mspdv, mstpv => $mstpv, elmcolor => $elmcolor, melm => $melm, efcolor => $efcolor);
	<TABLE BORDER=0>
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
	<%= $m->{名前} %>
		</TD>
	<TD>
	<font color=<%= $elmcolor->[$melm] %>><%= $m->{名前} %></font>
	</TD>
	<TD>
	<%= $m->{HP} %>/<%= $mhp_flg %>
	</TD>
</TR>
	<TR>
	<TD CLASS="b1" COLSPAN="3" ALIGN="center">
	効果 攻/防/速
		</TD>
</TR>
	<TR>
	<TD COLSPAN="3" ALIGN="center">
	<font color="<%= $efcolor->[0] %>"><%= $matcv %> %</font> / <font color="<%= $efcolor->[1] %>"><%= $mdefv %> %</font> / <font color="<%= $efcolor->[2] %>"><%= $mspdv %> %</font> <%= $mstpv %>
	</TD>
</TR>
	</TABLE>
EOF

}

sub display_monster_player_status
{
	my $k = shift;
	my $katcv = int($k->{"バフ"}->[0] * 100);
	my $kdefv = int($k->{"バフ"}->[1] * 100);
	my $kspdv = int($k->{"バフ"}->[2] * 100);
	my $kstpv = "";

	if($k->{"バフ"}->[3] < 0){
		$kstpv = "行動不能";
	}

	my $out = $controller->render_to_string(inline => <<'EOF', k => $k, katcv => $katcv, kdefv => $kdefv, kspdv => $kspdv, kstpv => $kstpv, elmcolor => $elmcolor, k_aelm => $k_aelm, efcolor => $efcolor);
		<TABLE BORDER=0>
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
	<%= $k->{レベル} %>
	</TD>
	<TD>
	<font color=<%= $elmcolor->[$k_aelm] %>><%= $k->{名前} %></font>
	</TD>
	<TD>
	<%= $k->{HP} %>/<%= $k->{最大HP} %>
	</TD>
</TR>
<TR>
	<TD CLASS="b1" COLSPAN="3" ALIGN="center">
	効果 攻/防/速
	</TD>
</TR>
<TR>
	<TD COLSPAN="3" ALIGN="center">
	<font color="<%= $efcolor->[0] %>"><%= $katcv %> %</font> / <font color="<%= $efcolor->[1] %>"><%= $kdefv %> %</font> / <font color="<%= $efcolor->[2] %>"><%= $kspdv %> %</font> <%= $kstpv %>
	</TD>
</TR>
</TABLE>
EOF

	return $out;
}

sub display_monster_battle2
{
	my $data = shift;

	my $out = $controller->render_to_string(
		template      => "battle",
		'battle_header' => \@battle_header,
		'battle_date'   => \@battle_date,
		'battle_footer' => \@battle_footer,
		j               => $j,
		kid             => $kid,
		kpass           => $kpass,
		sel             => $in{sel} || -1,
		spot            => "モンスター",
		mode            => "monster",
		rid             => "",
		k1id             => "",
		k2id             => "",
	);

	print Encode::encode_utf8($out);

}

#----------------------#
#  リスク積み上げ      #
#----------------------#
sub add_risk2 {
	$rid = $kid;
	&read_buff;

	$buff_flg = 0;
	$krsk = $rrsk + 1;
	&regist_buff;
}

1;
