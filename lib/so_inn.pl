use utf8;
#--------#
#  宿屋  #
#--------#
sub yado
{
	@inn_array = &load_ini($town_inn[$in{'area'}]);

	if($kspot != 0 || $kpst != 0) { &error("不正なパラメータです。"); }

	#割引率の設定
	$cut = 1 - $kn_6 / 200;

	&town_load;

	$get_area=$karea;$get_id="03";$get_cnt="0";
	&get_msg;

	&header;

	print <<"EOM";
<b>宿屋：$t_inn</b>
<hr size=0>
$get_msg<br>
<B><FONT COLOR="#FF9933">$error</FONT></B>
<form action="$script" method="post">
<B>所持金</B> $kgold G<BR>
<BR>

<div class="blackboard question">

<table border=0>
<tr>
<th></th><th>部屋名</th><th>料理</th><th>効果</th><th>価格</th>
EOM
	$error = "";

	foreach(@inn_array){
		($yno,$yname,$yfood,$yatc,$ydef,$yspd,$yrsk,$ygold) = split(/<>/);
		$ygold = int($ygold * $cut);
		# アイテム種別により処理変更
		$ybuf = "";
		if ($yatc != 0) {
			$ybuf .= "攻撃：$yatc % ";
		}
		if ($ydef != 0) {
			$ybuf .= "防御：$ydef % ";
		}
		if ($yspd != 0) {
			$ybuf .= "先制：$yspd % ";
		}
		if ($yrsk != 0) {
			$ybuf .= "リスク低減：$yrsk % ";
		}
		if ($yatc == 0 && $ydef == 0 && $yspd == 0 && $yrsk == 0){
			$ybuf = "効果無し";
		}
		$select = "";
		if($yno == 0){
			$select = "checked";
		}

		print "<tr>\n";
		print "<td><input type=radio name=inn_no value=\"$yno\" $select></td><td>$yname</td><td>$yfood</td><td align=center>$ybuf</td><td align=center>$ygold</td>\n";
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
<input type=hidden name=mode value=yado_in>
<input type=submit value="宿泊する">
</form>
<p>
	<script>
const spot = "$spot";
</script>
EOM

	&footer;
	&save_dat_append;

	exit;
}

#------------#
#  体力回復  #
#------------#
sub yado_in
{
	if(! exists $in{inn_no})
	{
		$error = "部屋を選んでください。";
		&yado;
	}

	&get_host;

	$date = time();

	# ファイルロック
	if ($lockkey == 1) { &lock1; }
	elsif ($lockkey == 2) { &lock2; }
	elsif ($lockkey == 3) { &file'lock; }

	@YADO = &load_ini($chara_file);
	@inn_array = &load_ini($town_inn[$in{'area'}]);

	foreach(@inn_array){
		($y_no,$y_name,$y_food,$y_atc,$y_def,$y_spd,$y_rsk,$y_gold) = split(/<>/);
		if($in{'inn_no'} eq "$y_no") {
			$yado_gold = $y_gold;
			last;
		}
	}

	$hit=0;@yado_new=();
	foreach(@YADO){
		($yid,$ypass,$yname,$ysex,$ychara,$yn_0,$yn_1,$yn_2,$yn_3,$yn_4,$yn_5,$yn_6,$yhp,$ymaxhp,$yex,$ylv,$yap,$ygold,$ylp,$ytotal,$ykati,$yhost,$ydate,$yarea,$yspot,$ypst,$yitem) = split(/<>/);
		if($in{'id'} eq "$yid" and $in{'pass'} eq "$ypass") {
			#割引率の設定
			$cut = 1 - $yn_6 / 200;
			$yado_gold = int($yado_gold * $cut);
			if($ygold < $yado_gold) {
				$error = "所持金が足りません。";
				&yado;
			}
			else { $ygold = $ygold - $yado_gold; }
			$ymaxhp = int($ylv * 7.5 + $yn_3 * 7.5);

			my $mes = "$yid<>$ypass<>$yname<>$ysex<>$ychara<>$yn_0<>$yn_1<>$yn_2<>$yn_3<>$yn_4<>$yn_5<>$yn_6<>$ymaxhp<>$ymaxhp<>$yex<>$ylv<>$yap<>$ygold<>$max_lp<>$ytotal<>$ykati<>$host<>$ydate<>$yarea<>$yspot<>$ypst<>$yitem<>\n";
			my $utf8 = Encode::encode_utf8($mes);

			unshift(@yado_new,$utf8);
			$kid = $yid;
			$kpass = $ypass;
			$karea = $yarea;
			$kspot = $yspot;
			$kpst = $ypst;
			@kbuf = (100,100,100);
			$krsk    = 0   - $y_rsk;
			$kbuf[0] = 100 + $y_atc;
			$kbuf[1] = 100 + $y_def;
			$kbuf[2] = 100 + $y_spd;
			$buff_flg = 1;
			&regist_buff;
			$hit=1;
		}else{
			push(@yado_new,"$_\n");
		}
	}

	if(!$hit) { &error("入力されたIDは登録されていません。又はパスワードが違います。"); }
	if($kspot != 0 || $kpst != 0) { &error("不正なパラメータです。"); }

	open(OUT,">$chara_file");
	print OUT @yado_new;
	close(OUT);

	# ロック解除
	if ($lockkey == 3) { &file'unlock; }
	else { if(-e $lockfile) { unlink($lockfile); } }

	&header;

	$get_area=$karea;$get_id="03";$get_cnt="1";
	&get_msg;

	&town_load;

	print <<"EOM";

<b>宿屋：$t_inn</b>
<hr size=0>
ゆっくり休んでHP、LPを完全に回復しました。<p>
$get_msg
<p>
		<script>
const spot = "$spot";
</script>
EOM

	&footer;
	&save_dat_append;

	exit;
}

1;
