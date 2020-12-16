use utf8;

#----------------#
#   メイン画面   #
#----------------#
sub log_in_frame
{
	my $html = $controller->render_to_string(
		template      => "log_in_frame",
		script        => $script,
		kid           => $kid,
		kname         => $kname,
		kpass         => $kpass,
		karea         => $karea,
		spot          => $spot,
		kspot         => $kspot,
		kpst          => $kpst,
		area          => $town_name[$karea],
		klv           => $klv,
		klp           => $klp,
		max_lp        => $max_lp,
		khp           => $khp,
		kmaxhp        => $kmaxhp,
		kex           => $kex,
		rrsk          => $rrsk,
		kgold         => $kgold,
	);

	&header;
	print Encode::encode_utf8($html);
	&footer;

	&save_dat_append;

	exit;
}

sub log_in
{
	my $esex = "女";
	$esex = "男" if($ksex);

	my @select_menu = ();
	$next_ex = $lv_up;

	# my $town = &town_load;
	my $k = &chara_load($kid);
	my $data = $town->load($k);

	my @message = ();

	push(@message, $movemsg);

	$rid = $kid;
	&read_battle;
	&read_bank;

	if($krgold > 0){
		$ggold = $krgold;
		$bflag = 0;
		&money_get;

		if($kmsg ne "")
		{
			push(@message, "<p>シマダ国営銀行より <b>$ggold</b> G が振り込まれました。明細は以下の通りです。<br>$kmsg</p>");
		}
		else
		{
			push(@message, "<p>シマダ国営銀行より <b>$ggold</b> G が振り込まれました。</p>");
		}

		$kgold = $tgold;
		&regist_bank;
	}

	&read_buff;

	if($rrsk > 100)
	{
		push(@message, "<p>動くのも苦痛なほど疲れてきました・・。</p>");
	}
	elsif($rrsk > 75)
	{
		push(@message, "<p>かなり疲れてきました・・。</p>");
	}
	elsif($rrsk > 50)
	{
		push(@message, "<p>少し疲れてきました・・。</p>");
	}

	my $error_string = Encode::decode_utf8($error) if (! utf8::is_utf8($error));

	$error = "";

	if($kspot == 4 && $kpst == 0)
	{
		push(@select_menu, sprintf('<p class="answer-menu">【%sの施設】</p>', $data->{current}->{地名}));
		push(@select_menu, sprintf('<p id="mode_town-select_%s" class="select-menu">%s</p>', "yado", "宿屋：".$data->{current}->{inn}));
		push(@select_menu, sprintf('<p id="mode_town-select_%s" class="select-menu">%s</p>', "item_shop", "ショップ：".$data->{current}->{shop}));
		push(@select_menu, sprintf('<p id="mode_town-select_%s" class="select-menu">%s</p>', "user_shop", "市場：チュパフリマ：". $data->{current}->{地名}));
		push(@select_menu, sprintf('<p id="mode_town-select_%s" class="select-menu">%s</p>', "bank", "銀行：シマダ国営銀行（". $data->{current}->{地名}. "店）"));
	}
	else
	{
		push(@select_menu, qw|<p class="answer-menu">【キャンプ】</p>|);
		push(@select_menu, qw|<p id="mode_camp-select_rest" class="blink-before select-menu">野宿</p>|);
		push(@select_menu, qw|<p id="mode_camp-select_monster" class="select-menu">キャンピング</p>|);
	}

	my ( $label, $optionHTML ) = ( "", "" );
	my @options;

	$label = sprintf("【%s周辺】", $data->{current}->{地名});

	if ($k->{スポット} == 0 && $k->{距離} == 0)
	{
		push( @options, [ "explore", sprintf( "%s郊外を探索する", $data->{current}->{地名} ) ] );
	}
	if ($k->{スポット} == 4 && $k->{距離} == 0)
	{
		# push( @options, [ "dungeon", sprintf( "地下に降りる", $data->{current}->{場所} ) ] );
		push( @options, [ "explore", sprintf( "%s郊外を探索する", $data->{current}->{地名} ) ] );
		push( @options, [ "field", sprintf( "%sへ向かう(距離 %s)", $data->{current}->{場所}, $data->{current}->{距離} ) ] );
		push( @options, [ "next", sprintf( "%s方面へ(距離 %s)", $data->{next}->{地名}, $data->{next}->{距離} ) ] );
		push( @options, [ "previous", sprintf( "%s方面へ(距離 %s)", $data->{previous}->{地名}, $data->{previous}->{距離} ) ] );
	}

	$label = "【行動】";
	push( @options, [ "forward", "先へ進む" ] );

	if ($k->{距離} == 0)
	{
		push( @options, [ "town", sprintf( "%sへ帰還する", $data->{current}->{地名} ) ] );
	}

	push(@select_menu, qq|<p class="answer-menu">|. $label. qq|</p>|);

	if ($k->{距離} != 0)
	{
		push( @options, [ "backward", "引き返す" ] );
	}

	for (@options)
	{
		push(@select_menu, sprintf('<p id="mode_monster-select_%s" class="select-menu">%s</p>', @$_));
		$optionHTML .= sprintf( "<option value=\"%s\">%s</option>\n", @$_);
	}

	my @rid;

	my @card = (
		["/img/cardwirth/romance.raindrop.jp/camp.gif", "野宿", "mode_camp-select_rest"],
		["/img/cardwirth/romance.raindrop.jp/gell4.png", "キャンピング", "mode_camp-select_monster"],
		["/img/cardwirth/romance.raindrop.jp/047.png", "郊外を探索", "mode_monster-select_explore"],
		["/img/cardwirth/romance.raindrop.jp/047.png", "先へ進む", "mode_monster-select_forward"],
		["/img/cardwirth/romance.raindrop.jp/047.png", "街へ帰還", "mode_monster-select_town"],
#		["/img/cardwirth/romance.raindrop.jp/dawn.gif", "壁紙を見る"],
#		["/img/cardwirth/romance.raindrop.jp/items.png", "荷物袋"],
#		["/img/cardwirth/romance.raindrop.jp/sky-f.gif", "パーティ情報"],
#		["/img/cardwirth/romance.raindrop.jp/turn.gif", "セーブ"],
#		["/img/cardwirth/romance.raindrop.jp/weapons.png", "冒険の中断"],
	);

	my $html = $controller->render_to_string(
		template     => "log_in",
		script       => $script,
		kid          => $kid,
		kname        => $kname,
		kpass        => $kpass,
		karea        => $karea,
		spot         => $spot,
		optionHTML   => $optionHTML,
		select_menu  => \@select_menu,
		kspot        => $kspot,
		kpst         => $kpst,
		rid          => \@rid,
		area         => $town_name[$karea],
		t_inn        => $t_inn,
		t_shop       => $t_shop,
		klv          => $klv,
		klp          => $klp,
		max_lp       => $max_lp,
		khp          => $khp,
		kmaxhp       => $kmaxhp,
		kex          => $kex,
		rrsk         => $rrsk,
		kgold        => $kgold,
		message      => \@message,
		error_string => $error_string,
		card         => \@card,
	);

	# &header;
	print Encode::encode_utf8($html);
	# &footer;

	&save_dat_append;

	exit;
}

1;
