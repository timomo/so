use utf8;

#------------------#
#　HTMLのフッター　#
#------------------#
sub footer
{
	my @select_menu;

	push(@select_menu, qq|<p class="answer-menu">| . "【デフォルト】" . qq|</p>|);

	if ($kid)
	{
		push(@select_menu, sprintf('<p id="mode_default-select_%s" class="select-menu">%s</p>', "log_in", "戻る"));
	}

	if ($kid and ($mode ne "monster"))
	{
		push(@select_menu, sprintf('<p id="mode_default-select_%s" class="select-menu">%s</p>', "item_check", "アイテム一覧"));
		push(@select_menu, sprintf('<p id="mode_default-select_%s" class="select-menu">%s</p>', "status_check", "ステータス詳細"));
	}

	if ($kid)
	{
		push(@select_menu, sprintf('<p id="mode_default-select_%s" class="select-menu">%s</p>', "logout", "ログアウト"));
	}

	my $html = $controller->render_to_string(
		template    => "footer",
		ver         => $ver,
		kid         => $kid,
		mode        => $mode,
		kpass       => $kpass,
		script      => $script,
		select_menu => \@select_menu,
	);

	print Encode::encode_utf8($html);
}
#------------------#
#  HTMLのヘッダー  #
#------------------#
sub header
{
	if(($mode eq 'log_in' or ($mode eq 'monster' and $battle_flag ne "1") or $mode eq 'rest'))
	{
		if($kspot == 0 && $kpst == 0)
		{
			$info0 = "HP、LPを完全に回復することができます。";
			$info1 = "アイテム等の購入ができます。";
			$info2 = "プレイヤー間でのアイテム売買ができます。";
			$info3 = "預けたアイテムを受け取る事が出来ます。";
		}
	}
	elsif($mode eq 'log_in' or ($mode eq 'monster' and $battle_flag ne "1") or $mode eq 'rest')
	{
		if($kspot == 0 && $kpst == 0)
		{
			$info0 = "HP、LPを完全に回復することができます。";
			$info1 = "アイテム等の購入ができます。";
			$info2 = "プレイヤー間でのアイテム売買ができます。";
			$info3 = "預けたアイテムを受け取る事が出来ます。";
			$info4 = "$town_name[$karea]周辺です。比較的弱い敵が出没します。";
			$info5 = "$town_name[$karea]のダンジョンです。最深部には強敵が待ち受けています。";
		}
		elsif($kspot == 0 && $kpst == 1)
		{
			$info0 = "HPを少し回復することができます。";
			$info1 = "HPを大きく回復できますが、安全ではありません。";
			$info4 = "$town_name[$karea]周囲を探索します。";
			$info5 = "$town_name[$karea]に帰ります。";
		}
		else
		{
			$info0 = "HPを少し回復することができます。";
			$info1 = "HPを大きく回復できますが、安全ではありません。";
			$info4 = "目的地を目指します。";
			$info5 = "$town_name[$karea]の方に引き返します。";
		}
	}

	my $css_backgif = "";
	$css_backgif = "background-image: url($backgif);" if ( $backgif ne "" );

	my $info_array = [$info0 || "", $info1 || "", $info2 || "", $info3 || "", $info4 || "", $info5 || "", $f_info || "", $r_info || ""];

	my $html = $controller->render_to_string(
		template     => "header",
		main_title   => $main_title,
		info_array   => $info_array,
		const_id     => $kid,
		css_backgif  => $css_backgif,
	);

	print Encode::encode_utf8($html);
}

1;
