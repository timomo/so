#!/usr/bin/perl

use File::Spec;
use FindBin;
use lib File::Spec->catdir($FindBin::RealBin, 'lib');

# 日本語ライブラリの読み込み
# require 'jcode.pl';

# 初期設定ファイルの読み込み
require './so_system.dat';

require './lib/so_skill.pl';
require './lib/so_item.pl';
require './lib/so_battle.pl';

	&decode;
	$header =<<"END";
Content-type:text/html

<html>
<head>
<meta http-equiv="Content-type" content="text/html; charset=UTF-8" />
<title>アイテム一覧</title>
<STYLE type="text/css">
<!--
body,tr,td,th { font-size: $b_size}
a:hover { color: $alink }
.small { font-size: 10pt }
.b1 {background: #9ac;border-color: #ccf #669 #669 #ccf;color:#fff; border-style: solid; border-width: 1px;}
.b2 {background: #669;border-color: #99c #336 #336 #99c;color:#fff; border-style: solid; border-width: 1px; text-align: center}
.b3 {background: #fff;border-color: #ccf #669 #669 #ccf;}
.dmg { color: #880000; font-size: 12pt }
.clit { color: #880000; font-size: 12pt }
form { margin-bottom: 0px }
-->
</STYLE>
</head>
<body background="$backgif" bgcolor="$bgcolor" text="$text" link="$link" vlink="$vlink" alink="$alink">
END


$bottom =<<"END";
</body>
</html>
END
	print $header;

	open(IN,"$item_path$in{'id'}");
	@user_item = <IN>;
	close(IN);

	open(IN,"$chara_file");
	@item_chara = <IN>;
	close(IN);

	$hit=0;
	foreach(@item_chara){
		($kid,$kpass,$kname,$ksex,$kchara,$kn_0,$kn_1,$kn_2,$kn_3,$kn_4,$kn_5,$kn_6,$khp,$kmaxhp,$kex,$klv,$kap,$kgold,$klp,$ktotal,$kkati,$khost,$kdate,$karea,$kspot,$kpst,$kitem) = split(/<>/);
		if($in{'id'} eq "$kid" and $in{'pass'} eq "$kpass") {
			$hit=1;
			last;
		}
	}

	if(!$hit) {
	print <<"EOM";
入力されたIDは登録されていません。又はパスワードが違います。
EOM
		print $bottom;
		exit;
	}
	#割増率の設定
	$plus = 1 + $kn_6 / 200;

	print <<"EOM";
<b>$knameの所持品</b>
<hr size=0>
<B>所持アイテム数</B> $kitem / $max_item<BR>
<BR>
<table border=1>
<tr>
<th>装備</th><th>種別</th><th>名前</th><th>効果</th><th>価値</th><th>使用</th><th>装備条件</th><th>属性</th><th>耐久</th><th>品質</th><th>作成者</th><th>所持数</th>
EOM
	$error = "";
	foreach(@user_item){
		($iid,$ino,$iname,$idmg,$igold,$imode,$iuelm,$ieelm,$ihand,$idef,$ireq,$iqlt,$imake,$irest,$ieqp) = split(/<>/);
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
		print "<td align=center>$item_eqp[$ieqp]</td><td align=center>$item_mode[$imode]</td><td>$iname</td><td align=center>$idmg</td><td align=center>$igold G</td><td align=center>$item_hand[$ihand]</td><td align=center>$ireq</td><td align=center><font color=$elmcolor[$ieelm]>$item_eelm[$ieelm]</font></td><td align=center>$item_def[$idef]</td><td align=center>$item_qlt[$iqlt]</td><td align=center>$imake</td><td align=center>$irest 個</td>\n";
		print "</tr>\n";
	}

	print <<"EOM";
</tr>
</table>
EOM

	print $bottom;

#----------------#
#  デコード処理  #
#----------------#
sub decode {
	if ($ENV{'REQUEST_METHOD'} eq "POST") {
		if ($ENV{'CONTENT_LENGTH'} > 51200) { &error("投稿量が大きすぎます。"); }
		read(STDIN, $buffer, $ENV{'CONTENT_LENGTH'});
	} else { $buffer = $ENV{'QUERY_STRING'}; }
	@pairs = split(/&/, $buffer);
	foreach (@pairs) {
		($name,$value) = split(/=/, $_);
		$value =~ tr/+/ /;
		$value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;

		# 文字コードをシフトJIS変換
		# &jcode'convert(*value, "sjis", "", "z");

		# タグ処理
		$value =~ s/</&lt;/g;
		$value =~ s/>/&gt;/g;
		$value =~ s/\"/&quot;/g;

		# 改行等処理
		$value =~ s/\r//g;
		$value =~ s/\n//g;

		# 一括削除用
		if ($name eq 'del') { push(@DEL,$value); }

		$in{$name} = $value;
	}
	$mode = $in{'mode'};
	$cookie_pass = $in{'pass'};
	$cookie_id = $in{'id'};
}
