use utf8;
#----------------#
#  所持アイテム  #
#----------------#
sub item_check {
	@user_item = &load_ini($item_path. $in{'id'});
	@item_chara = &load_ini($chara_file);

	$hit=0;
	foreach(@item_chara){
		($kid,$kpass,$kname,$ksex,$kchara,$kn_0,$kn_1,$kn_2,$kn_3,$kn_4,$kn_5,$kn_6,$khp,$kmaxhp,$kex,$klv,$kap,$kgold,$klp,$ktotal,$kkati,$khost,$kdate,$karea,$kspot,$kpst,$kitem) = split(/<>/);
		if($in{'id'} eq "$kid" and $in{'pass'} eq "$kpass") {
			$hit=1;
			last;
		}
	}

	if(!$hit) { &error("入力されたIDは登録されていません。又はパスワードが違います。"); }

	$rid = $kid;
	&read_bank;
	$space_price = int($kpitem / 5) + 1;

	#割増率の設定
	$plus = 1 + $kn_6 / 200;

	&header;

	print <<"EOM";
<b>$kname の所持品</b>
<hr size=0>
$msg<B><FONT COLOR="#FF9933">$error</FONT></B>
<p>
<form action="$script" method="post">
使用・装備したいアイテムをチェックしてください。<BR>
<BR>
<B>所持アイテム数</B> $kitem / $max_item<BR>
<BR>
<table border=1>
<tr>
<th></th><th>装備</th><th>種別</th><th>名前</th><th>効果</th><th>価値</th><th>使用</th><th>装備条件</th><th>属性</th><th>耐久</th><th>品質</th><th>作成者</th><th>所持数</th>
EOM
	$msg = "";$error = "";
	foreach(@user_item){
		($iid,$ino,$iname,$idmg,$igold,$imode,$iuelm,$ieelm,$ihand,$idef,$ireq,$iqlt,$imake,$irest,$ieqp) = split(/<>/);
		$igold = int($igold * $plus / 2);
		&check_limit;
		# アイテム種別により処理変更
		if ($imode == 01) {
			$idmg = "<font color=$efcolor[2]>HP回復：$idmg</font>";
			$ireq = "&nbsp;";
		} elsif ($imode == 02) {
			$idmg = "<font color=$efcolor[2]>LP回復：$idmg</font>";
			$ireq = "&nbsp;";
		} elsif ($imode == 03) {
			$idmg = "移動する";
			$ireq = "&nbsp;";
		} elsif ($imode == 04) {
			$idmg = "<font color=$efcolor[2]>$chara_skill[$idmg]</font>";
			$ireq = "&nbsp;";
		} elsif ($imode == 05) {
			$idmg = "素材";
			$ireq = "&nbsp;";
		} elsif ($imode == 07) {
			$idmg = "<font color=$efcolor[2]>治療：$idmg</font>";
			$ireq = "&nbsp;";
		} elsif (10 <= $imode && $imode < 20) {
			$idmg = "<font color=$efcolor[0]>攻撃：$idmg</font>";
			$ireq = "<font color=$reqcolor>$item_uelm[$iuelm]：$ireq</font>";
		} elsif (20 <= $imode && $imode < 30) {
			$idmg = "<font color=$efcolor[0]>攻撃：$idmg</font>";
			$ireq = "<font color=$reqcolor>$item_uelm[$iuelm]：$ireq</font>";
		} elsif (30 <= $imode && $imode < 40) {
			$idmg = "<font color=$efcolor[1]>防御：$idmg</font>";
			$ireq = "<font color=$reqcolor>力：$ireq</font>";
		} elsif (40 <= $imode && $imode < 50) {
			$idmg = "<font color=$efcolor[1]>防御：$idmg</font>";
			$ireq = "<font color=$reqcolor>力：$ireq</font>";
		} elsif (50 <= $imode && $imode < 60) {
			$idmg = "<font color=$efcolor[1]>回避：$idmg</font>";
			$ireq = "<font color=$reqcolor>力：$ireq</font>";
		} elsif (60 <= $imode && $imode < 70) {
			$idmg = "<font color=$efcolor[2]>補助：$idmg</font>";
			$ireq = "<font color=$reqcolor>$item_uelm[$iuelm]：$ireq</font>";
		} elsif (70 <= $imode && $imode < 80) {
			$idmg = "<font color=$efcolor[0]>攻撃：$idmg</font>";
			$ireq = "<font color=$reqcolor>$item_uelm[$iuelm]：$ireq</font>";
		} else {
			$idmg = "&nbsp";
			$ireq = "&nbsp;";
		}
		print "<tr>\n";
		print "<td><input type=radio name=item_no value=\"$iid\"></td><td align=center>$item_eqp[$ieqp]</td><td align=center>$item_mode[$imode]</td><td>$iname</td><td align=center>$idmg</td><td align=center>$igold G</td><td align=center>$item_hand[$ihand]</td><td align=center>$ireq</td><td align=center><font color=$elmcolor[$ieelm]>$item_eelm[$ieelm]</font></td><td align=center>$item_def[$idef]</td><td align=center>$item_qlt[$iqlt]</td><td align=center>$imake</td><td align=center>$irest 個</td>\n";
		print "</tr>\n";
	}

	print <<"EOM";
</tr>
</table>
<p>
<input type=hidden name=id   value=$in{'id'}>
<input type=hidden name=pass value=$in{'pass'}>
<select name=mode>
	<option value=item_use>使うor装備or装備解除
	<option value=item_battle>薬・治療アイテムを戦闘用に携帯
EOM
if($kspot == 0 && $kpst == 0){
	print "<option value=item_sell>ショップに売却\n";
	print "<option value=user_sell>自由市場に出品\n";
	print "<option value=bank_in>貸し金庫に預ける\n";
	print "<option value=bank_send>アイテムを他人に送る\n";
	print "<option value=bank_money>お金を他人に送る\n";
} else {
	print "<option value=item_sell>アイテムを捨てる\n";
}
	print <<"EOM";
</select>
&nbsp;<select name=sendid>
<option value="">送る相手を選択
EOM

	@MESSAGE = &load_ini($chara_file);

	foreach(@MESSAGE) {
		($did,$dpass,$dname,$dsex,$dchara,$dn_0,$dn_1,$dn_2,$dn_3,$dn_4,$dn_5,$dn_6,$dhp,$dmaxhp,$dex,$dlv,$dap,$dgold,$dlp,$dtotal,$dkati,$dhost,$ddate,$darea,$dspot,$dpst,$ditem) = split(/<>/);
		if($kid eq $did) { next; }
		print "<option value=$did>$dname\n";
	}

	print <<"EOM";
</select>
<input type=submit value="OK">
<br>
個数&nbsp;
<select name="item">
EOM
	$i=1;
	foreach(1..$max_itemcnt){
		print "<option value=\"$i\">$i\n";
		$i++;
	}
		print <<"EOM";
</select>&nbsp;個
&nbsp;金額&nbsp;<input type=text name=gold  size="11" value="">&nbsp;G&nbsp;/&nbsp;$kgold&nbsp;G
<br>
※ショップで売却する場合は各アイテムの「価値」で買い取られます。<br>
　自由市場に出品の際は、「金額」は単価になります。<br>
　現在の貸し金庫の手数料は「価値」の<b> $space_price </b>% です。
</form>
<p>
EOM

	&footer;

	exit;
}

#----------------#
#  アイテム取得  #
#----------------#
sub item_drop
{
	$mrand = int(rand(5));

	@drop = &load_ini($drop_file);

	$hit=0;
	foreach(@drop){
		($g_type,$g_rnd,$g_no,$g_name,$g_qlt) = split(/<>/);
		if($g_type == $mdrop && $g_rnd == $mrand){
			$hit=1;
			last;
		}
	}

	if(!$hit) { &error("アイテム取得エラー"); }

	@get = &load_ini($item_file);

	$hit=0;
	foreach(@get){
		($i_no,$i_name,$i_dmg,$i_gold,$i_mode,$i_uelm,$i_eelm,$i_hand,$i_def,$i_req,$i_qlt,$i_make) = split(/<>/);
		if($i_no == $g_no && $i_qlt == $g_qlt){
			$kcnt = 1;
			&item_regist;
			$hit=1;
			last;
		}
	}

	if(!$hit) { &error("アイテム書き込みエラー"); }
}

#----------------#
#  ストーン取得  #
#----------------#
sub stone_drop
{
	$srand = int(rand(@chara_skill));

	@get = &load_ini($item_file);

	$hit=0;
	foreach(@get){
		($i_no,$i_name,$i_dmg,$i_gold,$i_mode,$i_uelm,$i_eelm,$i_hand,$i_def,$i_req,$i_qlt,$i_make) = split(/<>/);
		if($i_no eq $stone_no){
			$i_dmg = $srand;

			if(int(rand(5)) > 0){
				$i_name = "$chara_skill[$srand]の宝珠";
				$i_gold = 500;
			} else {
				$i_name = "$chara_skill[$srand]の霊石";
				$i_qlt = 1;
				$i_gold = 1000;
			}

			if($srand > 9){
				$i_no = "04$srand";
			} else {
				$i_no = "040$srand";
			}
			$kcnt = 1;
			&item_regist;
			$hit=1;
			last;
		}
	}

	if(!$hit) { &error("アイテム書き込みエラー"); }
}

#----------------#
#  アイテム書込  #
#----------------#
sub item_regist
{
	@user_item = &load_ini($item_path. $kid);

	$u_flag = 0;$u_cnt = 0;$i_eqp = 0;$over = 0;
	@new_user_item=();

	foreach(@user_item)
	{
		($u_id,$u_no,$u_name,$u_dmg,$u_gold,$u_mode,$u_uelm,$u_eelm,$u_hand,$u_def,$u_req,$u_qlt,$u_make,$u_rest,$u_eqp) = split(/<>/);
		if("$u_no$u_qlt$u_make" eq "$i_no$i_qlt$i_make") {
			$u_rest += $kcnt;
			if($u_rest > $max_itemcnt && $mode eq 'item_buy') {
				$error = "$max_itemcnt 個までしか所持できません";
				&item_shop;
			}elsif($u_rest > $max_itemcnt && $mode eq 'user_buy') {
				$error = "$max_itemcnt 個までしか所持できません";
				&user_shop;
			}elsif($u_rest > $max_itemcnt) {
				$u_rest = $max_itemcnt;
				$over = 1;
			}
			$u_flag = 1;
		}

		my $mes = "$u_id<>$u_no<>$u_name<>$u_dmg<>$u_gold<>$u_mode<>$u_uelm<>$u_eelm<>$u_hand<>$u_def<>$u_req<>$u_qlt<>$u_make<>$u_rest<>$u_eqp<>\n";
		my $utf8 = Encode::encode_utf8($mes);

		unshift(@new_user_item, $utf8);

		$u_cnt++;
	}

	if($u_flag eq 0 && $in{'new'} ne 'new'){
		my $mes = "$u_cnt<>$i_no<>$i_name<>$i_dmg<>$i_gold<>$i_mode<>$i_uelm<>$i_eelm<>$i_hand<>$i_def<>$i_req<>$i_qlt<>$i_make<>$kcnt<>$i_eqp<>\n";
		my $utf8 = Encode::encode_utf8($mes);
		unshift(@new_user_item,$mes);
		$u_cnt++;
	}

	if($in{'new'} eq 'new'){
		unshift(@new_user_item,$newbie_equip[$in{'skill1'}]);
		unshift(@new_user_item,$newbie_equip[99]);
		$u_flag = 1;
	}

	open(OUT,">$item_path$kid");
	print OUT @new_user_item;
	close(OUT);

	&item_sort;

}

#----------------#
#  アイテム使用  #
#----------------#
sub item_use
{
	@user_item = &load_ini($item_path. $in{'id'});

	if($in{'item_no'} eq ""){
		$error = "アイテムを選んでください。";
		&item_check;
	}

	@item_chara = &load_ini($chara_file);

	$hit=0;
	foreach(@item_chara){
		($kid,$kpass,$kname,$ksex,$kchara,$kn_0,$kn_1,$kn_2,$kn_3,$kn_4,$kn_5,$kn_6,$khp,$kmaxhp,$kex,$klv,$kap,$kgold,$klp,$ktotal,$kkati,$khost,$kdate,$karea,$kspot,$kpst,$kitem) = split(/<>/);
		if($in{'id'} eq "$kid" and $in{'pass'} eq "$kpass") {
			$hit=1;
			last;
		}
	}

	if(!$hit) { &error("入力されたIDは登録されていません。又はパスワードが違います。"); }

	$hit=0;
	foreach(@user_item){
		($i_id,$i_no,$i_name,$i_dmg,$i_gold,$i_mode,$i_uelm,$i_eelm,$i_hand,$i_def,$i_req,$i_qlt,$i_make,$i_rest,$i_eqp) = split(/<>/);
		if($in{'item_no'} eq $i_id) {
			$hit=1;
			last;
		}
	}
	if(!$hit){
		$error = "アイテムが存在しません。";
		&item_check;
	}

	$k_id = $i_id;

	if($in{'mode'} eq "item_use"){
		$k_eqp = 0;

		# アイテム種別により処理変更
		if ($i_mode == 01) {
			&item_delete;
		} elsif ($i_mode == 02) {
			&item_delete;
		} elsif ($i_mode == 03) {
			&item_delete;
		} elsif ($i_mode == 04) {
			&skill_tcheck($i_dmg);
			&item_delete;
		} elsif ($i_mode == 07) {
			&item_delete;
		} elsif (10 <= $i_mode && $i_mode < 20) {
			$k_eqp = 1;
			&equip_check;
			&item_equip;
		} elsif (20 <= $i_mode && $i_mode < 30) {
			$k_eqp = 1;
			&equip_check;
			&item_equip;
		} elsif (30 <= $i_mode && $i_mode < 40) {
			$k_eqp = 2;
			&equip_check;
			&item_equip;
		} elsif (40 <= $i_mode && $i_mode < 50) {
			$k_eqp = 3;
			&equip_check;
			&item_equip;
		} elsif (50 <= $i_mode && $i_mode < 60) {
			$k_eqp = 4;
			&equip_check;
			&item_equip;
		} elsif (60 <= $i_mode && $i_mode < 70) {
			$k_eqp = 5;
			&equip_check;
			&item_equip;
		} elsif (70 <= $i_mode && $i_mode < 80) {
			$k_eqp = 5;
			&equip_check;
			&item_equip;
		} else {
			$error = "使用or装備できるアイテムではありません。";
			&item_check;
		}
	} elsif($in{'mode'} eq "item_battle"){
		if ($i_mode == 01) {
			$k_eqp = 6;
			&item_equip;
		} elsif ($i_mode == 07) {
			$k_eqp = 6;
			&item_equip;
		} else {
			$error = "戦闘中に使用できるアイテムではありません。";
			&item_check;
		}
	} elsif($in{'mode'} eq "item_sell"){
		$btl_flg = 0;
		&item_sell;
	} elsif($in{'mode'} eq "user_sell"){
		&user_sell;
	} elsif($in{'mode'} eq "bank_in"){
		&bank_in;
	} elsif($in{'mode'} eq "bank_send"){
		&bank_send;
	}
}

#----------------#
#  アイテム装備  #
#----------------#
sub item_equip
{
	# ファイルロック
	if ($lockkey == 1) { &lock1; }
	elsif ($lockkey == 2) { &lock2; }
	elsif ($lockkey == 3) { &file'lock; }

	@item_chara = &load_ini($chara_file);

	$hit=0;
	foreach(@item_chara){
		($kid,$kpass,$kname,$ksex,$kchara,$kn_0,$kn_1,$kn_2,$kn_3,$kn_4,$kn_5,$kn_6,$khp,$kmaxhp,$kex,$klv,$kap,$kgold,$klp,$ktotal,$kkati,$khost,$kdate,$karea,$kspot,$kpst,$kitem) = split(/<>/);
		if($in{'id'} eq "$kid" and $in{'pass'} eq "$kpass") {
			$hit=1;
			last;
		}
	}

	if(!$hit) { &error("入力されたIDは登録されていません。又はパスワードが違います。"); }

	@equip_item = &load_ini($item_path. $kid);

	$d_eqp = 0;
	$eqp_flag = 0;
	$eqp_name = "";
	@new_equip_item=();
	foreach(@equip_item){
		($u_id,$u_no,$u_name,$u_dmg,$u_gold,$u_mode,$u_uelm,$u_eelm,$u_hand,$u_def,$u_req,$u_qlt,$u_make,$u_rest,$u_eqp) = split(/<>/);
		if($u_eqp eq $k_eqp){
			unshift(@new_equip_item,"$u_id<>$u_no<>$u_name<>$u_dmg<>$u_gold<>$u_mode<>$u_uelm<>$u_eelm<>$u_hand<>$u_def<>$u_req<>$u_qlt<>$u_make<>$u_rest<>$d_eqp<>\n");
			$eqp_flag += 1;
			if(!$eqp_name){
				$eqp_name = $u_name;
			}
		} elsif($u_id eq $k_id) {
			unshift(@new_equip_item,"$u_id<>$u_no<>$u_name<>$u_dmg<>$u_gold<>$u_mode<>$u_uelm<>$u_eelm<>$u_hand<>$u_def<>$u_req<>$u_qlt<>$u_make<>$u_rest<>$k_eqp<>\n");
			$eqp_flag += 2;
			$eqp_name = $u_name;
		} else {
			unshift(@new_equip_item,"$u_id<>$u_no<>$u_name<>$u_dmg<>$u_gold<>$u_mode<>$u_uelm<>$u_eelm<>$u_hand<>$u_def<>$u_req<>$u_qlt<>$u_make<>$u_rest<>$u_eqp<>\n");
		}
	}
	open(OUT,">$item_path$kid");
	print OUT @new_equip_item;
	close(OUT);

	&item_sort;

	# ロック解除
	if ($lockkey == 3) { &file'unlock; }
	else { if(-e $lockfile) { unlink($lockfile); } }

	$msg = "";
	if($eqp_flag == 1){
		$msg = "$eqp_nameを装備解除しました。";
	}elsif($eqp_flag > 1){
		$msg = "$eqp_nameを装備しました。";
	}

	&item_check;
}

#----------------#
#    装備確認    #
#----------------#
sub equip_check
{
	@check_equip = &load_ini($item_path. $kid);

	$over_flag = 0;
	$wep_hand = 0;
	$def_hand = 0;
	foreach(@check_equip){
		($c_id,$c_no,$c_name,$c_dmg,$c_gold,$c_mode,$c_uelm,$c_eelm,$c_hand,$c_def,$c_req,$c_qlt,$c_make,$c_rest,$c_eqp) = split(/<>/);
		if($c_id eq $k_id){
			if($c_eqp ne $k_eqp){
				# アイテム種別により処理変更
				if (10 <= $i_mode && $i_mode < 30) {
					&skill_load;
					$i_uelm = $c_uelm;
					&get_attack;
					if($avesk / 10 < $c_req){
						$over_flag = 1;
					}
					$wep_hand = $c_hand;
				} elsif (30 <= $i_mode && $i_mode < 50) {
					if($kn_0 < $c_req){
						$over_flag = 2;
					}
				} elsif (50 <= $i_mode && $i_mode < 60) {
					if($kn_0 < $c_req){
						$over_flag = 2;
					}
					$def_hand = $c_hand;
				} elsif (60 <= $i_mode && $i_mode < 70) {
					&skill_load;
					$i_uelm = $c_uelm;
					&get_attack;
					if($avesk / 10 < $c_req){
						$over_flag = 1;
					}
				} elsif (70 <= $i_mode && $i_mode < 80) {
					&skill_load;
					$i_uelm = $c_uelm;
					&get_attack;
					if($avesk / 10 < $c_req){
						$over_flag = 1;
					}
				}
			}
		}
		if($c_eqp == 1 && $wep_hand == 0){
			$wep_hand = $c_hand;
		}elsif($c_eqp == 4 && $def_hand == 0){
			$def_hand = $c_hand;
		}

	}
	if($over_flag == 1){
		$error = "今のスキルでは使いこなせません。";
		&item_check;
	}elsif($over_flag == 2){
		$error = "重すぎて装備できません。";
		&item_check;
	}
	if($wep_hand + $def_hand > 2){
		$error = "両手武器を使用するときは盾は装備できません";
		&item_check;
	}
}

#----------------#
#    制限確認    #
#----------------#
sub check_limit
{
	$reqcolor = "$text";
	# アイテム種別により処理変更
	if (10 <= $imode && $imode < 30) {
		&skill_load;
		$i_uelm = $iuelm;
		&get_attack;
		if($avesk / 10 < $ireq){
			$reqcolor = "$down";
		}
	} elsif (30 <= $imode && $imode < 60) {
		if($kn_0 < $ireq){
			$reqcolor = "$down";
		}
	}
}

#----------------#
#  アイテム売却  #
#----------------#
sub item_sell
{
	#入国ＩＤ
	$kid = $in{'id'};
	$kpass = $in{'pass'};
	if($btl_flg == 0){
		$use_item = $in{'item'};
	} else {
		$use_item = 1;
	}

	# ファイルロック
	if ($lockkey == 1) { &lock1; }
	elsif ($lockkey == 2) { &lock2; }
	elsif ($lockkey == 3) { &file'lock; }

	@delete_item = &load_ini($item_path. $kid);

	$item_count = 0;
	$sell_flag = 0;
	$select_id   = "";
	$select_item = "";
	$select_price = 0;

	@new_delete_item=();
	foreach(@delete_item){
		($u_id,$u_no,$u_name,$u_dmg,$u_gold,$u_mode,$u_uelm,$u_eelm,$u_hand,$u_def,$u_req,$u_qlt,$u_make,$u_rest,$u_eqp) = split(/<>/);
		if($u_id eq $k_id){
			$sell_flag = 1;
			$sell_name = $u_name;
			$select_id   = "$u_no$u_qlt$u_make";
			$select_item = "$u_no<>$u_name<>$u_dmg<>$u_gold<>$u_mode<>$u_uelm<>$u_eelm<>$u_hand<>$u_def<>$u_req<>$u_qlt<>$u_make<>$use_item<>\n";
			$select_price   = $u_gold;
			if($u_rest < $use_item) {
				$error = "所持アイテムが足りません。";
				&item_check;
			}
			if($u_rest > $use_item){
				$u_rest -= $use_item;

				my $mes = "$item_count<>$u_no<>$u_name<>$u_dmg<>$u_gold<>$u_mode<>$u_uelm<>$u_eelm<>$u_hand<>$u_def<>$u_req<>$u_qlt<>$u_make<>$u_rest<>$u_eqp<>\n";
				my $utf8 = Encode::encode_utf8($mes);

				unshift(@new_delete_item,$utf8);
				$item_count++;
			}
		} else {
			my $mes = "$item_count<>$u_no<>$u_name<>$u_dmg<>$u_gold<>$u_mode<>$u_uelm<>$u_eelm<>$u_hand<>$u_def<>$u_req<>$u_qlt<>$u_make<>$u_rest<>$u_eqp<>\n";
			my $utf8 = Encode::encode_utf8($mes);

			unshift(@new_delete_item,$utf8);
			$item_count++;
		}
	}

	@item_chara = &load_ini($chara_file);

	$hit=0;@item_new=();
	foreach(@item_chara){
		($iid,$ipass,$iname,$isex,$ichara,$in_0,$in_1,$in_2,$in_3,$in_4,$in_5,$in_6,$ihp,$imaxhp,$iex,$ilv,$iap,$igold,$ilp,$itotal,$ikati,$ihost,$idate,$iarea,$ispot,$ipst,$iitem) = split(/<>/);
		if($kid eq "$iid"){
			if($btl_flg == 0){
				$kspot = $ispot;
				$kpst  = $ipst;
				if($kspot == 0 && $kpst == 0){
					#割増率の設定
					$plus = 1 + $in_6 / 200;
					$sell_price = int($select_price * $plus / 2) * $use_item;
					$igold = $igold + $sell_price;
				}
			}
			$iitem = $item_count;

			my $mes = "$iid<>$ipass<>$iname<>$isex<>$ichara<>$in_0<>$in_1<>$in_2<>$in_3<>$in_4<>$in_5<>$in_6<>$ihp<>$imaxhp<>$iex<>$ilv<>$iap<>$igold<>$ilp<>$itotal<>$ikati<>$ihost<>$idate<>$iarea<>$ispot<>$ipst<>$iitem<>\n";
			my $utf8 = Encode::encode_utf8($mes);

			unshift(@item_new,$utf8);
			$hit=1;
		}else{
			push(@item_new,"$_");
		}
	}

	if(!$hit) { &error("キャラクターが見つかりません。"); }

	open(OUT,">$chara_file");
	print OUT @item_new;
	close(OUT);

	open(OUT,">$item_path$kid");
	print OUT @new_delete_item;
	close(OUT);

	&item_sort;

	# ロック解除
	if ($lockkey == 3) { &file'unlock; }
	else { if(-e $lockfile) { unlink($lockfile); } }

	$msg = "";
	if($sell_flag == 1 && $btl_flg == 0){
		if($kspot == 0 && $kpst == 0){
			$msg = "$sell_nameをを$use_item 個$sell_price Gで売却しました。";
		} else {
			$msg = "$sell_nameを$use_item 個捨てました。";
		}
	}

	if($btl_flg == 0){
		&item_check;
	}
}

#----------------#
#  アイテム出品  #
#----------------#
sub user_sell
{
	#入国ＩＤ
	$kid = $in{'id'};
	$kpass = $in{'pass'};
	$kitem = $in{'item'};
	$sell_gold = $in{'gold'};

	if ($sell_gold =~ m/[^0-9]/ || $sell_gold eq ""){
		$error = "金額は数字で入力してください。";
		&item_check;
	}

	# ファイルロック
	if ($lockkey == 1) { &lock1; }
	elsif ($lockkey == 2) { &lock2; }
	elsif ($lockkey == 3) { &file'lock; }

	@delete_item = &load_ini($item_path. $kid);

	$item_count = 0;
	$sell_flag = 0;
	$select_id   = "";
	$select_item = "";
	$select_price = 0;

	@new_delete_item=();
	foreach(@delete_item){
		($u_id,$u_no,$u_name,$u_dmg,$u_gold,$u_mode,$u_uelm,$u_eelm,$u_hand,$u_def,$u_req,$u_qlt,$u_make,$u_rest,$u_eqp) = split(/<>/);
		if($u_id eq $k_id){
			$sell_flag = 1;
			$sell_name = $u_name;
			$select_id   = "$u_no$u_qlt$u_make$kid";
			$select_item = "$u_no<>$u_name<>$u_dmg<>$sell_gold<>$u_mode<>$u_uelm<>$u_eelm<>$u_hand<>$u_def<>$u_req<>$u_qlt<>$u_make<>$kitem<>$kid<>\n";
			$select_price   = $sell_gold;
			if($u_rest < $kitem) {
				$error = "所持アイテムが足りません。";
				&item_check;
			}
			if($u_rest > $kitem){
				$u_rest -= $kitem;

				my $mes = "$item_count<>$u_no<>$u_name<>$u_dmg<>$u_gold<>$u_mode<>$u_uelm<>$u_eelm<>$u_hand<>$u_def<>$u_req<>$u_qlt<>$u_make<>$u_rest<>$u_eqp<>\n";
				my $utf8 = Encode::encode_utf8($mes);

				unshift(@new_delete_item,$utf8);
				$item_count++;
			}
		} else {
			my $mes = "$item_count<>$u_no<>$u_name<>$u_dmg<>$u_gold<>$u_mode<>$u_uelm<>$u_eelm<>$u_hand<>$u_def<>$u_req<>$u_qlt<>$u_make<>$u_rest<>$u_eqp<>\n";
			my $utf8 = Encode::encode_utf8($mes);
			unshift(@new_delete_item,$utf8);
			$item_count++;
		}
	}

	@item_chara = &load_ini($chara_file);

	$hit=0;@item_new=();
	foreach(@item_chara){
		($iid,$ipass,$iname,$isex,$ichara,$in_0,$in_1,$in_2,$in_3,$in_4,$in_5,$in_6,$ihp,$imaxhp,$iex,$ilv,$iap,$igold,$ilp,$itotal,$ikati,$ihost,$idate,$iarea,$ispot,$ipst,$iitem) = split(/<>/);
		if($kid eq "$iid"){
			$kspot = $ispot;
			$kpst  = $ipst;
			open(IN,"$user_shop[$iarea]");
			@item_array = <IN>;
			close(IN);

			@sell_item=();
			$new_item = 0;
			foreach(@item_array){
				($i_no,$i_name,$i_dmg,$i_gold,$i_mode,$i_uelm,$i_eelm,$i_hand,$i_def,$i_req,$i_qlt,$i_make,$i_rest,$i_id) = split(/<>/);
				if($select_id eq "$i_no$i_qlt$i_make$i_id") {
					$i_rest += $kitem;
					$new_item=1;
					$i_gold = $select_price;
					$i_id = $kid;
				}

				my $mes = "$i_no<>$i_name<>$i_dmg<>$i_gold<>$i_mode<>$i_uelm<>$i_eelm<>$i_hand<>$i_def<>$i_req<>$i_qlt<>$i_make<>$i_rest<>$i_id<>\n";
				my $utf8 = Encode::encode_utf8($mes);

				unshift(@sell_item,$utf8);
			}
			if($new_item == 0) {
				unshift(@sell_item,$select_item);
			}
			open(OUT,">$user_shop[$iarea]");
			print OUT @sell_item;
			close(OUT);

			&shop_sort;
			$iitem = $item_count;

			my $mes = "$iid<>$ipass<>$iname<>$isex<>$ichara<>$in_0<>$in_1<>$in_2<>$in_3<>$in_4<>$in_5<>$in_6<>$ihp<>$imaxhp<>$iex<>$ilv<>$iap<>$igold<>$ilp<>$itotal<>$ikati<>$ihost<>$idate<>$iarea<>$ispot<>$ipst<>$iitem<>\n";
			my $utf8 = Encode::encode_utf8($mes);

			unshift(@item_new,$utf8);
			$hit=1;
		}else{
			push(@item_new,"$_");
		}
	}

	if(!$hit) { &error("キャラクターが見つかりません。"); }

	open(OUT,">$chara_file");
	print OUT @item_new;
	close(OUT);

	open(OUT,">$item_path$kid");
	print OUT @new_delete_item;
	close(OUT);

	&item_sort;

	# ロック解除
	if ($lockkey == 3) { &file'unlock; }
	else { if(-e $lockfile) { unlink($lockfile); } }

	$msg = "";
	if($sell_flag == 1){
		$msg = "$sell_nameを$kitem 個$select_price Gで出品しました。";
	}

	&item_check;
}

#------------#
#  銀行預け  #
#------------#
sub bank_in
{
	#入国ＩＤ
	$kid = $in{'id'};
	$kpass = $in{'pass'};
	$kitem = $in{'item'};

	# ファイルロック
	if ($lockkey == 1) { &lock1; }
	elsif ($lockkey == 2) { &lock2; }
	elsif ($lockkey == 3) { &file'lock; }

	@delete_item = &load_ini($item_path. $kid);

	$item_count = 0;
	$sell_flag = 0;
	$select_id   = "";
	$select_item = "";

	@new_delete_item=();
	foreach(@delete_item){
		($u_id,$u_no,$u_name,$u_dmg,$u_gold,$u_mode,$u_uelm,$u_eelm,$u_hand,$u_def,$u_req,$u_qlt,$u_make,$u_rest,$u_eqp) = split(/<>/);
		if($u_id eq $k_id){
			$sell_flag = 1;
			$sell_name = $u_name;
			$sell_gold = $u_gold;
			$select_id   = "$u_no$u_qlt$u_make";
			$select_item = "$kid<>$u_no<>$u_name<>$u_dmg<>$u_gold<>$u_mode<>$u_uelm<>$u_eelm<>$u_hand<>$u_def<>$u_req<>$u_qlt<>$u_make<>$kitem<>\n";
			if($u_rest < $kitem) {
				$error = "所持アイテムが足りません。";
				&item_check;
			}
			if($u_rest > $kitem){
				$u_rest -= $kitem;

				my $mes = "$item_count<>$u_no<>$u_name<>$u_dmg<>$u_gold<>$u_mode<>$u_uelm<>$u_eelm<>$u_hand<>$u_def<>$u_req<>$u_qlt<>$u_make<>$u_rest<>$u_eqp<>\n";
				my $utf8 = Encode::encode_utf8($mes);

				unshift(@new_delete_item,$utf8);
				$item_count++;
			}
		} else {
			my $mes = "$item_count<>$u_no<>$u_name<>$u_dmg<>$u_gold<>$u_mode<>$u_uelm<>$u_eelm<>$u_hand<>$u_def<>$u_req<>$u_qlt<>$u_make<>$u_rest<>$u_eqp<>\n";
			my $utf8 = Encode::encode_utf8($mes);

			unshift(@new_delete_item,$utf8);
			$item_count++;
		}
	}

	@item_chara = &load_ini($chara_file);

	$hit=0;@item_new=();
	foreach(@item_chara){
		($iid,$ipass,$iname,$isex,$ichara,$in_0,$in_1,$in_2,$in_3,$in_4,$in_5,$in_6,$ihp,$imaxhp,$iex,$ilv,$iap,$igold,$ilp,$itotal,$ikati,$ihost,$idate,$iarea,$ispot,$ipst,$iitem) = split(/<>/);
		if($kid eq "$iid"){
			#割増率の設定
			$plus = 1 + $in_6 / 200;

			$rid = $iid;
			&read_bank;
			$space_price = int($kpitem / 5) + 1;
			$bank_gold =int($sell_gold * $plus * $space_price / 200) * $kitem;
			if($bank_gold < 1){ $bank_gold = 1; }
			if($igold < $bank_gold) {
				$error = "所持金が足りません。";
				&item_check;
			}

			$igold -= $bank_gold;

			$kid   = $iid;
			$kspot = $ispot;
			$kpst  = $ipst;

			open(IN,"$bank_path$kid");
			@item_array = <IN>;
			close(IN);

			@sell_item=();
			$new_item = 0;
			foreach(@item_array){
				($i_id,$i_no,$i_name,$i_dmg,$i_gold,$i_mode,$i_uelm,$i_eelm,$i_hand,$i_def,$i_req,$i_qlt,$i_make,$i_rest) = split(/<>/);
				if($select_id eq "$i_no$i_qlt$i_make") {
					$i_rest += $kitem;
					$new_item=1;
				}

				my $mes = "$i_id<>$i_no<>$i_name<>$i_dmg<>$i_gold<>$i_mode<>$i_uelm<>$i_eelm<>$i_hand<>$i_def<>$i_req<>$i_qlt<>$i_make<>$i_rest<>\n";
				my $utf8 = Encode::encode_utf8($mes);

				unshift(@sell_item,$utf8);
			}
			if($new_item == 0) {
				unshift(@sell_item,$select_item);
			}

			open(OUT,">$bank_path$kid");
			print OUT @sell_item;
			close(OUT);

			$iid = $kid;
			&bank_sort;
			&read_bank;
			$kpitem = $bcnt;
			&in_bank;

			$iitem = $item_count;

			my $mes = "$iid<>$ipass<>$iname<>$isex<>$ichara<>$in_0<>$in_1<>$in_2<>$in_3<>$in_4<>$in_5<>$in_6<>$ihp<>$imaxhp<>$iex<>$ilv<>$iap<>$igold<>$ilp<>$itotal<>$ikati<>$ihost<>$idate<>$iarea<>$ispot<>$ipst<>$iitem<>\n";
			my $utf8 = Encode::encode_utf8($mes);

			unshift(@item_new,$utf8);
			$hit=1;
		}else{
			push(@item_new,"$_");
		}
	}

	if(!$hit) { &error("キャラクターが見つかりません。"); }

	open(OUT,">$chara_file");
	print OUT @item_new;
	close(OUT);

	open(OUT,">$item_path$kid");
	print OUT @new_delete_item;
	close(OUT);

	&item_sort;

	# ロック解除
	if ($lockkey == 3) { &file'unlock; }
	else { if(-e $lockfile) { unlink($lockfile); } }

	$msg = "";
	if($sell_flag == 1){
		$msg = "$sell_nameを$kitem 個 手数料 $bank_gold Gで貸し金庫に預けました。";
	}

	&item_check;
}

#------------#
#  銀行送信  #
#------------#
sub bank_send
{
	if($in{'sendid'} eq ""){
		$error = "相手が指定されていません。";
		&item_check;
	}

	#入国ＩＤ
	$kid = $in{'id'};
	$kpass = $in{'pass'};
	$kitem = $in{'item'};

	$send_id = $in{'sendid'};

	# ファイルロック
	if ($lockkey == 1) { &lock1; }
	elsif ($lockkey == 2) { &lock2; }
	elsif ($lockkey == 3) { &file'lock; }

	@delete_item = &load_ini($item_path. $kid);

	$item_count = 0;
	$sell_flag = 0;
	$select_id   = "";
	$select_item = "";

	@new_delete_item=();
	foreach(@delete_item){
		($u_id,$u_no,$u_name,$u_dmg,$u_gold,$u_mode,$u_uelm,$u_eelm,$u_hand,$u_def,$u_req,$u_qlt,$u_make,$u_rest,$u_eqp) = split(/<>/);
		if($u_id eq $k_id){
			$sell_flag = 1;
			$sell_name = $u_name;
			$sell_gold = $u_gold;
			$select_id   = "$u_no$u_qlt$u_make";
			$select_item = "$kid<>$u_no<>$u_name<>$u_dmg<>$u_gold<>$u_mode<>$u_uelm<>$u_eelm<>$u_hand<>$u_def<>$u_req<>$u_qlt<>$u_make<>$kitem<>\n";
			if($u_rest < $kitem) {
				$error = "所持アイテムが足りません。";
				&item_check;
			}
			if($u_rest > $kitem){
				$u_rest -= $kitem;

				my $mes = "$item_count<>$u_no<>$u_name<>$u_dmg<>$u_gold<>$u_mode<>$u_uelm<>$u_eelm<>$u_hand<>$u_def<>$u_req<>$u_qlt<>$u_make<>$u_rest<>$u_eqp<>\n";
				my $utf8 = Encode::encode_utf8($mes);

				unshift(@new_delete_item,$utf8);
				$item_count++;
			}
		} else {
			my $mes = "$item_count<>$u_no<>$u_name<>$u_dmg<>$u_gold<>$u_mode<>$u_uelm<>$u_eelm<>$u_hand<>$u_def<>$u_req<>$u_qlt<>$u_make<>$u_rest<>$u_eqp<>\n";
			my $utf8 = Encode::encode_utf8($mes);

			unshift(@new_delete_item,$utf8);
			$item_count++;
		}
	}

	@item_chara = &load_ini($chara_file);

	$hit=0;@item_new=();
	foreach(@item_chara){
		($iid,$ipass,$iname,$isex,$ichara,$in_0,$in_1,$in_2,$in_3,$in_4,$in_5,$in_6,$ihp,$imaxhp,$iex,$ilv,$iap,$igold,$ilp,$itotal,$ikati,$ihost,$idate,$iarea,$ispot,$ipst,$iitem) = split(/<>/);
		if($send_id eq "$iid"){
			$send_name = $iname;
			$hit+=1;
		}
		if($kid eq "$iid"){
			$iitem = $item_count;

			my $mes = "$iid<>$ipass<>$iname<>$isex<>$ichara<>$in_0<>$in_1<>$in_2<>$in_3<>$in_4<>$in_5<>$in_6<>$ihp<>$imaxhp<>$iex<>$ilv<>$iap<>$igold<>$ilp<>$itotal<>$ikati<>$ihost<>$idate<>$iarea<>$ispot<>$ipst<>$iitem<>\n";
			my $utf8 = Encode::encode_utf8($mes);

			unshift(@item_new,$utf8);
			$hit+=1;

			$kid   = $send_id;
			$kspot = $ispot;
			$kpst  = $ipst;

			@item_array = &load_ini($bank_path. $kid);

			@sell_item=();
			$new_item = 0;
			foreach(@item_array){
				($i_id,$i_no,$i_name,$i_dmg,$i_gold,$i_mode,$i_uelm,$i_eelm,$i_hand,$i_def,$i_req,$i_qlt,$i_make,$i_rest) = split(/<>/);
				if($select_id eq "$i_no$i_qlt$i_make") {
					$i_rest += $kitem;
					$new_item=1;
				}

				my $mes = "$i_id<>$i_no<>$i_name<>$i_dmg<>$i_gold<>$i_mode<>$i_uelm<>$i_eelm<>$i_hand<>$i_def<>$i_req<>$i_qlt<>$i_make<>$i_rest<>\n";
				my $utf8 = Encode::encode_utf8($mes);

				unshift(@sell_item,$utf8);
			}
			if($new_item == 0) {
				unshift(@sell_item,$select_item);
			}

			open(OUT,">$bank_path$kid");
			print OUT @sell_item;
			close(OUT);

			$iid = $kid;
			&bank_sort;
			&read_bank;
			$kpitem = $bcnt;
			&in_bank;

			$kid = $in{'id'};
		}else{
			push(@item_new,"$_");
		}
	}

	if($hit < 2 ) { &error("キャラクターが見つかりません。"); }

	open(OUT,">$chara_file");
	print OUT @item_new;
	close(OUT);

	open(OUT,">$item_path$kid");
	print OUT @new_delete_item;
	close(OUT);

	&item_sort;

	# ロック解除
	if ($lockkey == 3) { &file'unlock; }
	else { if(-e $lockfile) { unlink($lockfile); } }

	$msg = "";
	if($sell_flag == 1){
		$msg = "$sell_nameを$kitem 個 $send_nameに送付しました。";
	}

	&item_check;
}

#------------#
#  銀行送金  #
#------------#
sub bank_money
{
	if($in{'sendid'} eq ""){
		$error = "相手が指定されていません。";
		&item_check;
	}

	$send_id = $in{'sendid'};
	$send_gold = $in{'gold'};

	if ($send_gold =~ m/[^0-9]/ || $send_gold eq ""){
		$error = "金額は数字で入力してください。";
		&item_check;
	}
	&get_host;
	$date = time();

	# ファイルロック
	if ($lockkey == 1) { &lock1; }
	elsif ($lockkey == 2) { &lock2; }
	elsif ($lockkey == 3) { &file'lock; }

	@money = &load_ini($chara_file);

	@money_new=();@sn=();$hit=0;
	foreach(@money){
		($sid,$spass,$sname,$ssex,$schara,$sn[0],$sn[1],$sn[2],$sn[3],$sn[4],$sn[5],$sn[6],$shp,$smaxhp,$sex,$slv,$sap,$sgold,$slp,$stotal,$skati,$shost,$sdate,$sarea,$sspot,$spst,$sitem) = split(/<>/);
		if($send_id eq "$sid"){
			$send_name = $sname;
			$hit+=1;
		}
		if($in{'id'} eq "$sid" and $in{'pass'} eq "$spass") {
			$kname = $sname;
			$kspot = $sspot;
			$kpst = $spst;
			$tgold = $sgold - $send_gold;
			if($tgold < 0) {
				$error = "所持金が足りません。";
				&item_check;
			}

			my $mes = "$sid<>$spass<>$sname<>$ssex<>$schara<>$sn[0]<>$sn[1]<>$sn[2]<>$sn[3]<>$sn[4]<>$sn[5]<>$sn[6]<>$shp<>$smaxhp<>$sex<>$slv<>$sap<>$tgold<>$slp<>$stotal<>$skati<>$host<>$sdate<>$sarea<>$sspot<>$spst<>$sitem<>\n";
			my $utf8 = Encode::encode_utf8($mes);

			unshift(@money_new,$utf8);
			$hit+=1;
		}else{
			push(@money_new,"$_");
		}
	}

	if($hit < 2) { &error("入力されたIDは登録されていません。又はパスワードが違います。"); }
	if($kspot != 0 || $kpst != 0) { &error("不正なパラメータです。"); }

	#ボーナス・賞金登録
	$kid = $send_id;
	$krgold = $send_gold;
	$kpgold = 0;$kpitem = 0;
	$kmsg = "「$kname 様より送金」 <b>$krgold</b> G";
	$bflag = 1;
	&regist_bank;

	$kid = $in{'id'};

	open(OUT,">$chara_file");
	print OUT @money_new;
	close(OUT);

	# ロック解除
	if ($lockkey == 3) { &file'unlock; }
	else { if(-e $lockfile) { unlink($lockfile); } }

	$msg = "$send_gold G を $send_nameに送付しました。";

	&item_check;
}

#------------------#
#  アイテムソート  #
#------------------#
sub item_sort
{
	#ソートし直す

	@sort_item = &load_ini($item_path. $kid);

	@tmp1 = @tmp2 = @tmp3 = ();
	foreach(@sort_item){
		($u_id,$u_no,$u_name,$u_dmg,$u_gold,$u_mode,$u_uelm,$u_eelm,$u_hand,$u_def,$u_req,$u_qlt,$u_make,$u_rest,$u_eqp) = split(/<>/);
		if($u_no != null){
			push(@tmp1, $u_no);
			push(@tmp2, $u_make);
		}
	}
	@sort_item = @sort_item[sort {$tmp1[$b] <=> $tmp1[$a] or
			$tmp2[$b] <=> $tmp2[$a]} 0 .. $#tmp1];

	@new_sort_item=();$cnt = @sort_item;
	foreach(@sort_item){
		($u_id,$u_no,$u_name,$u_dmg,$u_gold,$u_mode,$u_uelm,$u_eelm,$u_hand,$u_def,$u_req,$u_qlt,$u_make,$u_rest,$u_eqp) = split(/<>/);

		my $mes = "$cnt<>$u_no<>$u_name<>$u_dmg<>$u_gold<>$u_mode<>$u_uelm<>$u_eelm<>$u_hand<>$u_def<>$u_req<>$u_qlt<>$u_make<>$u_rest<>$u_eqp<>\n";
		my $utf8 = Encode::encode_utf8($mes);

		unshift(@new_sort_item,$utf8);
		$cnt -= 1;
	}
	open(OUT,">$item_path$kid");
	print OUT @new_sort_item;
	close(OUT);
}

#----------------#
#  アイテム消費  #
#----------------#
sub item_delete
{
	#入国ＩＤ
	$kid = $in{'id'};
	$kpass = $in{'pass'};

	# ファイルロック
	if ($lockkey == 1) { &lock1; }
	elsif ($lockkey == 2) { &lock2; }
	elsif ($lockkey == 3) { &file'lock; }

	@use_item = &load_ini($item_path. $kid);

	$item_count = 0;
	$use_flag = 1;
	$use_name = "";
	$use_pow  = 0;
	$use_mode = "";

	@new_use_item=();
	foreach(@use_item){
		($u_id,$u_no,$u_name,$u_dmg,$u_gold,$u_mode,$u_uelm,$u_eelm,$u_hand,$u_def,$u_req,$u_qlt,$u_make,$u_rest,$u_eqp) = split(/<>/);
		if($u_id eq $k_id){
			$use_flag = 1;
			$use_name = $u_name;
			$use_pow  = $u_dmg;
			$use_mode = $u_mode;
			$use_qlt  = $u_qlt;
			if($u_rest > 1){
				$u_rest -= 1;

				my $mes = "$item_count<>$u_no<>$u_name<>$u_dmg<>$u_gold<>$u_mode<>$u_uelm<>$u_eelm<>$u_hand<>$u_def<>$u_req<>$u_qlt<>$u_make<>$u_rest<>$u_eqp<>\n";
				my $utf8 = Encode::encode_utf8($mes);

				unshift(@new_use_item,$utf8);
				$item_count++;
			}
		} else {
			my $mes = "$item_count<>$u_no<>$u_name<>$u_dmg<>$u_gold<>$u_mode<>$u_uelm<>$u_eelm<>$u_hand<>$u_def<>$u_req<>$u_qlt<>$u_make<>$u_rest<>$u_eqp<>\n";
			my $utf8 = Encode::encode_utf8($mes);

			unshift(@new_use_item,$utf8);
			$item_count++;
		}
	}

	@item_chara = &load_ini($chara_file);

	$hit=0;@item_new=();
	foreach(@item_chara){
		($iid,$ipass,$iname,$isex,$ichara,$in_0,$in_1,$in_2,$in_3,$in_4,$in_5,$in_6,$ihp,$imaxhp,$iex,$ilv,$iap,$igold,$ilp,$itotal,$ikati,$ihost,$idate,$iarea,$ispot,$ipst,$iitem) = split(/<>/);
		if($kid eq "$iid"){
			if($use_mode eq "01"){
				$ihp = $ihp + $use_pow;
				if($ihp > $imaxhp){$ihp = $imaxhp;}
			}elsif($use_mode eq "02"){
				$ilp = $ilp + $use_pow;
				if($ilp > $max_lp){$ilp = $max_lp;}
			} elsif($use_mode eq "03") {
				$iarea = $use_pow;
				$ispot = 0;
				$ipst  = 0;
			} elsif($use_mode eq "04") {
				&skill_gain($use_pow,$use_qlt);
			} elsif($use_mode eq "07"){
				$rcvhp = int($use_pow * ($ksk[20]/ 1000 + rand(2) / 5 + 1) / 2);
				&skill_up(20,($imaxhp - $ihp) / 10);
				$ihp = $ihp + $rcvhp;
				if($ihp > $imaxhp){$ihp = $imaxhp;}
			}
			$iitem = $item_count;

			my $mes = "$iid<>$ipass<>$iname<>$isex<>$ichara<>$in_0<>$in_1<>$in_2<>$in_3<>$in_4<>$in_5<>$in_6<>$ihp<>$imaxhp<>$iex<>$ilv<>$iap<>$igold<>$ilp<>$itotal<>$ikati<>$ihost<>$idate<>$iarea<>$ispot<>$ipst<>$iitem<>\n";
			my $utf8 = Encode::encode_utf8($mes);

			unshift(@item_new,$utf8);
			$hit=1;
		}else{
			push(@item_new,"$_");
		}
	}

	if(!$hit) { &error("キャラクターが見つかりません。"); }

	open(OUT,">$chara_file");
	print OUT @item_new;
	close(OUT);

	open(OUT,">$item_path$kid");
	print OUT @new_use_item;
	close(OUT);

	&item_sort;

	# ロック解除
	if ($lockkey == 3) { &file'unlock; }
	else { if(-e $lockfile) { unlink($lockfile); } }

	$msg = "";
	if($use_flag == 1){
		if($use_mode eq "01"){
			$msg = "$use_nameを使用し、HPが<b>$use_pow</b>回復しました。";
		} elsif($use_mode eq "02"){
			$msg = "$use_nameを使用し、LPが<b>$use_pow</b>回復しました。";
		} elsif($use_mode eq "03"){
			$movemsg = "$use_nameを手に念じると、$town_name[$use_pow]の風景が浮かんで来て・・・<p>$town_name[$use_pow]の入り口に立っていました。";
			$mode = "log_in";
			&log_in;
			exit;
		} elsif($use_mode eq "04"){
			if($use_qlt > 0){
				$msg = "$use_nameを使用すると、$chara_skill[$use_pow]の最大値と、最大合計スキルが<b>5</b>上昇しました。";
			} else {
				$msg = "$use_nameを使用すると、$chara_skill[$use_pow]の最大値が<b>5</b>上昇しました。";
			}
		} elsif($use_mode eq "07"){
			$msg = "$kskm$use_nameを使用し、HPが<b>$rcvhp</b>回復しました。";
		}
	}

	&item_check;

}

#--------------------#
# アイテム価格再設定 #
#--------------------#
sub item_price
{
	#価格を算出
	open(IN,"$item_file");
	@item_price = <IN>;
	close(IN);

	if($i_mode eq "04"){
		$price_no = $stone_no;
	} else {
		$price_no = $i_no;
	}

	$hit=0;$kprice=0;
	foreach(@item_price){
		($p_no,$p_name,$p_dmg,$p_gold,$p_mode,$p_uelm,$p_eelm,$p_hand,$p_def,$p_req,$p_qlt,$p_make,$p_rest) = split(/<>/);
		if("$price_no$i_qlt" eq "$p_no$p_qlt") { $hit=1; $kprice = $p_gold; last; }
	}
	if(!$hit) { &error("アイテムが存在しません。"); }

}

1;
