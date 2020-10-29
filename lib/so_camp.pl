use utf8;

#--------#
#  休憩  #
#--------#
sub rest {
	if($battle_flag) { &error("現在行動中です。お待ち下さい。"); }

	@battle = &load_ini($chara_file);

	$hit=0;
	foreach(@battle){
		($kid,$kpass,$kname,$ksex,$kchara,$kn_0,$kn_1,$kn_2,$kn_3,$kn_4,$kn_5,$kn_6,$khp,$kmaxhp,$kex,$klv,$kap,$kgold,$klp,$ktotal,$kkati,$khost,$kdate,$karea,$kspot,$kpst,$kitem) = split(/<>/);
		if($in{'id'} eq "$kid" and $in{'pass'} eq "$kpass") {
			$hit=1;
			last;
		}
	}

	if(!$hit) { &error("入力されたIDは登録されていません。又はパスワードが違います。"); }
	if($kspot == 0 && $kpst == 0) { &error("不正なパラメータです。"); }

	$ltime = time();
	$ltime = $ltime - $kdate;
	$vtime = $b_time - $ltime;
	$mtime = $m_time - $ltime;

	if($ltime < $m_time and $ktotal) {
		$error = "$mtime秒後に行動できます。";
		$mode = "log_in";
		&log_in;
	}

	$kdate = time();

	&skill_load;

	$krcv = 5;
	&camp_gain;
	$movemsg = "$kskm休憩し、HPが<B>$rcvhp</B>、リスクが<B>$rcvrsk%</B> 回復しました。";
	&event;
	$mode = "log_in";
	&log_in;
}

#------------#
#  キャンプ  #
#------------#
sub camp {
	$kdate = time();

	$krcv = 20;
	&camp_gain;
	$movemsg = "$kskmキャンプを行い、HPが<B>$rcvhp</B>、リスクが<B>$rcvrsk%</B> 回復しました。";
	if(int(rand(2)) == 0){
		&event;
		$mode = "log_in";
		&log_in;
	}
	$kbuff[3] = -1 * int(rand(4));
	if($kbuff[3] < 0){
		$movemsg .= "<p>寝込みを襲われた！";
	} else {
		$movemsg .= "<p>寝込みを襲われたが、$kname は反応し、飛び起きた！";
	}
}

#------------#
#  休憩処理  #
#------------#
sub camp_gain {
	&skill_up(19,int(($ksk[19] - $ksk[19] / 10) / 20));

	$rcvhp = int($kmaxhp / 20 + rand($kmaxhp / 10) + $krcv * ($ksk[19] / 50));
	if(10 > $rcvhp){
		$rcvhp = 10;
	}
	$khp += $rcvhp;
	if($khp > $kmaxhp){
		$khp = $kmaxhp;
	}

	$rid = $kid;
	&read_buff;

	$buff_flg = 0;
	$rcvrsk = int($krcv / 5 + $ksk[19] / 200 + rand($ksk[19] / 200) + 1);
	$krsk = $rrsk - $rcvrsk;
	if($krsk < -50){
		$krsk = -50;
	}
	&regist_buff;

}

1;
