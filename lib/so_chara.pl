use utf8;
#----------------------#
#  キャラクタ作成画面  #
#----------------------#
sub chara_make
{
	my @option;

	$i=0;
	foreach(@chara_name){
		push(@option, "<option value=\"$i\">$chara_name[$i]\n");
		$i++;
	}

	my $point = $system->range_rand(7, 14);
	my $i=0;
	my $j=0;
	my @param;

	foreach(0..6){
		my $mes = "";
		$mes .= "<td>$kiso_nouryoku[$i] + <select name=n_$i>\n";
		foreach(0..$point){
			$mes .= "<option value=\"$j\">$j\n";
			$j++;
		}
		$mes .= "</select>\n";
		$mes .= "</td>\n";
		$i++;$j=0;

		push(@param, $mes);
	}

	my $html = $controller->render_to_string(
		template    => "chara_make",
		script      => $script,
		chara_name  => \@option,
		param       => \@param,
		kid         => $kid,
		mode        => "chara_make",
		select_menu => [],
		kpass       => "*****",
		point       => $point,
	);

	print Encode::encode_utf8($html);

	exit;
}

#----------------#
#  登録完了画面  #
#----------------#
sub make_end {
	if($chara_stop){ &error("現在キャラクターの作成登録はできません。"); }
	if ($in{'id'} =~ m/[^0-9a-zA-Z]/)
	{&error("IDに半角英数字以外の文字が含まれています。"); }
	if ($in{'pass'} =~ m/[^0-9a-zA-Z]/)
	{&error("パスワードに半角英数字以外の文字が含まれています。"); }
	# スキル未取得の場合
	if($in{'skill1'} eq "") {
		if($in{'id'} eq "" or length($in{'id'}) < 4 or length($in{'id'}) > 8) { &error("IDは、4文字以上、8文字以下で入力して下さい。"); }
		elsif($in{'pass'} eq "" or length($in{'pass'}) < 4 or length($in{'pass'}) > 8) { &error("パスワードは、4文字以上、8文字以下で入力して下さい。"); }
		elsif($in{'c_name'} eq "") { &error("キャラクターの名前が未記入です。"); }
		elsif($in{'sex'} eq "") { &error("性別が選択されていません。"); }

		$g = $in{'n_0'} + $in{'n_1'} + $in{'n_2'} + $in{'n_3'} + $in{'n_4'} + $in{'n_5'} + $in{'n_6'};

		if($g > $in{'point'}) { &error("ポイントの振り分けが多すぎます。振り分けの合計を、$in{'point'}以下にしてください。"); }

		my @option;
		my $cnt=0;

		foreach (0 .. @chara_skill) {
			push(@option, "<option value=$cnt>$chara_skill[$cnt]\n");
			$cnt++;
		}

		my @option2;
		$cnt=0;
		foreach (0 .. @chara_skill) {
			push(@option2, "<option value=$cnt>$chara_skill[$cnt]\n");
			$cnt++
		}

		my $html = $controller->render_to_string(
			template    => "make_end1",
			script      => $script,
			option      => \@option,
			option2     => \@option2,
			in          => \%in,
			kid         => $kid,
			mode        => "make_end",
			select_menu => [],
			kpass       => "*****",
		);

		print Encode::encode_utf8($html);

		exit;
	}else{
		my $esex;
		if($in{'sex'}) { $esex = "男"; } else { $esex = "女"; }

		my $html = $controller->render_to_string(
			template    => "make_end2",
			script      => $script,
			option      => \@option,
			option2     => \@option2,
			in          => \%in,
			kid         => $kid,
			esex        => $esex,
			kname       => $kname,
			khp         => $khp,
			klp         => $klp,
			kn_0        => $kn_0,
			kn_1        => $kn_1,
			kn_2        => $kn_2,
			kn_3        => $kn_3,
			kn_4        => $kn_4,
			kn_5        => $kn_5,
			kn_6        => $kn_6,
			kgold       => $kgold,
			chara_skill => \@chara_skill,
			mode        => "make_end",
			select_menu => [],
			kpass       => "*****",
		);

		print Encode::encode_utf8($html);

		exit;
	}
}

sub regist
{
	&get_host;
	my $date = time();

	if ($in{'new'} eq 'new')
	{
		$klp = $max_lp;
		$khp = int(($in{n_3} + $kiso_nouryoku[3]) * 5 + 10);
		$kmaxhp = $khp;
		$kex = 0;
		$klv = 1;
		$kgold = 0;
		$kn_0 = $kiso_nouryoku[0] + $in{n_0};
		$kn_1 = $kiso_nouryoku[1] + $in{n_1};
		$kn_2 = $kiso_nouryoku[2] + $in{n_2};
		$kn_3 = $kiso_nouryoku[3] + $in{n_3};
		$kn_4 = $kiso_nouryoku[4] + $in{n_4};
		$kn_5 = $kiso_nouryoku[5] + $in{n_5};
		$kn_6 = $kiso_nouryoku[6] + $in{n_6};
		$kap = 0;
		$karea = 0;
		$kspot = 0;
		$kpst = 0;
		$kitem = 2;
		$ktotal = 0;
		$kid = $in{id};
		$kpass = $in{pass};
		$kname = $in{c_name};
		$ksex = $in{sex};
		$kchara = $in{chara};
		$kati = 0;

		my $dup1 = $system->load_chara($kid);

		if (defined $dup1)
		{
			&error("そのID[". $kid. "]はすでに登録されています。");
		}
		my $dup2 = $system->load_chara_by_name($kname);
		if (defined $dup2)
		{
			&error("同名のキャラクターが存在します。");
		}
	}

	my $new = {};
	@$new{@{$config->{keys}}} = (
		$kid, $kpass, $kname, $ksex, $kchara,
		$kn_0, $kn_1, $kn_2, $kn_3, $kn_4, $kn_5, $kn_6,
		$khp, $kmaxhp, $kex, $klv, $kap, $kgold, $klp,
		$ktotal, $kkati, $host, $date,
		$karea, $kspot, $kpst,
		$kitem
	);

	$system->modify_chara_data($new);
	$system->save_chara($new);

	if ($in{'new'} eq 'new')
	{
		@kbuf = (100,100,100);
		$krsk    = 0;
		$buff_flg = 1;
		&regist_buff;

		&skill_regist;
		$kcnt =1;
		&item_regist;

		&make_end;
	}
}

sub chara_load
{
	my $id = shift;
	my $k = $system->load_chara($id);

	if (defined $k)
	{
		(
			$kid, $kpass, $kname, $ksex, $kchara,
			$kn_0, $kn_1, $kn_2, $kn_3, $kn_4, $kn_5, $kn_6,
			$khp, $kmaxhp, $kex, $klv, $kap, $kgold, $klp,
			$ktotal, $kkati, $khost, $kdate,
			$karea, $kspot, $kpst,
			$kitem
		) = @$k{@{$config->{keys}}};
	}
}

1;
