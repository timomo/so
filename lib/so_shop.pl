use utf8;
#----------------#
#  ショップ表示  #
#----------------#
sub item_shop
{
	my @shop_array = &load_ini($town_shop[$in{'area'}]);

	unless($kspot == 4 && $kpst == 0) { &error("不正なパラメータです。"); }

	#割引率の設定
	my $cut = 1 - $kn_6 / 200;

	&town_load;

	if($get_msg eq ""){
		$get_area=$karea;$get_id="02";$get_cnt="0";
		&get_msg;
	}

	my $i = 0;
	my @item_array;
	{
		my $rows = $system->load_master_item_db;
		@item_array = @$rows;
	}
	my @item_list;
	my @item_count;

	for my $key (@shop_array)
	{
		my $hit = 0;
		my $item;

		for my $tmp (@item_array)
		{
			my $key2 = sprintf("%s%s%s", @$tmp{qw|アイテムid 品質 作成者|});

			if($key eq $key2)
			{
				$item = $tmp;
				$hit = 1;
				last;
			}
		}

		if($hit == 0) { next; }
		$i++;

		my ($iid,$ino,$iname,$idmg,$igold,$imode,$iuelm,$ieelm,$ihand,$idef,$ireq,$iqlt,$imake,$irest) = @$item{@{$mojo->config->{マスタデータ_アイテム}}};

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

		my $mes = "<tr><td><input type=radio name=item_no value=\"$iid\"></td><td align=center>$item_mode[$imode]</td><td>$iname</td><td align=center>$idmg</td><td align=center>$igold G</td><td align=center>$item_hand[$ihand]</td><td align=center>$ireq</td><td align=center><font color=$elmcolor[$ieelm]>$item_eelm[$ieelm]</font></td><td align=center>$item_def[$idef]</td><td align=center>$item_qlt[$iqlt]</td><td align=center>$imake</td></tr>";

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

	unless($kspot == 4 && $kpst == 0) { &error("不正なパラメータです。"); }

	&town_load;

	my @item_list;
	my @item_count;

	for my $exhibit (@$exhibits)
	{
		my ($id, $iarea, $ino,$iname,$idmg,$igold,$imode,$iuelm,$ieelm,$ihand,$idef,$ireq,$iqlt,$imake,$irest,$iid) = @$exhibit{@{$mojo->config->{出品データ}}};
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

	&save_dat_append;

	exit;
}

#------------#
#  銀行表示  #
#------------#
sub bank
{
	unless($kspot == 4 && $kpst == 0) { &error("不正なパラメータです。"); }

	my $rows = $system->load_bank_storage($kid);
	my @bank_item = @$rows;
	our $rid = $kid;
	&read_bank;
	my $space_price = int($kpitem / 5) + 1;

	#割増率の設定
	my $plus = 1 + $kn_6 / 200;

	$error = "";

	my @item_list;
	my @item_count;

	foreach(@bank_item)
	{
		my ($iid,$ino,$iname,$idmg,$igold,$imode,$iuelm,$ieelm,$ihand,$idef,$ireq,$iqlt,$imake,$irest) = @$_{@{$mojo->config->{銀行貸し金庫}}};
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

	&save_dat_append;

	exit;
}

#----------------#
#  ショップ購入  #
#----------------#
sub item_buy
{
	unless($kspot == 4 && $kpst == 0) { &error("不正なパラメータです。"); }
	if ($in{item_no} eq "")
	{
		$error = "アイテムを選んでください。";
		&item_shop;
	}
	my $item_cnt = int($in{item});
	my $item_no_id = Encode::encode_utf8($in{'item_no'});
	my @item_array;
	{
		my $rows = $system->load_master_item_db;
		@item_array = @$rows;
	}
	my $new;
	foreach(@item_array)
	{
		if($item_no_id eq $_->{id}) {
			$new = Storable::dclone($_);
			last;
		}
	}

	if ($kitem eq $max_item)
	{
		$error = "所持アイテムが多すぎます。";
		&item_shop;
	}
	#割引率の設定
	my $cut = 1 - $kn_6 / 200;
	my $buy_gold = int($new->{価値} * $cut) * $item_cnt;
	if ($kgold < $buy_gold)
	{
		$error = "所持金が足りません。";
		&item_shop;
	}
	else
	{
		$kgold -= $buy_gold;
	}
	my $buy_name = $new->{名前};

	$new->{キャラid} = $kid;
	$new->{装備} = 0;
	$new->{所持数} = $item_cnt;

	my $rows = $system->load_item_db($kid);
	my $hit = 0;

	for my $item (@$rows)
	{
		my $item_id = Encode::encode_utf8(sprintf("%s%s%s", @$new{qw|アイテムid 品質 作成者|}));
		my $tmp = Encode::encode_utf8(sprintf("%s%s%s", @$item{qw|アイテムid 品質 作成者|}));

		if ($item_id eq $tmp)
		{
			$item->{所持数} += $item_cnt;
			$hit = 1;
		}
	}

	if ($hit == 0)
	{
		push(@$rows, $new);
	}
	$system->save_item_db($kid, $rows);

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
	unless($kspot == 4 && $kpst == 0) { &error("不正なパラメータです。"); }

	my $exhibits = $system->load_exhibit_db($karea);
	my $item_no_id = $in{'item_no'};
	my $hit = 0;
	my $sell;

	for my $exhibit (@$exhibits)
	{
		if($exhibit->{id} eq $item_no_id)
		{
			$sell = Storable::dclone($exhibit);
			$exhibit->{所持数} -= $item_cnt;
			$hit = 1;
			last;
		}
	}

	if($hit == 0) { &error("アイテムが存在しません。"); }

	my $buy_gold = 0;
	my $buy_name = "";
	my $rtn_flag = 0;
	$hit = 0;

	if($kitem eq $max_item)
	{
		$error = "所持アイテムが多すぎます。";
		&user_shop;
	}
	$buy_gold = $sell->{価値} * $item_cnt;
	if($kid eq $sell->{キャラid})
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

	if($sell->{所持数} < $item_cnt)
	{
		$error = "在庫が足りません。";
		&user_shop;
	}

	$sell->{所持数} -= $item_cnt;
	my $kprice = &item_price($sell);
	$sell->{価値} = $kprice;
	$system->save_exhibit_db($karea, $exhibits);

	# 以降、アイテム用に使うのでid削除
	delete $sell->{id};

	my $items = $system->load_item_db($kid);
	my $key = sprintf("%s%s%s", @$sell{qw|アイテムid 品質 作成者|});
	$hit = 0;

	for my $item (@$items)
	{
		my $tmp_key = sprintf("%s%s%s", @$item{qw|アイテムid 品質 作成者|});

		if ($key eq $tmp_key)
		{
			$hit = 1;
			@$item{@{$mojo->config->{キャラ所持品}}} = @$sell{@{$mojo->config->{キャラ所持品}}};
			$item->{所持数} = $item_cnt;
			$item->{キャラid} = $kid;
			$item->{装備} ||= 0;
			last;
		}
	}

	if ($hit == 0)
	{
		my $item = {};
		@$item{@{$mojo->config->{キャラ所持品}}} = @$sell{@{$mojo->config->{キャラ所持品}}};
		$item->{所持数} = $item_cnt;
		$item->{キャラid} = $kid;
		$item->{装備} ||= 0;
		push(@$items, $item);
	}

	$system->save_item_db($kid, $items);

	# 銀行
	$krgold = $buy_gold;
	$kpgold = 0;
	$kpitem = 0;
	$kmsg = "「$iname の チュパフリマ $town_name[$karea] における $buy_name 購入 」 <b>$buy_gold</b> G";
	$bflag = 1;
	&regist_bank;

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
	unless($kspot == 4 && $kpst == 0) { &error("不正なパラメータです。"); }

	my $rows = $system->load_bank_storage($kid);
	my $item_id = int($in{item_no});
	my $item_cnt = int($in{item});
	my $new;
	my $rows2 = $system->load_item_db($kid);

	for my $item (@$rows)
	{
		if ($item->{id} != $item_id)
		{
			next;
		}
		$item->{所持数} -= $item_cnt;
		$new = Storable::dclone($item);
		$new->{所持数} = $item_cnt;
	}

	delete $new->{id};
	$new->{キャラid} = $kid;
	$new->{装備} = 0;

	push(@$rows2, $new);

	$system->save_item_db($kid, $rows2);
	$system->save_bank_storage_db($kid, $rows);

	my $buy_name = $new->{名前};

	our $buy_msg = "$buy_name を$item_cnt 個取り出しました。";

	&bank;
}

1;
