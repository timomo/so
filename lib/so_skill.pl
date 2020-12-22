use utf8;
#--------------#
#  スキル書込  #
#--------------#
sub skill_regist
{
	my @skill_new = ();
	my $skills = {};
	$skills->{キャラスキル現状値} ||= {};
	$skills->{キャラスキル設定値} ||= {};
	$skills->{キャラスキル最大値} ||= {};

	if($in{'new'} eq 'new')
	{
		my $cnt=0;
		my @sk=();

		foreach (0 .. @chara_skill)
		{
			$sk[$cnt] = 0;
			if($cnt eq $in{'skill1'}){
				$sk[$cnt] = 100;
			}

			if($cnt eq $in{'skill2'}){
				$sk[$cnt] = $sk[$cnt] + 50;
			}
			$cnt++;
		}

		$kid = $in{'id'};
		# unshift(@skill_new,"1000<>1000<>1000<>1000<>1000<>1000<>1000<>1000<>1000<>1000<>1000<>1000<>1000<>1000<>1000<>1000<>1000<>1000<>1000<>1000<>1000<>1000<>5000<>\n");
		# unshift(@skill_new,"0<>0<>0<>0<>0<>0<>0<>0<>0<>0<>0<>0<>0<>0<>0<>0<>0<>0<>0<>0<>0<>0<>\n");
		# unshift(@skill_new,"$sk[0]<>$sk[1]<>$sk[2]<>$sk[3]<>$sk[4]<>$sk[5]<>$sk[6]<>$sk[7]<>$sk[8]<>$sk[9]<>$sk[10]<>$sk[11]<>$sk[12]<>$sk[13]<>$sk[14]<>$sk[15]<>$sk[16]<>$sk[17]<>$sk[18]<>$sk[19]<>$sk[20]<>$sk[21]<>\n");

		for my $no (0 .. 21)
		{
			$kmx[$no] = 1000;
			$kmg[$no] = 0;
			$kmx[$no] = $sk[$no];
		}
		$kmx[22] = 5000;
	}

	@{$skills->{キャラスキル現状値}}{@{$mojo->config->{キャラスキル現状値}}} = @ksk;
	@{$skills->{キャラスキル設定値}}{@{$mojo->config->{キャラスキル設定値}}} = @kmg;
	@{$skills->{キャラスキル最大値}}{@{$mojo->config->{キャラスキル最大値}}} = (@kmx, $kmax);

	$system->save_skill_db($kid, $skills);

	# open(OUT,">", $skill_path. $kid);
	# print OUT @skill_new;
	# close(OUT);
}

#--------------#
#  スキル読出  #
#--------------#
sub skill_load
{
	my $skills = $system->load_skill_db($kid);
	@ksk=();@kmg=();@kmx=();

	if (! defined $skills->{キャラスキル現状値})
	{
		my @kskill = &load_ini($skill_path. $kid);

		($ksk[0],$ksk[1],$ksk[2],$ksk[3],$ksk[4],$ksk[5],$ksk[6],$ksk[7],$ksk[8],$ksk[9],$ksk[10],$ksk[11],$ksk[12],$ksk[13],$ksk[14],$ksk[15],$ksk[16],$ksk[17],$ksk[18],$ksk[19],$ksk[20],$ksk[21]) = split(/<>/,$kskill[0]);
		($kmg[0],$kmg[1],$kmg[2],$kmg[3],$kmg[4],$kmg[5],$kmg[6],$kmg[7],$kmg[8],$kmg[9],$kmg[10],$kmg[11],$kmg[12],$kmg[13],$kmg[14],$kmg[15],$kmg[16],$kmg[17],$kmg[18],$kmg[19],$kmg[20],$kmg[21]) = split(/<>/,$kskill[1]);
		($kmx[0],$kmx[1],$kmx[2],$kmx[3],$kmx[4],$kmx[5],$kmx[6],$kmx[7],$kmx[8],$kmx[9],$kmx[10],$kmx[11],$kmx[12],$kmx[13],$kmx[14],$kmx[15],$kmx[16],$kmx[17],$kmx[18],$kmx[19],$kmx[20],$kmx[21],$kmax) = split(/<>/,$kskill[2]);
	}
	else
	{
		@ksk = @{$skills->{キャラスキル現状値}}{@{$mojo->config->{キャラスキル現状値}}};
		@kmg = @{$skills->{キャラスキル設定値}}{@{$mojo->config->{キャラスキル設定値}}};
		(@kmx, $kmax) = @{$skills->{キャラスキル最大値}}{@{$mojo->config->{キャラスキル最大値}}};
	}
}

#--------------#
#  スキル上昇  #
#--------------#

#対象・難易度
sub skill_up
{
	# 引数を受け取る
	@tmp_skl = @_;

	&skill_load;
	$cnt = 0;
	$kskm = "";

	foreach (0 .. @chara_skill) {
		if($cnt eq $tmp_skl[0]){
			$tmp_handy = $tmp_skl[1] * 20 - $ksk[$cnt];
			if($tmp_handy > 180){$tmp_handy = 180;}
			$tmp_handy = abs($tmp_handy);
			if(($tmp_handy < 200 || $ksk[$cnt] < 200) && $kmg[$cnt] == 0){
				$tmp_handy += int((200 - $tmp_handy) * $ksk[$cnt] / 2000);
				$tmp_up = (rand(400) - $tmp_handy - 200) / 100;
				if($tmp_up > 0 || $ksk[$cnt] < 200){
					$tmp_up = 1000 - $ksk[$cnt];
					$tmp_up = int(rand($tmp_up)/200);
					if($tmp_up < 1){$tmp_up = 1}
					#スキル合計値を確認
					&skill_check;
					if(($ksk[$cnt] < 300 || $ksk[$cnt] < $kmx[$cnt]) && $tmp_up > 0){
						# 上昇前
						$aksk = $ksk[$cnt];
						$ksk[$cnt] = $ksk[$cnt] + $tmp_up;
						# 上昇後
						$bksk = $ksk[$cnt];
						$scnt = $cnt;
						$tmp_up = $tmp_up / 10;
						$kskm = "$chara_skill[$cnt] が $tmp_up 上昇！<p>";
						&skill_grow;
						if($delskl != 99){
							$kskm .= "$chara_skill[$delskl] が $tmp_up 減少！<p>";
							$ksk[$delskl] = $ksk[$delskl] - $tmp_up * 10;
						}
					} elsif($tmp_up != 0) {
						$kskm = "$chara_skill[$cnt] は限界に達した！<p>";
						$ksk[$cnt] = $kmx[$cnt];
					} else {
						$kskm = "スキル合計が限界に達した！<p>";
					}
					&skill_regist;
				}
				last;
			}
		}
		$cnt++;
	}
}

#--------------#
# 合計チェック #
#--------------#

sub skill_check
{
	$cttl = 0;
	$mttl = 0;
	$ccnt = 0;
	$delskl = 99;
	foreach (0 .. @chara_skill) {
		$cttl += $ksk[$ccnt];
		if($kmg[$ccnt] == 1 && $delskl == 99 && $ksk[$ccnt] > 0){$delskl = $ccnt;}
		$ccnt++;
	}
	if($kmax - $cttl <= 0){
		if($delskl == 99){
			$tmp_up = 0;
		} elsif($ksk[$delskl] < $tmp_up){
			$tmp_up = $ksk[$delskl];
		}
	} elsif($kmax - $cttl - $tmp_up < 0){
		$tmp_up = $kmax - $cttl;
		$delskl = 99;
	} else {
		$delskl = 99;
	}
}

#--------------#
#    技取得    #
#--------------#

sub skill_grow
{
	#武器スキルの十の位が一つ上がった場合
	if (int($aksk / 200) < int($bksk / 200) && $scnt < 6 && int($bksk / 200) < 5){
		($tname) = split(/<>/,$skill_tech[$scnt][int($bksk / 200)]);
		$kskm .= "<b>$tnameを閃いた！</b><p>";
	}
}

#--------------#
#  スキル管理  #
#--------------#

sub skill_manage
{
	@skill_chara = &load_ini($chara_file);

	$hit=0;
	foreach(@skill_chara){
		($kid,$kpass,$kname,$ksex,$kchara,$kn_0,$kn_1,$kn_2,$kn_3,$kn_4,$kn_5,$kn_6,$khp,$kmaxhp,$kex,$klv,$kap,$kgold,$klp,$ktotal,$kkati,$khost,$kdate,$karea,$kspot,$kpst,$kitem) = split(/<>/);
		if($in{'id'} eq "$kid" and $in{'pass'} eq "$kpass") {
			$hit=1;
			last;
		}
	}

	if(!$hit) { &error("入力されたIDは登録されていません。又はパスワードが違います。")};

	&skill_load;

	$kmg[0] = $in{'kmg0'};
	$kmg[1] = $in{'kmg1'};
	$kmg[2] = $in{'kmg2'};
	$kmg[3] = $in{'kmg3'};
	$kmg[4] = $in{'kmg4'};
	$kmg[5] = $in{'kmg5'};
	$kmg[6] = $in{'kmg6'};
	$kmg[7] = $in{'kmg7'};
	$kmg[8] = $in{'kmg8'};
	$kmg[9] = $in{'kmg9'};
	$kmg[10] = $in{'kmg10'};
	$kmg[11] = $in{'kmg11'};
	$kmg[12] = $in{'kmg12'};
	$kmg[13] = $in{'kmg13'};
	$kmg[14] = $in{'kmg14'};
	$kmg[15] = $in{'kmg15'};
	$kmg[16] = $in{'kmg16'};
	$kmg[17] = $in{'kmg17'};
	$kmg[18] = $in{'kmg18'};
	$kmg[19] = $in{'kmg19'};
	$kmg[20] = $in{'kmg20'};
	$kmg[21] = $in{'kmg21'};

	&skill_regist;

	print &status_check;

	exit;
}

#--------------#
#  スキル成長  #
#--------------#

sub skill_gain
{
	# 引数を受け取る
	@tmp_skl = @_;
	&skill_load;
	$cnt = 0;
	$kskm = "";

	foreach (0 .. @chara_skill) {
		if($cnt eq $tmp_skl[0]){
			$kmx[$cnt] += 50;
		}
		$cnt++;
	}

	if($tmp_skl[1] > 0 && $kmax / 10 < $skill_tmax){
			$kmax += 50;
	}
	&skill_regist;
}

#--------------#
#  スキル確認  #
#--------------#

#対象・難易度
sub skill_tcheck
{
	# 引数を受け取る
	@tmp_skl = @_;
	&skill_load;
	$cnt = 0;

	foreach (0 .. @chara_skill) {
		if($cnt eq $tmp_skl[0]){
			if($kmx[$cnt] / 10 + 5 > $skill_max){
				$error = "$chara_skill[$cnt]の限界は<b>$skill_max</b>です";
				&item_check;
			}
		}
		$cnt++;
	}
}

1;
