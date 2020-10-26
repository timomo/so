#------------#
#  装備効果  #
#------------#
sub get_equip
{
	open(IN,"$item_path$kid");
	@equip_item = <IN>;
	close(IN);
	$hit=0;
	foreach(@equip_item){
		($i_id,$i_no,$i_name,$i_dmg,$i_gold,$i_mode,$i_uelm,$i_eelm,$i_hand,$i_def,$i_req,$i_qlt,$i_make,$i_rest,$i_eqp) = split(/<>/);
		if($i_eqp eq $k_eqp) {
			$hit=1;
			last;
		}
	}
	if(!$hit){
		($i_id,$i_no,$i_name,$i_dmg,$i_gold,$i_mode,$i_uelm,$i_eelm,$i_hand,$i_def,$i_req,$i_qlt,$i_make,$i_rest,$i_eqp) = split(/<>/,$equip_default[$k_eqp]);
	}
}

#------------#
#  攻撃      #
#------------#
sub get_attack{
	$avesk = 0;
	$bflg = 0;
	if($i_uelm == 0){
		$atc_skill1 = 0;
		$dmg1 = int($kn_0 + $i_dmg + $i_dmg * $ksk[0] / 1000 + $ksk[10] / 100);
		$dmg1 = int(($ksk[10] / 2000 + 1) * $dmg1);
		$swg1 = int($ksk[0] / 100 + $kn_5 / 10);
		if($swg1 < 1){$swg1 = 1;}
		$avesk = $ksk[0];
	}
	if($i_uelm == 1){
		$atc_skill1 = 1;
		$dmg1 = int($kn_0 + $i_dmg + $i_dmg * $ksk[1] / 1000 + $ksk[10] / 100);
		$dmg1 = int(($ksk[10] / 2000 + 1) * $dmg1);
		$swg1 = int($ksk[1] / 100 + $kn_5 / 10);
		if($swg1 < 1){$swg1 = 1;}
		$avesk = $ksk[1];
	}
	if($i_uelm == 2){
		$atc_skill1 = 2;
		$dmg1 = int($kn_0 + $i_dmg + $i_dmg * $ksk[2] / 1000 + $ksk[10] / 100);
		$dmg1 = int(($ksk[10] / 2000 + 1) * $dmg1);
		$swg1 = int($ksk[2] / 100 + $kn_5 / 10);
		if($swg1 < 1){$swg1 = 1;}
		$avesk = $ksk[2];
	}
	if($i_uelm == 3){
		$atc_skill1 = 3;
		$l_dmg = $i_dmg;
		if($k_btype eq "70"){$l_dmg += $k_batc;$bflg = 1;}
		$dmg1 = int($kn_0 + $l_dmg + $l_dmg * $ksk[3] / 1000 + $ksk[11] / 100);
		$dmg1 = int(($ksk[11] / 2000 + 1) * $dmg1);
		$swg1 = int($ksk[3] / 100 + $kn_5 / 10);
		if($swg1 < 1){$swg1 = 1;}
		$avesk = $ksk[3];
	}
	if($i_uelm == 4){
		$atc_skill1 = 4;
		$l_dmg = $i_dmg;
		if($k_btype eq "71"){$l_dmg += $k_batc;$bflg = 1;}
		$dmg1 = int($l_dmg * 2 + $l_dmg * $ksk[4] / 1000 + $ksk[11] / 100);
		$dmg1 = int(($ksk[11] / 2000 + 1) * $dmg1);
		$swg1 = int($ksk[4] / 100 + $kn_5 / 10);
		if($swg1 < 1){$swg1 = 1;}
		$avesk = $ksk[4];
	}
	if($i_uelm == 5){
		$sklflg = int(rand(2));
		if($sklflg == 0){
			$atc_skill1 = 0;
		} else {
			$atc_skill1 = 1;
		}
		$dmg1 = int($kn_0 + $i_dmg + $i_dmg * ($ksk[0] + $ksk[1]) / 1600 + $ksk[10] / 100);
		$dmg1 = int(($ksk[10] / 2000 + 1) * $dmg1);
		$swg1 = int(($ksk[0] + $ksk[1]) / 200 + $kn_5 / 10);
		if($swg1 < 1){$swg1 = 1;}
		$avesk = int(($ksk[0] + $ksk[1]) / 2);
	}
	if($i_uelm == 6){
		$sklflg = int(rand(2));
		if($sklflg == 0){
			$atc_skill1 = 0;
		} else {
			$atc_skill1 = 2;
		}
		$dmg1 = int($kn_0 + $i_dmg + $i_dmg * ($ksk[0] + $ksk[2]) / 1600 + $ksk[10] / 100);
		$dmg1 = int(($ksk[10] / 2000 + 1) * $dmg1);
		$swg1 = int(($ksk[0] + $ksk[2]) / 200 + $kn_5 / 10);
		if($swg1 < 1){$swg1 = 1;}
		$avesk = int(($ksk[0] + $ksk[2]) / 2);
	}
	if($i_uelm == 7){
		$sklflg = int(rand(2));
		if($sklflg == 0){
			$atc_skill1 = 1;
		} else {
			$atc_skill1 = 2;
		}
		$dmg1 = int($kn_0 + $i_dmg + $i_dmg * ($ksk[1] + $ksk[2]) / 1600 + $ksk[10] / 100);
		$dmg1 = int(($ksk[10] / 2000 + 1) * $dmg1);
		$swg1 = int(($ksk[1] + $ksk[2]) / 200 + $kn_5 / 10);
		if($swg1 < 1){$swg1 = 1;}
		$avesk = int(($ksk[1] + $ksk[2]) / 2);
	}
	if($i_uelm == 8){
		$sklflg = int(rand(3));
		if($sklflg == 0){
			$atc_skill1 = 0;
		} elsif($sklflg == 1) {
			$atc_skill1 = 1;
		} else {
			$atc_skill1 = 2;
		}
		$dmg1 = int($kn_0 + $i_dmg + $i_dmg * ($ksk[0] + $ksk[1] + $ksk[2]) / 2000 + $ksk[10] / 100);
		$dmg1 = int(($ksk[10] / 2000 + 1) * $dmg1);
		$swg1 = int(($ksk[0] + $ksk[1] + $ksk[2]) / 300 + $kn_5 / 10);
		if($swg1 < 1){$swg1 = 1;}
		$avesk = int(($ksk[0] + $ksk[1] + $ksk[2]) / 3);
	}
	if($i_uelm == 9){
		$atc_skill1 = 5;
		$dmg1 = int($kn_0 + $i_dmg + $i_dmg * $ksk[5] / 1000 + $ksk[10] / 100);
		$dmg1 = int(($ksk[10] / 2000 + 1) * $dmg1);
		$swg1 = int($ksk[5] / 100 + $kn_5 / 10);
		if($swg1 < 1){$swg1 = 1;}
		$avesk = $ksk[5];
	}
	if($i_uelm == 10){
		$atc_skill1 = 6;
		$dmg1 = int($kn_1 + $i_dmg + $i_dmg * $ksk[6] / 1000 + $ksk[12] / 100);
		$dmg1 = int(($ksk[12] / 2000 + 1) * $dmg1);
		$swg1 = int($ksk[6] / 100 + $kn_1 / 10);
		if($swg1 < 1){$swg1 = 1;}
		$avesk = $ksk[6];
	}
	if($i_uelm == 11){
		$atc_skill1 = 7;
		$dmg1 = int($kn_2 + $i_dmg + $i_dmg * $ksk[7] / 1000 + $ksk[12] / 100);
		$dmg1 = int(($ksk[12] / 2000 + 1) * $dmg1);
		$swg1 = int($ksk[7] / 100 + $kn_2 / 10);
		if($swg1 < 1){$swg1 = 1;}
		$avesk = $ksk[7];
	}
	if($i_uelm == 12){
		$atc_skill1 = 8;
		$dmg1 = int($kn_1 + $i_dmg + $i_dmg * $ksk[8] / 1000 + $ksk[12] / 100);
		$dmg1 = int(($ksk[12] / 2000 + 1) * $dmg1);
		$swg1 = int($ksk[8] / 100 + $kn_1 / 10);
		if($swg1 < 1){$swg1 = 1;}
		$avesk = $ksk[8];
	}
	if($i_uelm == 13){
		$atc_skill1 = 9;
		$dmg1 = int($kn_1 + $i_dmg + $i_dmg * $ksk[9] / 1000 + $ksk[12] / 100);
		$dmg1 = int(($ksk[12] / 2000 + 1) * $dmg1);
		$swg1 = int($ksk[9] / 100 + $kn_1 / 10);
		if($swg1 < 1){$swg1 = 1;}
		$avesk = $ksk[9];
	}
	if($i_uelm == 20){
		$atc_skill1 = 13;
		$avesk = $ksk[13];
	}
	if($i_uelm == 21){
		$atc_skill1 = 14;
		$avesk = $ksk[14];
	}
	if($i_uelm == 22){
		$atc_skill1 = 15;
		$avesk = $ksk[15];
	}
}

#------------#
#  技        #
#------------#
sub get_tech{
	$efcmsg = "";
	$spm = 5 + $kn_4 / 4 + $kskl / 40 - $mskl / 4;
	if($spm < 5){$spm = 5;}
	if($spm > int(rand(100))){
		$skpow=0;$rndsk=0;$rndmsg="";
		$rndsk  = int(rand($kskl / 200));
		if($rndsk > 4){$rndsk = 4;}
		if($atc_skill1 > 5){
			$rndmsg = "$clt_msg[$atc_skill1][$elm1][$rndsk]<br>";
			$dmg1 = int($dmg1 * (100 + $rndsk * 10) / 100);
			$skpow = $elm1;
		} else {
			$skpow = $rndsk;
		}
		($tname,$tdoc,$tatc,$telm,$tefct[0],$tefct[1],$tefct[2],$tefct[3],$tefct[4],$tefct[5],$tefct[6],$tefct[7],$tup[0],$tup[1],$tup[2],$tdw[0],$tdw[1],$tdw[2]) = split(/<>/,$skill_tech[$atc_skill1][$skpow]);
		&get_efc;
		$sklmsg = "$tdoc<br><b class=\"clit\">$tname！</b><br>$rndmsg";
		$dmg1 = int($dmg1 * $tatc / 100);
		@efct1 = @tefct;
	} else {
		$rndsk=0;$rndmsg="";
		$rndsk  = int(rand($kskl / 200));
		if($rndsk > 4){$rndsk = 4;}
		$dmg1 = int($dmg1 * (100 + $rndsk * 5) / 100);
		if($atc_skill1 > 5){
			$rndmsg = "$btl_msg[$atc_skill1][$elm1][$rndsk]<br>";
			$sklmsg = "$magic_msg[$atc_skill1][$elm1]<br>$rndmsg";
		} else {
			$sklmsg = "$attack_msg[$atc_skill1][$rndsk]<br>";
		}
	}
}

#------------#
#  技効果    #
#------------#
sub get_efc{
	if($tup[0] > 0){
		$kbuf[0] = $kbuf[0] * (1 + $tup[0] / 4);
		$efcmsg .= "<BR>攻撃力が上昇した！";
	}
	if($tup[1] > 0){
		$kbuf[1] = $kbuf[1] * (1 + $tup[1] / 4);
		$efcmsg .= "<BR>防御力が上昇した！";
	}
	if($tup[2] > 0){
		$kbuf[2] = $kbuf[2] * (1 + $tup[2] / 4);
		$efcmsg .= "<BR>速度が上昇した！";
	}
	if($tdw[0] > 0){
		$mbuf[0] = $mbuf[0] * (1 - $tdw[0] / 4);
		$efcmsg .= "<BR>攻撃力を低下させた！";
	}
	if($tdw[1] > 0){
		$mbuf[1] = $mbuf[1] * (1 - $tdw[1] / 4);
		$efcmsg .= "<BR>防御力を低下させた！";
	}
	if($tdw[2] > 0){
		$mbuf[2] = $mbuf[2] * (1 - $tdw[2] / 4);
		$efcmsg .= "<BR>速度を低下させた！";
	}
	if($tefct[5] > 0) {
		$mbuf[3] = -1 * $tefct[5];
		$efcmsg .= "<BR>凍結させた！";
	}
	if($tefct[6] > 0) {
		$mbuf[3] = -1 * $tefct[6];
		$efcmsg .= "<BR>麻痺させた！";
	}
}

#------------#
#  敵技効果  #
#------------#
sub get_mefc{
	if($mwefct == 1){
		$mbuf[0] = $mbuf[0] * (5 / 4);
		$mefcmsg .= "<BR>攻撃力が上昇した！";
	}elsif($mwefct == 2){
		$mbuf[1] = $mbuf[1] * (5 / 4);
		$mefcmsg .= "<BR>防御力が上昇した！";
	}elsif($mwefct == 3){
		$mbuf[2] = $mbuf[2] * (5 / 4);
		$mefcmsg .= "<BR>速度が上昇した！";
	}elsif($mwefct == 4){
		$kbuf[0] = $kbuf[0] * (3 / 4);
		$mefcmsg .= "<BR>攻撃力を低下させた！";
	}elsif($mwefct == 5){
		$kbuf[1] = $kbuf[1] * (3 / 4);
		$mefcmsg .= "<BR>防御力を低下させた！";
	}elsif($mwefct == 6){
		$kbuf[2] = $kbuf[2] * (3 / 4);
		$mefcmsg .= "<BR>速度を低下させた！";
	}elsif($mwefct == 7) {
		$kbuf[3] = - 2;
		$mefcmsg .= "<BR>凍結させた！";
	}elsif($mwefct == 8) {
		$kbuf[3] = - 2;
		$mefcmsg .= "<BR>麻痺させた！";
	}
}

#------------------#
#    属性値算出    #
#------------------#
sub elm_judge {
	($eelm[0],$eelm[1],$eelm[2],$eelm[3],$eelm[4],$eelm[5],$eelm[6]) = split(/<>/,$elm_efect[$delm]);
	$eefe = $eelm[$aelm];
}

1;
