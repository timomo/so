use utf8;
#------------------#
#    金額計算      #
#------------------#
sub money_get
{
	my $tgold = $kgold + $ggold;

	if($tgold < 0)
	{
		$error = "所持金が足りません。";
		$mode = "log_in";
		&log_in;
	}

	$kgold = $tgold;

	&regist;
}

#------------------#
#  銀行データ読込  #
#------------------#
sub read_bank
{
	my $rows = $system->load_bank($rid);

	$krgold = 0;

	my @mes;

	for my $row (@$rows)
	{
		$kpgold += 0;
		$krgold  += $row->{送金額};
		$kpitem += $row->{預かりアイテム数};
		push(@mes, $row->{預かりメッセージ});
	}

	$kmsg = join("<br />", @mes);
}

#----------------------#
#  銀行金額データ書込  #
#----------------------#
sub regist_bank
{
	my $new = {
		キャラid    => $kid,
		送金額      => $krgold,
		預かりアイテム数 => $kpitem,
		預かりメッセージ => $kmsg,
	};

	$system->save_bank_db($kid, $new);
}

#----------------------#
#  銀行持物データ書込  #
#----------------------#
sub in_bank
{
	my $new = {
		キャラid    => $kid,
		送金額      => 0,
		預かりアイテム数 => $kpitem,
		預かりメッセージ => "",
	};

	$system->save_bank_db($kid, $new);
}

1;
