use utf8;

#------------------#
#　HTMLのフッター　#
#------------------#
sub footer {
	my @select_menu;

	push(@select_menu, qq|<p class="answer-menu">|. "【デフォルト】". qq|</p>|);

	if($kid) {
		push(@select_menu, sprintf('<p id="mode_default-select_%s" class="select-menu">%s</p>', "log_in", "戻る"));
	}

	if($kid and ($mode ne "monster")) {
		push(@select_menu, sprintf('<p id="mode_default-select_%s" class="select-menu">%s</p>', "item_check", "アイテム一覧"));
		push(@select_menu, sprintf('<p id="mode_default-select_%s" class="select-menu">%s</p>', "status_check", "ステータス詳細"));
	}

	if ($kid and $mode ne "")
	{
		print '<div class="blackboard question" id="neighbors"></div>'. "\n";
	}

	print <<"EOM";
<div class="clearfix">
	<div class="blackboard answer float-l">
EOM
	print join("\n", @select_menu);

print <<EOF;
	</div>
</div>

<form action="$script" method="post">
<select id="default-select" name="mode" onchange="javascript:selectTown(this);">
<option value="item_check">アイテム一覧</option>
<option value="status_check">ステータス詳細</option>
<option value="log_in">戻る</option>
</select>
<input type="hidden" name="id" value="$kid" />
<input type="hidden" name="pass" value="$kpass" />
<input id="default-select-submit" type="submit" value="行動" />

<hr size=0 width="100%">
<div align="right" class="small">
$ver by <a href="http://www.interq.or.jp/sun/cumro/">D.Takamiya(CUMRO)</a><br>
Character Image by <a href="http://www.aas.mtci.ne.jp/~hiji/9ff/9ff.html">9-FFいっしょにTALK</a><br>
cooperation site by <a href="http://webooo.csidenet.com/asvyweb/">FFADV推奨委員会</a><br>
Music by <a href="https://otologic.jp/">OtoLogic</a>
</div>
EOF

	print "</body></html>\n\n";
}

#------------------#
#  HTMLのヘッダー  #
#------------------#
sub header
{
	print <<"EOM";
<html>
<head>
<meta http-equiv="Content-type" content="text/html; charset=UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0, minimum-scale=1.0" />
<meta name="format-detection" content="telephone=no" />
<meta name="apple-mobile-web-app-capable" content="yes" />
<meta name="apple-mobile-web-app-status-bar-style" content="black" />
<title>$main_title</title>
<script src="https://code.jquery.com/jquery-3.5.1.js" integrity="sha256-QWo7LDvxbWT2tbbQ97B53yJnYU3WhH/C8ycbRAkjPDc=" crossorigin="anonymous"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/howler/2.1.3/howler.js"></script>
<script src="https://cdn.jsdelivr.net/npm/vue\@2.6.12"></script>
<script src="/js/third-party/jquery.jgrowl.js"></script>
<script src="/js/sound.js"></script>
<script>
<!--
chara_config = {};
chara_config["楽曲"] = "あり";
chara_config["戦闘楽曲"] = "あり";
chara_config["戦闘効果音"] = "あり";
chara_config["音声"] = "あり";


	var info = new Array();
EOM

if(($mode eq 'log_in' or ($mode eq 'monster' and $battle_flag ne "1") or $mode eq 'rest')){
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

my $css_backgif = "";
$css_backgif = "background-image: url($backgif);" if ( $backgif ne "" );

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
<script>
master_sound = [
    {"id":1,"ファイル名":"NES-RPG-A02-2(Town1-Loop130).mp3","名称":"town1","ユニークid":"1","サウンド種別":"1"},
    {"id":2,"ファイル名":"NES-RPG-B10-2(Dungeon2-Loop170).mp3","名称":"dungeon1","ユニークid":"2","サウンド種別":"1"},
    {"id":3,"ファイル名":"GB-RPG-A12-2(Battle1-Loop157).mp3","名称":"battle1","ユニークid":"3","サウンド種別":"1"},
];
</script>
<script src="/js/so_town.js"></script>
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
<link href="https://fonts.googleapis.com/css2?family=Kosugi+Maru&display=swap" rel="stylesheet">
<link rel="stylesheet" href="/css/so_common.css" type="text/css" />
<link rel="stylesheet" href="/css/blackboard.css" type="text/css" />
<link rel="stylesheet" href="/css/third-party/jquery.jgrowl.css" type="text/css" />
</head>
<body>
EOM
}

1;
