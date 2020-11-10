use utf8;
#----------------#
#  所持アイテム  #
#----------------#

sub item_check_window
{
	my @user_item = &item_load($kid);
	our $rid = $kid;
	&read_bank;
	my $space_price = int($kpitem / 5) + 1;

	#割増率の設定
	my $plus = 1 + $kn_6 / 200;

	$msg = "";
	$error = "";
	my @items;

	for my $ary (@user_item)
	{
		my ($iid,$ino,$iname,$idmg,$igold,$imode,$iuelm,$ieelm,$ihand,$idef,$ireq,$iqlt,$imake,$irest,$ieqp) = @$ary;
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
			$idmg = "&nbsp;";
			$ireq = "&nbsp;";
		}

		my $mes = "<tr><td align=center>$item_eqp[$ieqp]</td><td align=center>$item_mode[$imode]</td><td class=iname>$iname<input type=hidden name=item_no value=\"$iid\"></td><td align=center>$idmg</td><td align=center>$igold G</td><td align=center>$item_hand[$ihand]</td><td align=center>$ireq</td><td align=center><font color=$elmcolor[$ieelm]>$item_eelm[$ieelm]</font></td><td align=center>$item_def[$idef]</td><td align=center>$item_qlt[$iqlt]</td><td align=center>$imake</td><td align=center>$irest 個</td></tr>\n";
		push(@items, $mes);
	}

	my $characters = $system->characters;
	my @send_id;

	for my $to (@$characters)
	{
		if($kid eq $to->{id})
		{
			next;
		}
		push(@send_id, sprintf("<option value='%s'>%s</option>\n", $to->{id}, $to->{名前}));
	}

	my $i = 1;
	my @item_count;

	foreach(1 .. $max_itemcnt)
	{
		push(@item_count, sprintf("<option value='%s'>%s</option>\n", $i, $i));
		$i++;
	}

	my $html = $controller->render_to_string(
		template    => "window/item_check",
		script      => "/window/item",
		item_count  => \@item_count,
		spot        => $spot,
		space_price => $space_price,
		kgold       => $kgold,
		kid         => $kid,
		items       => \@items,
		kitem       => $kitem,
		max_item    => $max_item,
		error       => $error,
		msg         => $msg,
		kname       => $kname,
		send_id     => \@send_id,
		kpst        => $kpst,
		kspot       => $kspot,
	);

	return Encode::encode_utf8($html);
}

sub _item_check
{
	my @user_item = &item_load($kid);
	our $rid = $kid;
	&read_bank;
	my $space_price = int($kpitem / 5) + 1;

	#割増率の設定
	my $plus = 1 + $kn_6 / 200;

	$msg = "";
	$error = "";
	my @items;

	for my $ary (@user_item)
	{
		my ($iid,$ino,$iname,$idmg,$igold,$imode,$iuelm,$ieelm,$ihand,$idef,$ireq,$iqlt,$imake,$irest,$ieqp) = @$ary;
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
			$idmg = "&nbsp;";
			$ireq = "&nbsp;";
		}

		my $mes = "<tr><td><input type=radio name=item_no value=\"$iid\"></td><td align=center>$item_eqp[$ieqp]</td><td align=center>$item_mode[$imode]</td><td class=iname>$iname</td><td align=center>$idmg</td><td align=center>$igold G</td><td align=center>$item_hand[$ihand]</td><td align=center>$ireq</td><td align=center><font color=$elmcolor[$ieelm]>$item_eelm[$ieelm]</font></td><td align=center>$item_def[$idef]</td><td align=center>$item_qlt[$iqlt]</td><td align=center>$imake</td><td align=center>$irest 個</td></tr>\n";
		push(@items, $mes);
	}

	my $characters = $system->characters;
	my @send_id;

	for my $to (@$characters)
	{
		if($kid eq $to->{id})
		{
			next;
		}
		push(@send_id, sprintf("<option value='%s'>%s</option>\n", $to->{id}, $to->{名前}));
	}

	my $i = 1;
	my @item_count;

	foreach(1 .. $max_itemcnt)
	{
		push(@item_count, sprintf("<option value='%s'>%s</option>\n", $i, $i));
		$i++;
	}

	my $html = $controller->render_to_string(
		template    => "item_check",
		script      => $script,
		item_count  => \@item_count,
		spot        => $spot,
		space_price => $space_price,
		kgold       => $kgold,
		kid         => $kid,
		items       => \@items,
		kitem       => $kitem,
		max_item    => $max_item,
		error       => $error,
		msg         => $msg,
		kname       => $kname,
		send_id     => \@send_id,
		kpst        => $kpst,
		kspot       => $kspot,
	);

	return Encode::encode_utf8($html);
}

sub item_check
{
	&header;
	print &_item_check;
	&footer;
	&save_dat_append;
	exit;
}

#----------------#
#  アイテム取得  #
#----------------#
sub item_drop
{
	my $mrand = int(rand(5));
	my @drop = &load_ini($drop_file);
	my $hit = 0;
	my $g_no;
	my $g_qlt;

	foreach(@drop)
	{
		my ($type, $rnd, $no, $name, $qlt) = split(/<>/);
		if($type == $mdrop && $rnd == $mrand)
		{
			$hit = 1;
			$g_no = $no;
			$g_qlt = $qlt;
			last;
		}
	}

	if ($hit == 0) { &error("アイテム取得エラー"); }

	my @get = &load_ini($item_file);

	$hit = 0;

	foreach(@get)
	{
		($i_no,$i_name,$i_dmg,$i_gold,$i_mode,$i_uelm,$i_eelm,$i_hand,$i_def,$i_req,$i_qlt,$i_make) = split(/<>/);

		if($i_no == $g_no && $i_qlt == $g_qlt){
			$kcnt = 1;
			&item_regist;
			$hit=1;
			last;
		}
	}

	if($hit == 0) { &error("アイテム書き込みエラー"); }
}

#----------------#
#  ストーン取得  #
#----------------#
sub stone_drop
{
	my $srand = int(rand(@chara_skill));
	my @get = &load_ini($item_file);
	my $hit = 0;

	foreach(@get)
	{
		($i_no,$i_name,$i_dmg,$i_gold,$i_mode,$i_uelm,$i_eelm,$i_hand,$i_def,$i_req,$i_qlt,$i_make) = split(/<>/);

		if($i_no eq $stone_no)
		{
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

	if($hit == 0) { &error("アイテム書き込みエラー"); }
}

#----------------#
#  アイテム書込  #
#----------------#
sub item_regist
{
	my @user_item = &item_load($in{'id'});
	my $u_flag = 0;
	my $u_cnt = 0;
	my $i_eqp = 0;
	my $over = 0;
	my @new_user_item = ();
	my @new = ();
	my $uniq_key = sprintf("%s%s%s", $i_no, $i_qlt, $i_make);

	foreach(@user_item)
	{
		my ($u_id,$u_no,$u_name,$u_dmg,$u_gold,$u_mode,$u_uelm,$u_eelm,$u_hand,$u_def,$u_req,$u_qlt,$u_make,$u_rest,$u_eqp) = @$_;
		my $tmp_uniq_key = sprintf("%s%s%s", $u_no, $u_qlt, $u_make);

		if($uniq_key eq $tmp_uniq_key)
		{
			$u_rest += $kcnt;
			if ($u_rest > $max_itemcnt && $mode eq 'item_buy')
			{
				$error = "$max_itemcnt 個までしか所持できません";
				&item_shop;
			}
			elsif ($u_rest > $max_itemcnt && $mode eq 'user_buy')
			{
				$error = "$max_itemcnt 個までしか所持できません";
				&user_shop;
			}
			elsif ($u_rest > $max_itemcnt)
			{
				$u_rest = $max_itemcnt;
				$over = 1;
			}
			$u_flag = 1;

			my $mes = "$u_id<>$u_no<>$u_name<>$u_dmg<>$u_gold<>$u_mode<>$u_uelm<>$u_eelm<>$u_hand<>$u_def<>$u_req<>$u_qlt<>$u_make<>$u_rest<>$u_eqp<>\n";
			my $utf8 = Encode::encode_utf8($mes);
			unshift(@new, $utf8);
		}
		else
		{
			my $mes = "$u_id<>$u_no<>$u_name<>$u_dmg<>$u_gold<>$u_mode<>$u_uelm<>$u_eelm<>$u_hand<>$u_def<>$u_req<>$u_qlt<>$u_make<>$u_rest<>$u_eqp<>\n";
			my $utf8 = Encode::encode_utf8($mes);
			unshift(@new_user_item, $utf8);
		}
		$u_cnt++;
	}

	if($u_flag eq 0 && $in{'new'} ne 'new'){
		my $mes = "<>$i_no<>$i_name<>$i_dmg<>$i_gold<>$i_mode<>$i_uelm<>$i_eelm<>$i_hand<>$i_def<>$i_req<>$i_qlt<>$i_make<>$kcnt<>$i_eqp<>\n";
		my $utf8 = Encode::encode_utf8($mes);
		unshift(@new, $mes);
		$u_cnt++;
	}

	if($in{'new'} eq 'new'){
		unshift(@new, $newbie_equip[$in{'skill1'}]);
		unshift(@new, $newbie_equip[99]);
		$u_flag = 1;
	}

	# TODO: !!!!
	my @items = ();

	for my $line (@new)
	{
		$line =~ s/(?:\r\n|\r|\n)$//g;
		my @tmp = split("<>", $line);
		my $item = {};
		@$item{@{$controller->config->{キャラ所持品}}} = @tmp;
		push(@items, $item);
	}

	$system->save_item_db($kid, \@items);

	&item_sort;
}

sub item_load
{
	my $kid = shift;
	my $rows = $system->load_item_db($kid);
	my @items;

	for my $row (@$rows)
	{
		my @tmp = @$row{@{$controller->config->{キャラ所持品}}};
		push(@items, \@tmp);
	}

	return @items;
}

#----------------#
#  アイテム使用  #
#----------------#
sub item_use
{
	my @user_item = &item_load($in{'id'});

	if($in{'item_no'} eq "")
	{
		$error = "アイテムを選んでください。";
		&item_check;
	}

	my $hit = 0;

	foreach(@user_item)
	{
		($i_id,$i_no,$i_name,$i_dmg,$i_gold,$i_mode,$i_uelm,$i_eelm,$i_hand,$i_def,$i_req,$i_qlt,$i_make,$i_rest,$i_eqp) = @$_;
		if($in{item_no} eq $i_id) {
			$hit = 1;
			last;
		}
	}
	if($hit == 0)
	{
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

sub item_db_save
{
	my $kid = shift;
	my @new_equip_item = @_;

	my @items = ();
	for my $line (@new_equip_item)
	{
		$line =~ s/(?:\r\n|\r|\n)$//g;
		my @tmp = split("<>", $line);
		my $item = {};
		@$item{@{$controller->config->{キャラ所持品}}} = @tmp;
		push(@items, $item);
	}

	$system->save_item_db($kid, \@items);
}

#----------------#
#  アイテム装備  #
#----------------#
sub item_equip
{
	my @user_item = &item_load($in{'id'});

	if (scalar @user_item == 0)
	{
		my @equip_item = &load_ini($item_path. $kid);
		@user_item = ();
		for my $item (@equip_item)
		{
			my @tmp = split("<>", $item);
			push(@user_item, \@tmp);
		}
	}

	my $d_eqp = 0;
	my $eqp_flag = 0;
	my $eqp_name = "";
	my @new_equip_item = ();

	foreach(@user_item)
	{
		my ($u_id, $u_no, $u_name, $u_dmg, $u_gold, $u_mode, $u_uelm, $u_eelm, $u_hand, $u_def, $u_req, $u_qlt, $u_make, $u_rest, $u_eqp) = @$_;

		if($u_eqp eq $k_eqp){
			unshift(@new_equip_item,"$u_id<>$u_no<>$u_name<>$u_dmg<>$u_gold<>$u_mode<>$u_uelm<>$u_eelm<>$u_hand<>$u_def<>$u_req<>$u_qlt<>$u_make<>$u_rest<>$d_eqp<>\n");
			$eqp_flag += 1;
			if(! defined $eqp_name)
			{
				$eqp_name = $u_name;
			}
		}
		elsif($u_id eq $k_id)
		{
			unshift(@new_equip_item,"$u_id<>$u_no<>$u_name<>$u_dmg<>$u_gold<>$u_mode<>$u_uelm<>$u_eelm<>$u_hand<>$u_def<>$u_req<>$u_qlt<>$u_make<>$u_rest<>$k_eqp<>\n");
			$eqp_flag += 2;
			$eqp_name = $u_name;
		}
		else
		{
			unshift(@new_equip_item,"$u_id<>$u_no<>$u_name<>$u_dmg<>$u_gold<>$u_mode<>$u_uelm<>$u_eelm<>$u_hand<>$u_def<>$u_req<>$u_qlt<>$u_make<>$u_rest<>$u_eqp<>\n");
		}
	}

	&item_db_save($kid, @new_equip_item);

	open(OUT,">", $item_path. $kid);
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
	my @check_equip = &item_load($kid);

	$over_flag = 0;
	$wep_hand = 0;
	$def_hand = 0;

	foreach(@check_equip)
	{
		($c_id,$c_no,$c_name,$c_dmg,$c_gold,$c_mode,$c_uelm,$c_eelm,$c_hand,$c_def,$c_req,$c_qlt,$c_make,$c_rest,$c_eqp) = @$_;
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
	my @user_item = &item_load($kid);
    my $sell_name;
	my $sell_flag = 0;
	my $select_id = "";
	my $select_price = 0;
	my $use_item;

	if ($btl_flg == 0)
	{
		$use_item = $in{item};
	}
	else
	{
		$use_item = 1;
	}

	for my $ary (@user_item)
	{
		if ($ary->[0] ne $k_id)
		{
			next;
		}

		my $row = {};
		@$row{@{$controller->config->{キャラ所持品}}} = @$ary;

		if ($row->{所持数} < $use_item)
		{
			$error = "所持アイテムが足りません。";
			&item_check;
		}

		$row->{所持数} -= $use_item;

		$sell_name = $row->{名前};
		$sell_flag = 1;
		$select_id = sprintf("%s%s%s", @$row{qw|アイテムid 品質 作成者|});
		$select_price = $row->{価値};

		$system->save_item_db($kid, [ $row ]);
	}

	my $plus = 1 + $kn_6 / 200;
	my $sell_price = int($select_price * $plus / 2) * $use_item;
	$kgold += $sell_price;
	$kitem = scalar @user_item;

	&regist;

	$msg = "";

	if ($sell_flag == 1 && $btl_flg == 0)
	{
		if ($kspot == 0 && $kpst == 0)
		{
			$msg = "$sell_name を$use_item 個$sell_price Gで売却しました。";
		}
		else
		{
			$msg = "$sell_name を$use_item 個捨てました。";
		}
	}

	if ($btl_flg == 0)
	{
		&item_check;
	}
}

#----------------#
#  アイテム出品  #
#----------------#
sub user_sell
{
	my @user_item = &item_load($kid);
	my $sell_gold = $in{gold};
	my $select_id = "";
	my $sell_name;
	my $sell_flag = 0;
	my $select_price = 0;
	my $use_item = $in{item};
	my $sell;

	if ($sell_gold !~ /^\d+$/)
	{
		$error = "金額は数字で入力してください。";
		&item_check;
	}

	for my $ary (@user_item)
	{
		if ($ary->[0] ne $k_id)
		{
			next;
		}

		my $row = {};
		@$row{@{$controller->config->{キャラ所持品}}} = @$ary;

		if ($row->{所持数} < $use_item)
		{
			$error = "所持アイテムが足りません。";
			&item_check;
		}

		$row->{所持数} -= $use_item;
		$sell_name = $row->{名前};
		$sell_flag = 1;
		$select_id = sprintf("%s%s%s", @$row{qw|アイテムid 品質 作成者|}, $kid);
		$select_price = $row->{価値};
		$sell = $row;
		$system->save_item_db($kid, [ $row ]);
	}

	if (! defined $sell)
	{
		$error = "アイテムがありません。";
		&item_check;
	}

	$kitem = scalar @user_item;
	&regist;
	my $exhibits = $system->load_exhibit_db($karea); # 出品データ
	my $hit = 0;

	if ($hit == 0)
	{
		my $exhibit = {};
		my @key = (qw|アイテムid 名前 効果 価値 アイテム種別 攻撃属性 属性 使用 耐久 装備条件 品質 作成者 所持数|);
		@$exhibit{@key} = @$sell{@key};
		$exhibit->{価値} = $sell_gold;
		$exhibit->{所持数} = $use_item;
		$exhibit->{エリア} = $karea;
		$exhibit->{キャラid} = $kid;
		push(@$exhibits, $exhibit);
	}

	$system->save_exhibit_db($karea, $exhibits);

	# &item_sort;

	$msg = "";
	if($sell_flag == 1)
	{
		$msg = "$sell_name を$kitem 個$select_price Gで出品しました。";
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
			push(@item_new,"$_\n");
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
			push(@item_new,"$_\n");
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
			push(@money_new,"$_\n");
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
	my @user_item = &item_load($kid);
	my $use;

	for my $ary (@user_item)
	{
		if ($ary->[0] ne $k_id)
		{
			next;
		}

		my $row = {};
		@$row{@{$controller->config->{キャラ所持品}}} = @$ary;
		$row->{所持数} -= 1;
		$use = $row;
		$system->save_item_db($kid, [ $row ]);
	}

	my $use_name = $use->{名前};
	my $use_mode = $use->{アイテム種別};
	my $use_flag = 1;
	my $use_pow  = $use->{効果};
	my $use_qlt  = $use->{品質};

	if($use_mode eq "01")
	{
		$khp = $khp + $use_pow;
		if($khp > $kmaxhp){$khp = $kmaxhp;}
	}
	elsif($use_mode eq "02")
	{
		$klp = $klp + $use_pow;
		if($klp > $max_lp){$klp = $max_lp;}
	}
	elsif($use_mode eq "03")
	{
		$karea = $use_pow;
		$kspot = 0;
		$kpst  = 0;
	}
	elsif($use_mode eq "04")
	{
		&skill_gain($use_pow, $use_qlt);
	}
	elsif($use_mode eq "07")
	{
		my $rcvhp = int($use_pow * ($ksk[20]/ 1000 + rand(2) / 5 + 1) / 2);
		&skill_up(20,($kmaxhp - $khp) / 10);
		$khp = $khp + $rcvhp;
		if($khp > $kmaxhp){$khp = $kmaxhp;}
	}

	$kitem = scalar @user_item;

	&regist;

	$msg = "";

	if($use_flag == 1)
	{
		if($use_mode eq "01")
		{
			$msg = "$use_name を使用し、HPが<b>$use_pow</b>回復しました。";
		}
		elsif($use_mode eq "02")
		{
			$msg = "$use_name を使用し、LPが<b>$use_pow</b>回復しました。";
		}
		elsif($use_mode eq "03")
		{
			$movemsg = "$use_name を手に念じると、$town_name[$use_pow]の風景が浮かんで来て・・・<p>$town_name[$use_pow]の入り口に立っていました。";
			$mode = "log_in";
			&log_in;
			exit;
		}
		elsif($use_mode eq "04")
		{
			if($use_qlt > 0){
				$msg = "$use_name を使用すると、$chara_skill[$use_pow]の最大値と、最大合計スキルが<b>5</b>上昇しました。";
			} else {
				$msg = "$use_name を使用すると、$chara_skill[$use_pow]の最大値が<b>5</b>上昇しました。";
			}
		}
		elsif($use_mode eq "07")
		{
			$msg = "$kskm $use_name を使用し、HPが<b>$rcvhp</b>回復しました。";
		}
	}

	&item_check;
}

#--------------------#
# アイテム価格再設定 #
#--------------------#
sub item_price
{
	my $item = shift;

	if(! defined $item) { &error("アイテムの価格の引数が不正です"); }

	#価格を算出
	my @item_price = &load_ini($item_file);
	my $price_no;

	if($item->{アイテム種別} eq "04")
	{
		$price_no = $stone_no;
	} else {
		$price_no = $item->{アイテムid};
	}

	my $hit = 0;
	my $kprice = 0;

	foreach(@item_price){
		my ($p_no,$p_name,$p_dmg,$p_gold,$p_mode,$p_uelm,$p_eelm,$p_hand,$p_def,$p_req,$p_qlt,$p_make,$p_rest) = split("<>");

		if($price_no. $item->{品質} eq "$p_no$p_qlt")
		{
			$hit=1;
			$kprice = $p_gold;
			last;
		}
	}
	if($hit == 0) { &error("アイテムが存在しません。"); }

	return $kprice;
}

1;
