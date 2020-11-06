use utf8;
#----------------------#
#  キャラクタ作成画面  #
#----------------------#
sub chara_make {
	# ヘッダー表示
	&header;

	print <<"EOM";
<b>入国手続き</b>
<hr size=0>
<i>受付嬢「シマダ共和国にご入国でしょうか？こちらにご記入願います。」</i>
<form action="$script" method="post">
<input type="hidden" name="mode" value="make_end">

<div class="blackboard question">

<table border=0>
<tr>
<td class="b1" align=center>入国ＩＤ</td>
<td><input type="text" name="id" size="11"><br><small>半角英数字4～8文字以内</small></td>
</tr>
<tr>
<td class="b1" align=center>パスワード</td>
<td><input type="password" name="pass" size="11"><br><small>半角英数字4～8文字以内</small></td>
</tr>
<tr>
<td class="b1" align=center>氏名</td>
<td><input type="text" name="c_name" size="30"></td>
</tr>
<tr>
<td class="b1" align=center>性別</td>
<td><input type="radio" name="sex" value="0">女　<input type="radio" name="sex" value="1">男</td>
</tr>
<tr>
<td class="b1" align=center>写真</td>
<td><select name="chara">
EOM

	$i=0;
	foreach(@chara_name){
		print "<option value=\"$i\">$chara_name[$i]\n";
		$i++;
	}

	print <<"EOM";
</select></td>
</tr>
<tr>
<td class="b1" align=center>能\力</td>
<td>
	<table border=1>
	<tr>
	<td class="b2" width="70">力</td><td class="b2" width="70">賢さ</td><td class="b2" width="70">信仰心</td><td class="b2" width="70">体力</td><td class="b2" width="70">器用さ</td><td class="b2" width="70">素早さ</td><td class="b2" width="70">魅力</td>
	</tr>
	<tr>
EOM
	$point+=7;

	$i=0;$j=0;
	foreach(0..6){
		print "<td>$kiso_nouryoku[$i] + <select name=n_$i>\n";
		foreach(0..$point){
			print "<option value=\"$j\">$j\n";
			$j++;
		}
		print "</select>\n";
		print "</td>\n";
		$i++;$j=0;
	}

	print <<"EOM";
	</tr>
	</table>
<small>ボーナスポイント「<b>$point</b>」をそれぞれに振り分けてください。</small>
</td>
</tr>
<tr>
<td colspan="2" align="center"><input type="submit" value="これで登録"></td>
</tr>
</table>
<input type="hidden" name=point value="$point">

</div>

</form>
<p>
EOM

	# フッター表示
	&footer;

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

		&header;

		print "<b>入国手続き</b><hr size=0>\n";
		print "<i>受付嬢「ご職業はなんでしょうか？」</i><p>\n";
		print "メインスキルとサブスキルを選択してください。<BR>両方同じものを選択するとより得意なものになります。<BR>ここで選択しなかったスキルも後で自由に上昇できます。<p>\n";
		print "<form action=\"$script\" method=\"post\">\n";
		print "<input type=hidden name=mode value=regist>\n";
		print "メインスキル";
		print "<select name=skill1>\n";
		$cnt=0;
		foreach (0 .. @chara_skill) {
			print "<option value=$cnt>$chara_skill[$cnt]\n";
			$cnt++
		}
		print "</select>\n";
		print "　サブスキル";
		print "<select name=skill2>\n";
		$cnt=0;
		foreach (0 .. @chara_skill) {
			print "<option value=$cnt>$chara_skill[$cnt]\n";
			$cnt++
		}
		print "</select>\n";
		print "<input type=hidden name=new value=new>\n";
		print "<input type=hidden name=id value=\"$in{'id'}\">\n";
		print "<input type=hidden name=pass value=\"$in{'pass'}\">\n";
		print "<input type=hidden name=c_name value=\"$in{'c_name'}\">\n";
		print "<input type=hidden name=sex value=\"$in{'sex'}\">\n";
		print "<input type=hidden name=chara value=\"$in{'chara'}\">\n";
		print "<input type=hidden name=n_0 value=\"$in{'n_0'}\">\n";
		print "<input type=hidden name=n_1 value=\"$in{'n_1'}\">\n";
		print "<input type=hidden name=n_2 value=\"$in{'n_2'}\">\n";
		print "<input type=hidden name=n_3 value=\"$in{'n_3'}\">\n";
		print "<input type=hidden name=n_4 value=\"$in{'n_4'}\">\n";
		print "<input type=hidden name=n_5 value=\"$in{'n_5'}\">\n";
		print "<input type=hidden name=n_6 value=\"$in{'n_6'}\">\n";
		print "<input type=submit value=\"このスキルでOK\"></form><p>\n";

		&footer;

		exit;
	}else{
		if($in{'sex'}) { $esex = "男"; } else { $esex = "女"; }
		$next_ex = $lv_up;

		&header;

		print <<"EOM";
登録完了画面
以下の内容で登録が完了しました。
<hr size=0>
<p>

<div class="blackboard question">

<table border=0>
<tr>
<td class="b1">名前</td>
<td>$kname</td>
<td class="b1">性別</td>
<td>$esex</td>
</tr>
<td class="b1">HP</td>
<td>$khp</td>
<td class="b1">LP</td>
<td>$klp</td>
</tr>
<tr>
<td class="b1">力</td>
<td>$kn_0</td>
<td class="b1">賢さ</td>
<td>$kn_1</td>
</tr>
<tr>
<td class="b1">信仰心</td>
<td>$kn_2</td>
<td class="b1">体力</td>
<td>$kn_3</td>
</tr>
<tr>
<td class="b1">器用さ</td>
<td>$kn_4</td>
<td class="b1">素早さ</td>
<td>$kn_5</td>
</tr>
<tr>
<td class="b1">魅力</td>
<td>$kn_6</td>
<td class="b1">所持金</td>
<td>$kgold</td>
</tr>
<tr>
<td class="b1">メインスキル</td>
<td>$chara_skill[$in{'skill1'}]</td>
<td class="b1">サブスキル</td>
<td>$chara_skill[$in{'skill2'}]</td>
</tr>
</table>
</div>

<a href="/">TOPページへ</a>
EOM

		&footer;

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
