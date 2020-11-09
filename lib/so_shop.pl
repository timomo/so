use utf8;
#----------------#
#  ショップ表示  #
#----------------#
sub item_shop
{
	my @shop_array = &load_ini($town_shop[$in{'area'}]);

	if($kspot != 0 || $kpst != 0) { &error("不正なパラメータです"); }

	#割引率の設定
	my $cut = 1 - $kn_6 / 200;

	&town_load;

	if($get_msg eq ""){
		$get_area=$karea;$get_id="02";$get_cnt="0";
		&get_msg;
	}

	&header;

	my $i = 0;

	my @item_array = &load_ini($item_file);
	my @item_list;
	my @item_count;

	foreach(@shop_array)
	{
		my $hit = 0;

		my ($ino, $iname, $idmg, $igold, $imode, $iuelm, $ieelm, $ihand, $idef, $ireq, $iqlt, $imake, $irest);

		foreach(@item_array)
		{
			($ino, $iname, $idmg, $igold, $imode, $iuelm, $ieelm, $ihand, $idef, $ireq, $iqlt, $imake, $irest) = split(/<>/);
			my $shopitem = "$ino$iqlt$imake";

			if($shop_array[$i] == $shopitem)
			{
				$hit=1;
				last;
			}
		}
		if($hit == 0) { &error("アイテムが存在しません。"); }
		$i++;

		$igold = int($igold * $cut);
		&check_limit;
		if ($imode == 01)
		{
			$idmg = "<font color=$efcolor[2]>HP回復：$idmg</font>";
			$ireq = "&nbsp;";
		}
		elsif ($imode == 02)
		{
			$idmg = "<font color=$efcolor[2]>LP回復：$idmg</font>";
			$ireq = "&nbsp;";
		}
		elsif ($imode == 03)
		{
			$idmg = "移動する";
			$ireq = "&nbsp;";
		}
		elsif ($imode == 04)
		{
			$idmg = "<font color=$efcolor[2]>$chara_skill[$idmg]</font>";
			$ireq = "&nbsp;";
		}
		elsif ($imode == 05)
		{
			$idmg = "素材";
			$ireq = "&nbsp;";
		}
		elsif ($imode == 07)
		{
			$idmg = "<font color=$efcolor[2]>治療：$idmg</font>";
			$ireq = "&nbsp;";
		}
		elsif (10 <= $imode && $imode < 20)
		{
			$idmg = "<font color=$efcolor[0]>攻撃：$idmg</font>";
			$ireq = "<font color=$reqcolor>$item_uelm[$iuelm]：$ireq</font>";
		}
		elsif (20 <= $imode && $imode < 30)
		{
			$idmg = "<font color=$efcolor[0]>攻撃：$idmg</font>";
			$ireq = "<font color=$reqcolor>$item_uelm[$iuelm]：$ireq</font>";
		}
		elsif (30 <= $imode && $imode < 40)
		{
			$idmg = "<font color=$efcolor[1]>防御：$idmg</font>";
			$ireq = "<font color=$reqcolor>力：$ireq</font>";
		}
		elsif (40 <= $imode && $imode < 50)
		{
			$idmg = "<font color=$efcolor[1]>防御：$idmg</font>";
			$ireq = "<font color=$reqcolor>力：$ireq</font>";
		}
		elsif (50 <= $imode && $imode < 60)
		{
			$idmg = "<font color=$efcolor[1]>回避：$idmg</font>";
			$ireq = "<font color=$reqcolor>力：$ireq</font>";
		}
		elsif (60 <= $imode && $imode < 70)
		{
			$idmg = "<font color=$efcolor[2]>補助：$idmg</font>";
			$ireq = "<font color=$reqcolor>$item_uelm[$iuelm]：$ireq</font>";
		}
		elsif (70 <= $imode && $imode < 80)
		{
			$idmg = "<font color=$efcolor[0]>攻撃：$idmg</font>";
			$ireq = "<font color=$reqcolor>$item_uelm[$iuelm]：$ireq</font>";
		}
		else
		{
			$idmg = "&nbsp";
			$ireq = "&nbsp;";
		}

		my $mes = "<tr><td><input type=radio name=item_no value=\"$ino$iqlt$imake\"></td><td align=center>$item_mode[$imode]</td><td>$iname</td><td align=center>$idmg</td><td align=center>$igold G</td><td align=center>$item_hand[$ihand]</td><td align=center>$ireq</td><td align=center><font color=$elmcolor[$ieelm]>$item_eelm[$ieelm]</font></td><td align=center>$item_def[$idef]</td><td align=center>$item_qlt[$iqlt]</td><td align=center>$imake</td></tr>";

		push(@item_list, $mes);
	}

	if($kitem < $max_item) {
		$i = 1;
		foreach (1 .. $max_itemcnt) {
			push(@item_count, "<option value=\"$i\">$i</option>");
			$i++;
		}
	}

	my $html = $controller->render_to_string(
		template   => "item_shop",
		t_shop     => $t_shop,
		get_msg    => $get_msg || "",
		buy_msg    => $buy_msg || "",
		error      => $error || "",
		script     => $script,
		kitem      => $kitem,
		max_item   => $max_item,
		kgold      => $kgold,
		spot       => $spot,
		kid        => $kid,
		karea      => $karea,
		item_count => \@item_count,
		item_list  => \@item_list,
	);

	print Encode::encode_utf8($html);

	&footer;
	&save_dat_append;

	$buy_msg = "";$error = "";

	exit;
}

#----------------#
#  自由市場表示  #
#----------------#
sub user_shop
{
	my $exhibits = $system->load_exhibit_db($karea);

	my @item_array = &load_ini($user_shop[$in{'area'}]);
	my @item_chara = &load_ini($chara_file);

	if($kspot != 0 || $kpst != 0) { &error("不正なパラメータです"); }

	&town_load;

	&header;

	my @item_list;
	my @item_count;

	for my $exhibit (@$exhibits)
	{
		my ($id, $iarea, $ino,$iname,$idmg,$igold,$imode,$iuelm,$ieelm,$ihand,$idef,$ireq,$iqlt,$imake,$irest,$iid) = @$exhibit{@{$controller->config->{出品データ}}};
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

		my $name = "";

		foreach(@item_chara)
		{
			my ($bid, $bpass, $bname) = split(/<>/);

			if($iid eq "$bid")
			{
				$name = $bname;
				last;
			}
		}

		if($iid eq "$kid"){ $igold = 0; }

		my $mes = "<tr><td><input type=radio name=item_no value=\"$id\"></td><td>$name</td><td align=center>$item_mode[$imode]</td><td>$iname</td><td align=center>$idmg</td><td align=center>$igold G</td><td align=center>$item_hand[$ihand]</td><td align=center>$ireq</td><td align=center><font color=$elmcolor[$ieelm]>$item_eelm[$ieelm]</font></td><td align=center>$item_def[$idef]</td><td align=center>$item_qlt[$iqlt]</td><td align=center>$imake</td><td align=center>$irest 個</td></tr>";

		push(@item_list, $mes);
	}

	if($kitem < $max_item) {
		$i = 1;
		foreach (1 .. $max_itemcnt) {
			push(@item_count, "<option value=\"$i\">$i</option>");
			$i++;
		}
	}

	my $html = $controller->render_to_string(
		template   => "user_shop",
		script     => $script,
		town_name  => \@town_name,
		karea      => $karea,
		buy_msg    => $buy_msg || "",
		error      => $error || "",
		kitem      => $kitem,
		max_item   => $max_item,
		kgold      => $kgold,
		kid        => $kid,
		karea      => $karea,
		item_list  => \@item_list,
		item_count => \@item_count,
		spot       => $spot,
	);

	print Encode::encode_utf8($html);

	&footer;
	&save_dat_append;

	exit;
}

#------------#
#  銀行表示  #
#------------#
sub bank
{
	my @bank_item = &load_ini($bank_path. $in{'id'});
	my @item_chara = &load_ini($chara_file);
	my $hit=0;

	$rid = $kid;
	&read_bank;
	my $space_price = int($kpitem / 5) + 1;

	#割増率の設定
	my $plus = 1 + $kn_6 / 200;

	&header;

	$error = "";

	my @item_list;
	my @item_count;

	foreach(@bank_item)
	{
		my ($iid,$ino,$iname,$idmg,$igold,$imode,$iuelm,$ieelm,$ihand,$idef,$ireq,$iqlt,$imake,$irest) = split(/<>/);
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
		my $mes = "<tr><td><input type=radio name=item_no value=\"$iid\"></td><td align=center>$item_mode[$imode]</td><td>$iname</td><td align=center>$idmg</td><td align=center>$igold G</td><td align=center>$item_hand[$ihand]</td><td align=center>$ireq</td><td align=center><font color=$elmcolor[$ieelm]>$item_eelm[$ieelm]</font></td><td align=center>$item_def[$idef]</td><td align=center>$item_qlt[$iqlt]</td><td align=center>$imake</td><td align=center>$irest 個</td></tr>";
		push(@item_list, $mes);
	}

	if($kitem < $max_item) {
		$i = 1;
		foreach (1 .. $max_itemcnt) {
			push(@item_count, "<option value=\"$i\">$i</option>");
			$i++;
		}
	}

	my $html = $controller->render_to_string(
		template    => "bank",
		kname       => $kname,
		buy_msg     => $buy_msg || "",
		error       => $error || "",
		script      => $script,
		kitem       => $kitem,
		max_item    => $max_item,
		kpitem      => $kpitem,
		space_price => $space_price,
		kid         => $kid,
		karea       => $karea,
		spot        => $spot,
		item_list   => \@item_list,
		item_count  => \@item_count,
	);

	print Encode::encode_utf8($html);

	$buy_msg = ""; $error = "";

	&footer;
	&save_dat_append;

	exit;
}

#----------------#
#  ショップ購入  #
#----------------#
sub item_buy
{
	my $item_cnt = $in{item};

	if ($in{item_no} eq "")
	{
		$error = "アイテムを選んでください。";
		&item_shop;
	}
	if($kspot != 0 || $kpst != 0) { &error("不正なパラメータです"); }

	my @item_array = &load_ini($item_file);
	my $hit = 0;
	my $item_no_id = Encode::encode_utf8($in{'item_no'});
	our ($i_no, $i_name, $i_dmg, $i_gold, $i_mode, $i_uelm, $i_eelm, $i_hand, $i_def, $i_req, $i_qlt, $i_make, $i_rest);

	foreach(@item_array)
	{
		($i_no, $i_name, $i_dmg, $i_gold, $i_mode, $i_uelm, $i_eelm, $i_hand, $i_def, $i_req, $i_qlt, $i_make, $i_rest) = split(/<>/);
		my $tmp = Encode::encode_utf8(sprintf("%s%s%s", $i_no, $i_qlt, $i_make));
		if($item_no_id eq $tmp) { $hit=1;last; }
	}

	if ($hit == 0) { &error("アイテムが存在しません。"); }

	&get_host;
	$khost = $host;
	my $date = time();
	$kdate = $date;

	if ($kitem eq $max_item) {
		$error = "所持アイテムが多すぎます。";
		&item_shop;
	}
	#割引率の設定
	my $cut = 1 - $kn_6 / 200;
	my $buy_gold = int($i_gold * $cut) * $item_cnt;
	if ($kgold < $buy_gold)
	{
		$error = "所持金が足りません。";
		&item_shop;
	}
	else
	{
		$kgold -= $buy_gold;
	}
	my $buy_name = $i_name;
	$kcnt = $item_cnt;
	&item_regist;
	$kitem = $u_cnt;

	&regist;

	&town_load;

	$get_area=$karea;$get_id="02";$get_cnt="1";
	&get_msg;

	$buy_msg = "$buy_name を$item_cnt 個$buy_gold Gで買いました。";

	&item_shop;
}

#----------------#
#  自由市場購入  #
#----------------#
sub user_buy
{
	my $item_cnt = $in{'item'};

	if($in{'item_no'} eq "")
	{
		$error = "アイテムを選んでください。";
		&user_shop;
	}

	my $exhibits = $system->load_exhibit_db($karea);
	my $item_no_id = Encode::encode_utf8($in{'item_no'});
	our ($i_no,$i_name,$i_dmg,$i_gold,$i_mode,$i_uelm,$i_eelm,$i_hand,$i_def,$i_req,$i_qlt,$i_make,$i_rest,$i_id);
	my $hit = 0;
	my $sell;

	for my $exhibit (@$exhibits)
	{
		if($exhibit->{id} eq $item_no_id)
		{
			$sell = $exhibit;
			$hit = 1;
			last;
		}
	}
	if($hit == 0) { &error("アイテムが存在しません。"); }

	&get_host;
	$khost = $host;
	my $date = time();
	$kdate = $date;

	my $buy_gold = 0;
	my $buy_name = "";
	my $rtn_flag = 0;
	$hit = 0;
	my @item_new=();
	my @buy_item = ();

	if($kitem eq $max_item) {
		$error = "所持アイテムが多すぎます。";
		&user_shop;
	}
	$buy_gold =$i_gold * $item_cnt;
	if($kid eq "$i_id")
	{
		$buy_gold = 0;
		$rtn_flag = 1;
	}
	if($kgold < $buy_gold)
	{
		$error = "所持金が足りません。";
		&user_shop;
	}
	else
	{
		$kgold -= $buy_gold;
	}

	(my $dummy, my $dummy2, $i_no,$i_name,$i_dmg,$i_gold,$i_mode,$i_uelm,$i_eelm,$i_hand,$i_def,$i_req,$i_qlt,$i_make,$i_rest,$i_id) = @$sell{@{$controller->config->{出品データ}}};

	if($sell->{所持数} < $item_cnt)
	{
		$error = "在庫が足りません。";
		&user_shop;
	}

	$sell->{所持数} -= $item_cnt;
	&item_price;
	$sell->{価値} = $kprice;
	$system->save_exhibit_db($karea, $exhibits);

	my $items = $system->load_item_db($kid);
	my $key = sprintf("%s%s%s", @$sell{qw|アイテムid 品質 作成者|});
	$hit = 0;

	for my $item (@$items)
	{
		my $tmp_key = sprintf("%s%s%s", @$item{qw|アイテムid 品質 作成者|});

		if ($key eq $tmp_key)
		{
			$hit = 1;
			@$item{@{$controller->config->{キャラ所持品}}} = @$sell{@{$controller->config->{キャラ所持品}}};
			$item->{所持数} = $item_cnt;
			$item->{キャラid} = $kid;
			$item->{装備} ||= 0;
			last;
		}
	}

	if ($hit == 0)
	{
		my $item = {};
		@$item{@{$controller->config->{キャラ所持品}}} = @$sell{@{$controller->config->{キャラ所持品}}};
		delete $item->{id};
		$item->{所持数} = $item_cnt;
		$item->{キャラid} = $kid;
		$item->{装備} ||= 0;
		push(@$items, $item);
	}

	$system->save_item_db($kid, $items);

=begin
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
=cut
	# if($hit == 0) { &error("キャラクターが見つかりません。"); }
	if($kspot != 0 || $kpst != 0) { &error("不正なパラメータです"); }

	$iarea = $item_area;
	&shop_sort;

	$buy_msg = "$buy_gold Gで買いました。";
	if($rtn_flag == 1){
		$buy_msg = "引き戻しました。";
	}

	$buy_msg = "$buy_name を$item_cnt 個$buy_msg";

	&user_shop;
}

#----------------#
#  銀行出し入れ  #
#----------------#
sub bank_out
{
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
