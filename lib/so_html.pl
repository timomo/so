#------------------#
#　HTMLのフッター　#
#------------------#
sub footer {
	if($mode ne ""){
		print "<a href=\"$script\">TOPへ</a>\n";
	}
	if($kid and $mode ne 'log_in') { 
		print " / <a href=\"$script?mode=log_in&id=$kid&pass=$kpass\">メイン画面へ</a>\n";
	}

print <<EOF;
<hr size=0 width="100%">
<div align="right" class="small">
$ver by <a href="http://www.interq.or.jp/sun/cumro/">D.Takamiya(CUMRO)</a><br>
Character Image by <a href="http://www.aas.mtci.ne.jp/~hiji/9ff/9ff.html">9-FFいっしょにTALK</a><br>
cooperation site by <a href="http://webooo.csidenet.com/asvyweb/">FFADV推奨委員会</a>
</div>
EOF

	if(($mode eq 'log_in' or ($mode eq 'monster' and $battle_flag ne "1") or $mode eq 'rest') and $ltime < $b_time and $ktotal){
	print <<"EOM";
<script type="text/javascript">window.setTimeout('CountDown()',100);</script>
EOM
	}
	print "</body></html>\n\n";
}

#------------------#
#  HTMLのヘッダー  #
#------------------#
sub header {

my $refresh = "";
if ( $vtime > 0 ) {
    $refresh = sprintf('<META HTTP-EQUIV="Refresh" CONTENT="%d" />',$vtime);
}

	print <<"EOM";
Cache-Control: no-cache
Pragma: no-cache
Content-type: text/html

<html>
<head>
<meta http-equiv="Content-type" content="text/html; charset=UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0, minimum-scale=1.0" />
<meta name="format-detection" content="telephone=no" />
<meta name="apple-mobile-web-app-capable" content="yes" />
<meta name="apple-mobile-web-app-status-bar-style" content="black" />
$refresh
<title>$main_title</title>
<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.4.3/jquery.min.js"></script>
<script type="text/javascript">
<!--
	var info = new Array();
EOM

if(($mode eq 'log_in' or ($mode eq 'monster' and $battle_flag ne "1") or $mode eq 'rest') and $ltime < $b_time and $ktotal){
	print <<"EOM";
	var start=new Date();
	start=Date.parse(start)/1000;
	var counts=$vtime;

	function CountDown(){
		var now=new Date();
		now=Date.parse(now)/1000;
		var x=parseInt(counts-(now-start),10);
		if(document.form1){document.form1.clock.value = x;}
		if(x>0){
			timerID=setTimeout("CountDown()", 100)
		}else{
			location.href="$script?mode=log_in&id=$kid&pass=$kpass"
		}
	}
EOM
	if($kspot == 0 && $kpst == 0){
		$info0 = "HP、LPを完全に回復することができます。";
		$info1 = "アイテム等の購入ができます。";
		$info2 = "プレイヤー間でのアイテム売買ができます。";
		$info3 = "預けたアイテムを受け取る事が出来ます。";
	}
} elsif($mode eq 'log_in' or ($mode eq 'monster' and $battle_flag ne "1") or $mode eq 'rest') {
	if($kspot == 0 && $kpst == 0){
		$info0 = "HP、LPを完全に回復することができます。";
		$info1 = "アイテム等の購入ができます。";
		$info2 = "プレイヤー間でのアイテム売買ができます。";
		$info3 = "預けたアイテムを受け取る事が出来ます。";
		$info4 = "$town_name[$karea]周辺です。比較的弱い敵が出没します。";
		$info5 = "$town_name[$karea]のダンジョンです。最深部には強敵が待ち受けています。";
	} elsif($kspot == 0 && $kpst == 1){
		$info0 = "HPを少し回復することができます。";
		$info1 = "HPを大きく回復できますが、安全ではありません。";
		$info4 = "$town_name[$karea]周囲を探索します。";
		$info5 = "$town_name[$karea]に帰ります。";
	} else {
		$info0 = "HPを少し回復することができます。";
		$info1 = "HPを大きく回復できますが、安全ではありません。";
		$info4 = "目的地を目指します。";
		$info5 = "$town_name[$karea]の方に引き返します。";
	}
}
if(($mode eq 'log_in' || ($mode eq 'monster' and $battle_flag ne "1") or $mode eq 'rest') && ($ltime >= $b_time or !$ktotal)){
	# noop
}
if(($mode eq 'monster' and $battle_flag eq "1") or $mode eq 'battle' ){
	# noop
}

my $css_backgif = "";
$css_backgif = "    background-image: url($backgif);" if ( $backgif ne "" );

	print <<"EOM";
	info[0] = "$info0";
	info[1] = "$info1";
	info[2] = "$info2";
	info[3] = "$info3";
	info[4] = "$info4";
	info[5] = "$info5";
	info[6] = "$f_info";
	info[7] = "$r_info";
//-->
</script>
<script type="text/javascript" src="so_town.js"></script>
<script type="text/javascript" src="so_battle.js"></script>
<style type="text/css">
<!--
body {
    color: $text;
    background-color: $bgcolor;
$css_backgif
}
body,tr,td,th,table { font-size: $b_size; }
a:hover   {
    color: $alink;
}
a:link    {
    color: $link;
}
a:visited {
    color: $vlink;
}
-->
</style>
<link rel="stylesheet" href="so_common.css" type="text/css" />
</head>
<body $onload>
EOM
}

1;
