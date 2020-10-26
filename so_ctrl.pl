#!/usr/bin/perl

use File::Spec;
use FindBin;
use lib File::Spec->catdir($FindBin::RealBin, 'lib');
use CGI;
use DBM::Deep;
use Data::Dumper;

# 初期設定ファイルの読み込み
require './so_system.dat';

my $query = new CGI();
my $logdir = File::Spec->catdir( $FindBin::Bin, $log_path );
my (
	@logs, @access_log, %in, @MESSAGE, %chara,
	@logsHTML, @charHTML, @errHTML, @moveHTML
);
# logdirの読み込み
{
	opendir(DH, $logdir);
	@logs = reverse sort grep /\.log$/, readdir(DH);
	closedir(DH);
	@logsHTML = map { sprintf( "<option value=\"%s\">%s</option>\n", $_, $_ ) } @logs;
}
###

# char load start
{
	open(IN,"$chara_file");
	@MESSAGE = <IN>;
	close(IN);

	foreach(@MESSAGE) {
		my ($did,$dpass,$dname,$dsex,$dchara,$dn_0,$dn_1,$dn_2,$dn_3,$dn_4,$dn_5,$dn_6,$dhp,$dmaxhp,$dex,$dlv,$dap,$dgold,$dlp,$dtotal,$dkati,$dhost,$ddate,$darea,$dspot,$dpst,$ditem) = split(/<>/);
		push @charHTML, "<option value=\"$did\">$dname Lv$dlv（$town_name[$darea]）</option>\n";
	}
}
# char load end

%in = (
	'log' => $query->param('log'),
	'id'  => $query->param('id'),
);

if ( ! -f $chara_db ) {
	push( @errHTML, "キャラデータのDBがありません。\n" );
} else {
	# noop
}

if ( $query->param('mode') eq 'log_view' ) {
	log_view();
	exit;
} elsif ( $query->param('mode') eq 'status_view' ) {
	status_view();
	exit;
} elsif ( $query->param('mode') eq 'convert_db' ) {
	convert_db();
	exit;
}

	print <<"EOM";
Content-type:text/html

<html>
<head>
<meta name="viewport" content="width=320, initial-scale=1.0, maximum-scale=1.0, user-scalable=no /">
<meta http-equiv="Content-type" content="text/html; charset=UTF-8" />
<link rel="stylesheet" href="so_common.css" type="text/css" />
<script src="http://www.google.com/jsapi"></script>
<script type="text/javascript">google.load("jquery", "1.4.3");</script>
<title>Kanshi</title>
</head>
<body>
<script type="text/javascript">
jQuery(document).ready(function() {
	jQuery("#select_log").val('$in{log}');
	jQuery("#select_id").val('$in{id}');
	jQuery("#btn_wochi").click(function() {
		jQuery("#log_view").load( "so_ctrl.cgi", { log: jQuery("#select_log").val(), id: jQuery("#select_id").val(), mode: "log_view" });
	});
	jQuery("#btn_status").click(function() {
		jQuery("#status_view").load( "so_ctrl.cgi", { id: jQuery("#select_id").val(), mode: "status_view" });
	});
	jQuery("#btn_convert").click(function() {
		jQuery("#status_view").load( "so_ctrl.cgi", { mode: "convert_db" });
	});
});
</script>
<style type="text/css">
.warn {
	color: red;
	font-weight: bold;
}
</style>
<pre class="warn">
@errHTML
</pre>
<form action="so_ctrl.cgi" method="post">
<b>行者監視システム</b>
<p>
<select id="select_log" name="log">
<option value="">ログファイル選択</option>
@logsHTML
</select>
<select id="select_id" name="id">
<option value="">監視対象選択</option>
@charHTML
</select>
<br />
<button id="btn_status" type="button">status</button>
<button id="btn_wochi" type="button">check</button>
<button id="btn_convert" type="button">convert</button>
</form>
<div id="status_view"></div>
<div id="log_view"></div>
</body>
</html>
EOM

sub status_view {
	tie %chara, 'DBM::Deep', $chara_db;
	my $c = $chara{ $query->param('id') };
	my $HTML = "";
	$HTML = Dumper $c;
	print <<EOM;
Content-type:text/html

<pre>
$HTML
</pre>
EOM
}

sub log_view {
	my @errHTML;
	my $HTML = "";
	if ( $query->param('log') eq "" ) {
		push( @errHTML, "ログファイルが選択されていません。" );
	}
	if ( $query->param('id') eq "" ) {
		push( @errHTML, "監視対象が選択されていません。" );
	}
	my $log_filename = $in{'log'} ne '' ? $in{'log'} : $logs[0];
	if ( -f File::Spec->catfile( $logdir, $log_filename ) ) {
		open(IN, '<', File::Spec->catfile( $logdir, $log_filename ) );
		@access_log = <IN>;
		close(IN);
	} else {
		push( @errHTML, "ログファイルがありません。\n" );
	}
	if ( @errHTML + 0 > 0 ) {
		$HTML = sprintf("<ul class=\"warn\"><li>%s</li></ul>", ( join "</li><li>", @errHTML ) );
	} else {
		$HTML .= "<table border=1><thead><tr><th class=b1>time</th><th class=b1>host</th><th class=b1>action</th></tr></thead><tbody>";
		foreach(@access_log){
			my ($time,$host,$user,$move) = split(/<>/);
			if($in{'id'} eq "$user"){
				$time = (split /\s/, $time)[1];
				$HTML .= "<tr><td>$time</td><td>$host</td><td>$move</td></tr>";
			}
		}
		$HTML .= "</tbody></table>";
	}

	print <<EOM;
Content-type:text/html

$HTML
EOM
}

sub convert_db {
	tie %chara, 'DBM::Deep', $chara_db;
	for my $line (@MESSAGE) {
		$line =~ s/\r\n|\r|\n$//;
		my @ary = split /<>/, $line;
		$chara{ $ary[0] } = \@ary;
	}
	my $cnt = keys %chara;
	print <<EOM;
Content-type:text/html

$cnt 件コンバート完了しました。
EOM
}
