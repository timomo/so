use utf8;

sub load_ini
{
	my $path = shift;
	my @ret;

	open(IN, "<", $path);
	while(<IN>)
	{
		my $str = Encode::decode_utf8($_);
		push(@ret, $str);
	}
	close(IN);

	return @ret;
}

#----------------#
#  デコード処理  #
#----------------#
sub decode {
	if ($ENV{'REQUEST_METHOD'} eq "POST") {
		if ($ENV{'CONTENT_LENGTH'} > 51200) { &error("投稿量が大きすぎます。"); }
		read(STDIN, $buffer, $ENV{'CONTENT_LENGTH'});
	} else { $buffer = $ENV{'QUERY_STRING'}; }
	my @pairs = split(/&/, $buffer);

	%in = ();

	foreach (@pairs) {
		my ($name, $value) = split(/=/, $_);
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

#----------------#
#  ホスト名取得  #
#----------------#
sub get_host {
	$host = $ENV{'REMOTE_HOST'};
	$addr = $ENV{'REMOTE_ADDR'};

	if ($get_remotehost) {
		if ($host eq "" || $host eq "$addr") {
			$host = gethostbyaddr(pack("C4", split(/\./, $addr)), 2);
		}
	}
	if ($host eq "") { $host = $addr; }
}

#--------------#
#  エラー処理  #
#--------------#
sub error {
	# ロック解除
	if ($lockkey == 3) { &file'unlock; }
	else { if(-e $lockfile) { unlink($lockfile); } }
	$battle_flag=0;

	&header;
	print "<center><hr width=400><h3>ERROR !</h3>\n";
	print "<P><font color=red><B>$_[0]</B></font>\n";
	print "<P><hr width=400>\n";
	print "<a href=\"$script\">TOPへ</a></center>\n";
	print "</body></html>\n";
	exit;
}

#-------------------------------#
#  ロックファイル：symlink関数  #
#-------------------------------#
sub lock1 {
	local($retry) = 5;
	while (!symlink(".", $lockfile)) {
		if (--$retry <= 0) { &error("LOCK is BUSY"); }
		sleep(1);
	}
}

#----------------------------#
#  ロックファイル：open関数  #
#----------------------------#
sub lock2 {
	local($retry) = 0;
	foreach (1 .. 5) {
		if (-e $lockfile) { sleep(1); }
		else {
			open(LOCK,">$lockfile") || &error("Can't Lock");
			close(LOCK);
			$retry = 1;
			last;
		}
	}
	if (!$retry) { &error("しばらくお待ちになってください。"); }
}

#------------------#
#  クッキーの発行  #
#------------------#
sub set_cookie {
	# クッキーは60日間有効
	local($sec,$min,$hour,$mday,$mon,$year,$wday) = gmtime(time+60*24*60*60);

	@month=('Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec');
	$gmt = sprintf("%s, %02d-%s-%04d %02d:%02d:%02d GMT",
			$week[$wday],$mday,$month[$mon],$year+1900,$hour,$min,$sec);
	$cook="id<>$cookie_id\,pass<>$cookie_pass";
	print "Set-Cookie: FFADV=$cook; expires=$gmt\n";
}

#------------------#
#  クッキーを取得  #
#------------------#
sub get_cookie {
	@pairs = split(/;/, $ENV{'HTTP_COOKIE'});
	foreach (@pairs) {
		local($key,$val) = split(/=/);
		$key =~ s/\s//g;
		$GET{$key} = $val;
	}
	@pairs = split(/,/, $GET{'FFADV'});
	foreach (@pairs) {
		local($key,$val) = split(/<>/);
		$COOK{$key} = $val;
	}
	$c_id  = $COOK{'id'};
	$c_pass = $COOK{'pass'};
}

#--------------#
#  時間を取得  #
#--------------#
sub get_time {
	$ENV{'TZ'} = "JST-9";
	($sec,$min,$hour,$mday,$mon,$year,$wday) = localtime(time);
	@week = ('Sun','Mon','Tue','Wed','Thu','Fri','Sat');

	# 日時のフォーマット
	$gettime = sprintf("%04d/%02d/%02d %02d:%02d",
			$year+1900,$mon+1,$mday,$hour,$min);
}

#ファイルのロック
sub file'lock
{
	$file'lockflag = 0;
	$file'lockfile = $lockfile;		#本来のロックファイルの名前
	$file'lock_sw0 = $lockfile . ".sw0";	#最新日時のロックファイル作成用
	$file'lock_sw1 = $lockfile . ".sw1";	#ロックされている状態の名前

	(-l $lockfile) && &file'error(0);
	(-d $lockfile) && &file'error(0);

	#ロックファイルを置くサーバーの現在時刻を取得(timeではだめ)
	$locktemp = $lockfile . ".$$";
	open(LOCK, ">$locktemp") || return (0);	close(LOCK);
	$time = (stat($locktemp))[9];
	unlink($locktemp);

	#作成されてから$lock_limit秒以上経過しているロックファイルの名前を戻す
	if ((-f $file'lock_sw1) && ($time - (stat($file'lock_sw1))[9] > $lock_limit)) {
		rename($file'lock_sw1, $file'lockfile) || return (0);
	}

	#ロックファイルの作成日時更新
	open(LOCK, ">$file'lock_sw0") || &file'error(2);
	close(LOCK);
	rename($file'lock_sw0, $file'lockfile) || return (0);

	(-f $file'lock_sw1) && return (0);

	#ロック権の取得
	while (($file'lockflag = rename($file'lockfile, $file'lock_sw1)) == 0 && $lock_try) {
		#0.03, [0.07, 0.13, 0.17], 0.23
		select(undef, undef, undef, 0.13);
		$lock_try--;
	}
	$file'lockflag;
}

#ファイルのアンロック
sub file'unlock
{
	if ($file'lockflag) {
		rename($file'lock_sw1, $file'lockfile);

		#0.03, [0.07, 0.13, 0.17], 0.23
		select(undef, undef, undef, 0.03);
	}
}

sub file'error
{
	local(@error) = (
		"ロックシンボルの作成を中止しました。<br>\n(ロックシンボル以外で同名称が存在)<br>\n",
		"ロックシンボルの作成に失敗しました。<br>\n",
		"ロックシンボルの更新に失敗しました。<br>\n",
		"ロックシンボルの削除に失敗しました。<br>\n",
		$_[1],
	);

	select(STDOUT);	$| = 1;
	print "$error[$_[0]]\n";
	exit;
}

1;
