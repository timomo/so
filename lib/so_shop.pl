use utf8;
#----------------#
#  ショップ表示  #
#----------------#
sub item_shop {

	@shop_array = &load_ini($town_shop[$in{'area'}]);
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

	if($kspot != 0 || $kpst != 0) { &error("不正なパラメータです"); }

	#割引率の設定
	$cut = 1 - $kn_6 / 200;

	&town_load;

	if($get_msg eq ""){
		$get_area=$karea;$get_id="02";$get_cnt="0";
		&get_msg;
	}

	&header;

	print <<"EOM";
<b>市場：$t_shop</b>
<hr size=0>
$get_msg<br>
$buy_msg<B><FONT COLOR="#FF9933">$error</FONT></B>
<form action="$script" method="post">
EOM
	$buy_msg = "";$error = "";
	if($kitem >= $max_item) { 
		print <<"EOM";
アイテムはこれ以上所持できません。<BR><BR>
EOM
	}
	print <<"EOM";
<B>所持金</B> $kgold G &nbsp; <B>所持アイテム数</B> $kitem / $max_item &nbsp; <a href=so_item.cgi?id=$kid&pass=$kpass  target="new">アイテム一覧</a>
<BR>
<BR>

<div class="blackboard question">

<table border=0>
<tr>
<th></th><th>種別</th><th>名前</th><th>効果</th><th>価値</th><th>使用</th><th>装備条件</th><th>属性</th><th>耐久</th><th>品質</th><th>作成者</th>
EOM
	$i=0;

	@item_array = &load_ini($item_file);

	foreach(@shop_array){
		$hit=0;
		foreach(@item_array){
			($ino,$iname,$idmg,$igold,$imode,$iuelm,$ieelm,$ihand,$idef,$ireq,$iqlt,$imake,$irest) = split(/<>/);
			$shopitem = "$ino$iqlt$imake";
			if($shop_array[$i] == $shopitem) { $hit=1;last; }
		}
		if(!$hit) { &error("アイテムが存在しません。"); }
		$i++;

		$igold = int($igold * $cut);
		&check_limit;
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
		print "<td><input type=radio name=item_no value=\"$ino$iqlt$imake\"></td><td align=center>$item_mode[$imode]</td><td>$iname</td><td align=center>$idmg</td><td align=center>$igold G</td><td align=center>$item_hand[$ihand]</td><td align=center>$ireq</td><td align=center><font color=$elmcolor[$ieelm]>$item_eelm[$ieelm]</font></td><td align=center>$item_def[$idef]</td><td align=center>$item_qlt[$iqlt]</td><td align=center>$imake</td>\n";
		print "</tr>\n";
	}

	print <<"EOM";
</tr>
</table>

</div>

<p>
<input type=hidden name=id   value=$in{'id'}>
<input type=hidden name=pass value=$in{'pass'}>
<input type=hidden name=area value=$in{'area'}>
<input type=hidden name=mode value=item_buy>
EOM
	if($kitem < $max_item) { 
	print <<"EOM";
<select name="item">
EOM
	$i=1;
	foreach(1..$max_itemcnt){
		print "<option value=\"$i\">$i\n";
		$i++;
	}
		print <<"EOM";
</select>
 個 <input type=submit value="アイテムを買う">
EOM
	}
	print <<"EOM";
</form>
<p>
		<script>
const spot = "$spot";
</script>
EOM

	&footer;

	exit;
}

#----------------#
#  自由市場表示  #
#----------------#
sub user_shop {

	@item_array = &load_ini($user_shop[$in{'area'}]);
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

	if($kspot != 0 || $kpst != 0) { &error("不正なパラメータです"); }

	&town_load;

	&header;

	print <<"EOM";
<b>市場：チュパフリマ $town_name[$karea]</b>
<hr size=0>
$buy_msg<B><FONT COLOR="#FF9933">$error</FONT></B>
<form action="$script" method="post">
EOM
	$buy_msg = "";$error = "";
	if($kitem >= $max_item) { 
		print <<"EOM";
アイテムはこれ以上所持できません。<BR><BR>
EOM
	}
	print <<"EOM";
<B>所持金</B> $kgold G &nbsp; <B>所持アイテム数</B> $kitem / $max_item &nbsp; <a href=so_item.cgi?id=$kid&pass=$kpass  target="new">アイテム一覧</a>
<BR>
<BR>

<div class="blackboard question">

<table border=0>
<tr>
<th></th><th>販売者</th><th>種別</th><th>名前</th><th>効果</th><th>価値</th><th>使用</th><th>装備条件</th><th>属性</th><th>耐久</th><th>品質</th><th>作成者</th><th>在庫</th>
EOM

	foreach(@item_array){
		($ino,$iname,$idmg,$igold,$imode,$iuelm,$ieelm,$ihand,$idef,$ireq,$iqlt,$imake,$irest,$iid) = split(/<>/);
		# アイテム種別により処理変更
		&check_limit;
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
	
		foreach(@item_chara){
			($bid,$bpass,$bname) = split(/<>/);
			if($iid eq "$bid") { last; }
		}

		if($iid eq "$kid"){ $igold = 0; }

		print "<tr>\n";
		print "<td><input type=radio name=item_no value=\"$ino$iqlt$imake$iid\"></td><td>$bname</td><td align=center>$item_mode[$imode]</td><td>$iname</td><td align=center>$idmg</td><td align=center>$igold G</td><td align=center>$item_hand[$ihand]</td><td align=center>$ireq</td><td align=center><font color=$elmcolor[$ieelm]>$item_eelm[$ieelm]</font></td><td align=center>$item_def[$idef]</td><td align=center>$item_qlt[$iqlt]</td><td align=center>$imake</td><td align=center>$irest 個</td>\n";
		print "</tr>\n";
	}

	print <<"EOM";
</tr>
</table>

</div>

<p>
<input type=hidden name=id   value=$in{'id'}>
<input type=hidden name=pass value=$in{'pass'}>
<input type=hidden name=area value=$in{'area'}>
<input type=hidden name=mode value=user_buy>
EOM
	if($kitem < $max_item) { 
	print <<"EOM";
<select name="item">
EOM
	$i=1;
	foreach(1..$max_itemcnt){
		print "<option value=\"$i\">$i\n";
		$i++;
	}
		print <<"EOM";
</select>
 個 <input type=submit value="アイテムを買う">
EOM
	}
	print <<"EOM";
</form>
<p>
		<script>
const spot = "$spot";
</script>
EOM

	&footer;

	exit;
}

#------------#
#  銀行表示  #
#------------#
sub bank {
	@bank_item = &load_ini($bank_path. $in{'id'});
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
<b>$kname の貸し金庫</b>
<hr size=0>
$buy_msg<B><FONT COLOR="#FF9933">$error</FONT></B>
<form action="$script" method="post">
EOM
	$buy_msg = "";$error = "";
	if($kitem >= $max_item) { 
		print <<"EOM";
アイテムはこれ以上所持できません。<BR><BR>
EOM
	} else {
		print <<"EOM";
持ち出したいアイテムをチェックしてください。<BR><BR>
EOM
	}
	print <<"EOM";
<B>預かりアイテム数</B> $kpitem (手数料は価値の <b>$space_price</b> %) &nbsp; <B>所持アイテム数</B> $kitem / $max_item &nbsp; <a href=so_item.cgi?id=$kid&pass=$kpass  target="new">アイテム一覧</a><BR>
<BR>

<div class="blackboard question">

<table border=0>
<tr>
<th></th><th>種別</th><th>名前</th><th>効果</th><th>価値</th><th>使用</th><th>装備条件</th><th>属性</th><th>耐久</th><th>品質</th><th>作成者</th><th>所持数</th>
EOM
	$msg = "";$error = "";
	foreach(@bank_item){
		($iid,$ino,$iname,$idmg,$igold,$imode,$iuelm,$ieelm,$ihand,$idef,$ireq,$iqlt,$imake,$irest) = split(/<>/);
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
		print "<td><input type=radio name=item_no value=\"$iid\"></td><td align=center>$item_mode[$imode]</td><td>$iname</td><td align=center>$idmg</td><td align=center>$igold G</td><td align=center>$item_hand[$ihand]</td><td align=center>$ireq</td><td align=center><font color=$elmcolor[$ieelm]>$item_eelm[$ieelm]</font></td><td align=center>$item_def[$idef]</td><td align=center>$item_qlt[$iqlt]</td><td align=center>$imake</td><td align=center>$irest 個</td>\n";
		print "</tr>\n";
	}

	print <<"EOM";
</tr>
</table>

</div>

<p>
<input type=hidden name=id   value=$in{'id'}>
<input type=hidden name=pass value=$in{'pass'}>
<input type=hidden name=area value=$in{'area'}>
<input type=hidden name=mode value=bank_out>
EOM
	if($kitem < $max_item) { 
	print <<"EOM";
個数
<select name="item">
EOM
	$i=1;
	foreach(1..$max_itemcnt){
		print "<option value=\"$i\">$i\n";
		$i++;
	}
		print <<"EOM";
</select>
 個 
<input type=submit value="貸し金庫より取り出す">
EOM
	}
	print <<"EOM";
<br>
※ここでの処理には手数料はかかりません。
</form>
<p>
		<script>
const spot = "$spot";
</script>
EOM

	&footer;

	exit;
}

#----------------#
#  ショップ購入  #
#----------------#
sub item_buy {
	$item_id = $in{'id'};
	$item_pass = $in{'pass'};
	$item_area = $in{'area'};
	$item_cnt = $in{'item'};
	if($in{'item_no'} eq ""){
		$error = "アイテムを選んでください。";
		&item_shop;
	}

	@item_array = &load_ini($item_file);
	$hit=0;

	my $item_no_id = Encode::decode_utf8($in{'item_no'});

	foreach(@item_array){
		($i_no,$i_name,$i_dmg,$i_gold,$i_mode,$i_uelm,$i_eelm,$i_hand,$i_def,$i_req,$i_qlt,$i_make,$i_rest) = split(/<>/);
		if($item_no_id eq "$i_no$i_qlt$i_make") { $hit=1;last; }
	}

	if(!$hit) { &error("アイテムが存在しません。"); }

	&get_host;

	$date = time();

	# ファイルロック
	if ($lockkey == 1) { &lock1; }
	elsif ($lockkey == 2) { &lock2; }
	elsif ($lockkey == 3) { &file'lock; }

	@item_chara = &load_ini($chara_file);
	@item_array = &load_ini($town_shop[$item_area]);

	$buy_gold = 0;
	$buy_name = "";
	$hit=0;@item_new=();
	foreach(@item_chara){
		($iid,$ipass,$iname,$isex,$ichara,$in_0,$in_1,$in_2,$in_3,$in_4,$in_5,$in_6,$ihp,$imaxhp,$iex,$ilv,$iap,$igold,$ilp,$itotal,$ikati,$ihost,$idate,$iarea,$ispot,$ipst,$iitem) = split(/<>/);
		if($iid eq "$item_id" && $ipass eq "$item_pass" ) {
			if($iitem eq $max_item) {
				$error = "所持アイテムが多すぎます。";
				&item_shop;
			}
			#割引率の設定
			$cut = 1 - $in_6 / 200;
			$buy_gold =int($i_gold * $cut) * $item_cnt;
			if($igold < $buy_gold) {
				$error = "所持金が足りません。";
				&item_shop;
			}
			else { $igold = $igold - $buy_gold; }
			$buy_name = $i_name;
			$kid = $iid;
			$kpass = $ipass;
			$kcnt = $item_cnt;
			$kspot = $ispot;
			$kpst = $ipst;
			&item_regist;
			$iitem = $u_cnt;

			my $mes = "$iid<>$ipass<>$iname<>$isex<>$ichara<>$in_0<>$in_1<>$in_2<>$in_3<>$in_4<>$in_5<>$in_6<>$ihp<>$imaxhp<>$iex<>$ilv<>$iap<>$igold<>$ilp<>$itotal<>$ikati<>$host<>$idate<>$iarea<>$ispot<>$ipst<>$iitem<>\n";
			my $utf8 = Encode::encode_utf8($mes);

			unshift(@item_new,$utf8);
			$hit=1;
		}else{
			push(@item_new,"$_\n");
		}
	}

	if(!$hit) { &error("キャラクターが見つかりません。"); }
	if($kspot != 0 || $kpst != 0) { &error("不正なパラメータです"); }

	open(OUT,">$chara_file");
	print OUT @item_new;
	close(OUT);

	$karea=$item_area;
	&town_load;

	$get_area=$item_area;$get_id="02";$get_cnt="1";
	&get_msg;

	# ロック解除
	if ($lockkey == 3) { &file'unlock; }
	else { if(-e $lockfile) { unlink($lockfile); } }

	$buy_msg = "$buy_nameを$item_cnt 個$buy_gold Gで買いました。";

	&item_shop;
}

#----------------#
#  自由市場購入  #
#----------------#
sub user_buy {
	$item_id = $in{'id'};
	$item_pass = $in{'pass'};
	$item_area = $in{'area'};
	$item_cnt = $in{'item'};
	if($in{'item_no'} eq ""){
		$error = "アイテムを選んでください。";
		&user_shop;
	}

	@item_array = &load_ini($user_shop[$item_area]);

	my $item_no_id = Encode::decode_utf8($in{'item_no'});

	$hit=0;
	foreach(@item_array){
		($i_no,$i_name,$i_dmg,$i_gold,$i_mode,$i_uelm,$i_eelm,$i_hand,$i_def,$i_req,$i_qlt,$i_make,$i_rest,$i_id) = split(/<>/);
		if($item_no_id eq "$i_no$i_qlt$i_make$i_id") { $hit=1;last; }
	}
	if(!$hit) { &error("アイテムが存在しません。"); }

	&get_host;

	$date = time();

	# ファイルロック
	if ($lockkey == 1) { &lock1; }
	elsif ($lockkey == 2) { &lock2; }
	elsif ($lockkey == 3) { &file'lock; }

	@item_chara = &load_ini($chara_file);

	$buy_gold = 0;
	$buy_name = "";
	$rtn_flag = 0;
	$hit=0;@item_new=();
	foreach(@item_chara){
		($iid,$ipass,$iname,$isex,$ichara,$in_0,$in_1,$in_2,$in_3,$in_4,$in_5,$in_6,$ihp,$imaxhp,$iex,$ilv,$iap,$igold,$ilp,$itotal,$ikati,$ihost,$idate,$iarea,$ispot,$ipst,$iitem) = split(/<>/);
		if($iid eq "$item_id" && $ipass eq "$item_pass" ) {
			if($iitem eq $max_item) {
				$error = "所持アイテムが多すぎます。";
				&user_shop;
			}
			$buy_gold =$i_gold * $item_cnt;
			if($iid eq "$i_id"){
				$buy_gold = 0;
				$rtn_flag = 1;
			}
			if($igold < $buy_gold) {
				$error = "所持金が足りません。";
				&user_shop;
			}
			else { $igold = $igold - $buy_gold; }
			@buy_item=();
			foreach(@item_array){
				($i_no,$i_name,$i_dmg,$i_gold,$i_mode,$i_uelm,$i_eelm,$i_hand,$i_def,$i_req,$i_qlt,$i_make,$i_rest,$i_id) = split(/<>/);
				if($item_no_id eq "$i_no$i_qlt$i_make$i_id") {
					if($i_rest < $item_cnt) {
						$error = "在庫が足りません。";
						&user_shop;
					}

					&item_price;
					$i_gold = $kprice;

					$buy_name = $i_name;
					$kid = $iid;
					$kpass = $ipass;
					$kcnt = $item_cnt;
					&item_regist;

					$kid = $i_id;
					$krgold = $buy_gold;
					$kpgold = 0;$kpitem = 0;
					$kmsg = "「$iname の チュパフリマ $town_name[$karea] における $buy_name 購入 」 <b>$buy_gold</b> G";
					$bflag = 1;
					&regist_bank;

					$kid = $iid;
					$kspot = $ispot;
					$kpst = $ipst;

					$iitem = $u_cnt;

					if($i_rest > $item_cnt) {
						$i_rest -= $item_cnt;

						my $mes = "$i_no<>$i_name<>$i_dmg<>$i_gold<>$i_mode<>$i_uelm<>$i_eelm<>$i_hand<>$i_def<>$i_req<>$i_qlt<>$i_make<>$i_rest<>$i_id<>\n";
						my $utf8 = Encode::encode_utf8($mes);

						unshift(@buy_item,$utf8);
					}
				}else{
					my $mes = "$i_no<>$i_name<>$i_dmg<>$i_gold<>$i_mode<>$i_uelm<>$i_eelm<>$i_hand<>$i_def<>$i_req<>$i_qlt<>$i_make<>$i_rest<>$i_id<>\n";
					my $utf8 = Encode::encode_utf8($mes);

					unshift(@buy_item,$utf8);
				}
			}

			my $mes = "$iid<>$ipass<>$iname<>$isex<>$ichara<>$in_0<>$in_1<>$in_2<>$in_3<>$in_4<>$in_5<>$in_6<>$ihp<>$imaxhp<>$iex<>$ilv<>$iap<>$igold<>$ilp<>$itotal<>$ikati<>$host<>$idate<>$iarea<>$ispot<>$ipst<>$iitem<>\n";
			my $utf8 = Encode::encode_utf8($mes);

			unshift(@item_new,$utf8);
			$hit=1;
		}else{
			push(@item_new,"$_\n");
		}
	}

	if(!$hit) { &error("キャラクターが見つかりません。"); }
	if($kspot != 0 || $kpst != 0) { &error("不正なパラメータです"); }

	open(OUT,">$user_shop[$item_area]");
	print OUT @buy_item;
	close(OUT);

	$iarea = $item_area;
	&shop_sort;

	open(OUT,">$chara_file");
	print OUT @item_new;
	close(OUT);

	# ロック解除
	if ($lockkey == 3) { &file'unlock; }
	else { if(-e $lockfile) { unlink($lockfile); } }

	$buy_msg = "$buy_gold Gで買いました。";
	if($rtn_flag == 1){
		$buy_msg = "引き戻しました。";
	}

	$buy_msg = "$buy_nameを$item_cnt 個$buy_msg";

	&user_shop;
}

#----------------#
#  銀行出し入れ  #
#----------------#
sub bank_out {
	$item_id = $in{'id'};
	$item_pass = $in{'pass'};
	$item_cnt = $in{'item'};
	if($in{'item_no'} eq ""){
		$error = "アイテムを選んでください。";
		&bank;
	}

	@item_array = &load_ini($bank_path. $item_id);

	my $item_no_id = Encode::decode_utf8($in{'item_no'});

	$hit=0;
	foreach(@item_array){
		($i_id,$i_no,$i_name,$i_dmg,$i_gold,$i_mode,$i_uelm,$i_eelm,$i_hand,$i_def,$i_req,$i_qlt,$i_make,$i_rest) = split(/<>/);
		if($item_no_id eq "$i_id") { $hit=1;last; }
	}
	if(!$hit) { &error("アイテムが存在しません。"); }

	&get_host;

	$date = time();

	# ファイルロック
	if ($lockkey == 1) { &lock1; }
	elsif ($lockkey == 2) { &lock2; }
	elsif ($lockkey == 3) { &file'lock; }

	@item_chara = &load_ini($chara_file);

	$buy_gold = 0;
	$buy_name = "";
	$rtn_flag = 0;
	$hit=0;@item_new=();
	foreach(@item_chara){
		($iid,$ipass,$iname,$isex,$ichara,$in_0,$in_1,$in_2,$in_3,$in_4,$in_5,$in_6,$ihp,$imaxhp,$iex,$ilv,$iap,$igold,$ilp,$itotal,$ikati,$ihost,$idate,$iarea,$ispot,$ipst,$iitem) = split(/<>/);
		if($iid eq "$item_id" && $ipass eq "$item_pass" ) {
			if($iitem eq $max_item) {
				$error = "所持アイテムが多すぎます。";
				&bank;
			}
			@bank_item=();
			foreach(@item_array){
				($i_id,$i_no,$i_name,$i_dmg,$i_gold,$i_mode,$i_uelm,$i_eelm,$i_hand,$i_def,$i_req,$i_qlt,$i_make,$i_rest) = split(/<>/);
				if($item_no_id eq "$i_id") {
					if($i_rest < $item_cnt) {
						$error = "在庫が足りません。";
						&bank;
					}
					$buy_name = $i_name;
					$kid = $iid;
					$kpass = $ipass;
					$kcnt = $item_cnt;
					&item_regist;

					$kspot = $ispot;
					$kpst = $ipst;

					$iitem = $u_cnt;

					if($i_rest > $item_cnt) {
						$i_rest -= $item_cnt;

						my $mes = "$i_id<>$i_no<>$i_name<>$i_dmg<>$i_gold<>$i_mode<>$i_uelm<>$i_eelm<>$i_hand<>$i_def<>$i_req<>$i_qlt<>$i_make<>$i_rest<>\n";
						my $utf8 = Encode::encode_utf8($mes);

						unshift(@bank_item,$utf8);
					}
				}else{
					my $mes = "$i_id<>$i_no<>$i_name<>$i_dmg<>$i_gold<>$i_mode<>$i_uelm<>$i_eelm<>$i_hand<>$i_def<>$i_req<>$i_qlt<>$i_make<>$i_rest<>\n";
					my $utf8 = Encode::encode_utf8($mes);

					unshift(@bank_item,$utf8);
				}
			}

			my $mes = "$iid<>$ipass<>$iname<>$isex<>$ichara<>$in_0<>$in_1<>$in_2<>$in_3<>$in_4<>$in_5<>$in_6<>$ihp<>$imaxhp<>$iex<>$ilv<>$iap<>$igold<>$ilp<>$itotal<>$ikati<>$host<>$idate<>$iarea<>$ispot<>$ipst<>$iitem<>\n";
			my $utf8 = Encode::encode_utf8($mes);

			unshift(@item_new,$utf8);
			$hit=1;
		}else{
			push(@item_new,"$_\n");
		}
	}

	if(!$hit) { &error("キャラクターが見つかりません。"); }
	if($kspot != 0 || $kpst != 0) { &error("不正なパラメータです"); }

	open(OUT,">$bank_path$item_id");
	print OUT @bank_item;
	close(OUT);

	$iid = $kid;
	&bank_sort;
	&read_bank;
	$kpitem = $bcnt;
	&in_bank;

	open(OUT,">$chara_file");
	print OUT @item_new;
	close(OUT);

	# ロック解除
	if ($lockkey == 3) { &file'unlock; }
	else { if(-e $lockfile) { unlink($lockfile); } }

	$buy_msg = "$buy_nameを$item_cnt 個取り出しました。";

	&bank;
}

#------------------#
#  ショップソート  #
#------------------#
sub shop_sort
{
	#ソートし直す
	@sort_shop = &load_ini($user_shop[$iarea]);

	@tmp1 = @tmp2 = @tmp3 = ();
	foreach(@sort_shop){
		($i_no,$i_name,$i_dmg,$i_gold,$i_mode,$i_uelm,$i_eelm,$i_hand,$i_def,$i_req,$i_qlt,$i_make,$i_rest,$i_id) = split(/<>/);
		if($i_no != null){
			push(@tmp1, $u_no);
			push(@tmp2, $u_make);
		}
	}
	@sort_shop = @sort_shop[sort {$tmp1[$b] <=> $tmp1[$a] or
			$tmp2[$b] <=> $tmp2[$a]} 0 .. $#tmp1];

	@new_sort_shop=();
	foreach(@sort_shop){
		($i_no,$i_name,$i_dmg,$i_gold,$i_mode,$i_uelm,$i_eelm,$i_hand,$i_def,$i_req,$i_qlt,$i_make,$i_rest,$i_id) = split(/<>/);

		my $mes = "$i_no<>$i_name<>$i_dmg<>$i_gold<>$i_mode<>$i_uelm<>$i_eelm<>$i_hand<>$i_def<>$i_req<>$i_qlt<>$i_make<>$i_rest<>$i_id<>\n";
		my $utf8 = Encode::encode_utf8($mes);

		unshift(@new_sort_shop,$utf8);
	}
	open(OUT,">$user_shop[$iarea]");
	print OUT @new_sort_shop;
	close(OUT);
}

#--------------#
#  銀行ソート  #
#--------------#
sub bank_sort
{
	#ソートし直す
	@sort_bank = &load_ini($bank_path. $iid);

	@tmp1 = @tmp2 = @tmp3 = ();
	foreach(@sort_bank){
		($i_id,$i_no,$i_name,$i_dmg,$i_gold,$i_mode,$i_uelm,$i_eelm,$i_hand,$i_def,$i_req,$i_qlt,$i_make,$i_rest) = split(/<>/);
		if($i_no != null){
			push(@tmp1, $i_no);
			push(@tmp2, $i_make);
		}
	}
	@sort_bank = @sort_bank[sort {$tmp1[$b] <=> $tmp1[$a] or
			$tmp2[$b] <=> $tmp2[$a]} 0 .. $#tmp1];

	@new_sort_bank=();$cnt = @sort_bank;
	foreach(@sort_bank){
		($i_id,$i_no,$i_name,$i_dmg,$i_gold,$i_mode,$i_uelm,$i_eelm,$i_hand,$i_def,$i_req,$i_qlt,$i_make,$i_rest) = split(/<>/);

		my $mes = "$cnt<>$i_no<>$i_name<>$i_dmg<>$i_gold<>$i_mode<>$i_uelm<>$i_eelm<>$i_hand<>$i_def<>$i_req<>$i_qlt<>$i_make<>$i_rest<>\n";
		my $utf8 = Encode::encode_utf8($mes);

		unshift(@new_sort_bank,$utf8);
		$cnt -= 1;
	}

	$bcnt = @new_sort_bank;

	open(OUT,">$bank_path$iid");
	print OUT @new_sort_bank;
	close(OUT);
}

1;
