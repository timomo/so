#------------------#
#    金額計算      #
#------------------#
sub money_get {

	&get_host;
	$date = time();

	# ファイルロック
	if ($lockkey == 1) { &lock1; }
	elsif ($lockkey == 2) { &lock2; }
	elsif ($lockkey == 3) { &file'lock; }

	open(IN,"$chara_file");
	@money = <IN>;
	close(IN);

	@money_new=();@sn=();
	foreach(@money){
		($sid,$spass,$sname,$ssex,$schara,$sn[0],$sn[1],$sn[2],$sn[3],$sn[4],$sn[5],$sn[6],$shp,$smaxhp,$sex,$slv,$sap,$sgold,$slp,$stotal,$skati,$shost,$sdate,$sarea,$sspot,$spst,$sitem) = split(/<>/);
		if($in{'id'} eq "$sid") {
			$tgold = $sgold + $ggold;
			if($tgold < 0) {
				$error = "所持金が足りません。";
				$mode = "log_in";
				&log_in;
			}
			if($bflag == 1){$sdate = $date}
			unshift(@money_new,"$sid<>$spass<>$sname<>$ssex<>$schara<>$sn[0]<>$sn[1]<>$sn[2]<>$sn[3]<>$sn[4]<>$sn[5]<>$sn[6]<>$shp<>$smaxhp<>$sex<>$slv<>$sap<>$tgold<>$slp<>$stotal<>$skati<>$host<>$sdate<>$sarea<>$sspot<>$spst<>$sitem<>\n");
		}else{
			push(@money_new,"$_");
		}
	}

	open(OUT,">$chara_file");
	print OUT @money_new;
	close(OUT);

	# ロック解除
	if ($lockkey == 3) { &file'unlock; }
	else { if(-e $lockfile) { unlink($lockfile); } }
}

#------------------#
#  銀行データ読込  #
#------------------#
sub read_bank {
	open(IN,"$bank_file");
	@bank = <IN>;
	close(IN);

	$hit=0;@bank_new=();
	foreach(@bank){
		($bid,$bpgold,$brgold,$bpitem,$bmsg) = split(/<>/);
		if($rid eq "$bid") {
			$kpgold = $brgold;
			$krgold  = $brgold;
			$kpitem = $bpitem;
			$kmsg = $bmsg;
			$hit=1;
		}
	}

	if(!$hit){$krgold = 0;}
}

#----------------------#
#  銀行金額データ書込  #
#----------------------#
sub regist_bank {

	# ファイルロック
	if ($lockkey == 1) { &lock1; }
	elsif ($lockkey == 2) { &lock2; }
	elsif ($lockkey == 3) { &file'lock; }

	open(IN,"$bank_file");
	@bank = <IN>;
	close(IN);

	$hit=0;@bank_new=();
	foreach(@bank){
		($bid,$bpgold,$brgold,$bpitem,$bmsg) = split(/<>/);
		if($kid eq "$bid") {
			# 支払い完了
			if($bflag == 0){
				$brgold = 0;
				$bmsg = "";
			} else {
				$brgold  += $krgold;
				$bpgold  += $kpgold;
				$bpitem  += $kpitem;
				if($bmsg ne ""){
					$bmsg = "$bmsg<br>$kmsg";
				} else {
					$bmsg = $kmsg;
				}
			}
			unshift(@bank_new,"$bid<>$bpgold<>$brgold<>$bpitem<>$bmsg<>\n");
		$hit=1;
		}else{
			push(@bank_new,"$_");
		}
	}

	if(!$hit){
		unshift(@bank_new,"$kid<>$kpgold<>$krgold<>$kpitem<>$kmsg<>\n");
	}

	open(OUT,">$bank_file");
	print OUT @bank_new;
	close(OUT);

	# ロック解除
	if ($lockkey == 3) { &file'unlock; }
	else { if(-e $lockfile) { unlink($lockfile); } }
}

#----------------------#
#  銀行持物データ書込  #
#----------------------#
sub in_bank {

	# ファイルロック
	if ($lockkey == 1) { &lock1; }
	elsif ($lockkey == 2) { &lock2; }
	elsif ($lockkey == 3) { &file'lock; }

	open(IN,"$bank_file");
	@bank = <IN>;
	close(IN);

	$hit=0;@bank_new=();
	foreach(@bank){
		($bid,$bpgold,$brgold,$bpitem,$bmsg) = split(/<>/);
		if($kid eq "$bid") {
			unshift(@bank_new,"$bid<>$bpgold<>$brgold<>$kpitem<>$bmsg<>\n");
		$hit=1;
		}else{
			push(@bank_new,"$_");
		}
	}

	if(!$hit){
		unshift(@bank_new,"$kid<>0<>0<>$kpitem<><>\n");
	}

	open(OUT,">$bank_file");
	print OUT @bank_new;
	close(OUT);

	# ロック解除
	if ($lockkey == 3) { &file'unlock; }
	else { if(-e $lockfile) { unlink($lockfile); } }
}

1;
