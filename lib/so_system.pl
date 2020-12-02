use utf8;

sub save_dat_append_1p
{
	my $param = {};
	if (! defined $k1id)
	{
		return;
	}
	@$param{@{$config->{keys2}}} = ($k1id, $mode, $k1area, $k1spot, $k1pst, time, 1);
	$system->modify_append_data($param);
	$system->save_append($param);
}

sub save_dat_append_2p
{
	my $param = {};
	if (! defined $k2id)
	{
		return;
	}
	@$param{@{$config->{keys2}}} = ($k2id, $mode, $k2area, $k2spot, $k2pst, time, 1);
	$system->modify_append_data($param);
	$system->save_append($param);
}

sub save_dat_append
{
	my $param = {};
	if (! defined $kid)
	{
		return;
	}
	@$param{@{$config->{keys2}}} = ($kid, $mode, $karea, $kspot, $kpst, time, $kstage);
	$system->modify_append_data($param);
	$system->save_append($param);
}

sub load_ini
{
	my $path = shift;
	my @ret;

	open(IN, "<", $path);

	my @tmp = <IN>;

	for (@tmp)
	{
		$_ =~ s/(?:\r\n|\r|\n)$//g;
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
	my $buffer;

	if ($ENV{'REQUEST_METHOD'} eq "POST") {
		if ($ENV{'CONTENT_LENGTH'} > 51200) { &error("投稿量が大きすぎます。"); }
		read(STDIN, $buffer, $ENV{'CONTENT_LENGTH'});
	}

	my $params = Mojo::Parameters->new($buffer);
	my $query = $ENV{'QUERY_STRING'};

	$params = $params->merge( Mojo::Parameters->new($query) );
	%in = %{$params->to_hash};
	$mode = $in{'mode'};
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
	my $error = shift;
	my $html = $controller->render_to_string(template => "exception", confirmation => $error);
	print Encode::encode_utf8($html);
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

sub initialize
{
	our $mode = undef;
	our $error = undef;
	our $movemsg = undef;
	our %in = undef;
	our $battle_flag = undef;
	our $spot = undef;
	our $msg = undef;

	# player
	our $kid = undef; our $kpass = undef; our $kname = undef; our $ksex = undef; our $kchara = undef;
	our $kn_0 = undef; our $kn_1 = undef; our $kn_2 = undef; our $kn_3 = undef; our $kn_4 = undef; our $kn_5 = undef; our $kn_6 = undef;
	our $khp = undef; our $kmaxhp = undef; our $kex = undef; our $klv = undef; our $kap = undef;our $kgold = undef; our $klp = undef;
	our $ktotal = undef; our $kkati = undef; our $host = undef; our $date = undef;
	our $karea = undef; our $kspot = undef; our $kpst = undef; our $kstage = undef;
	our $kitem = undef;
	our @kbuff = undef;
	our $khost = undef;
	our $kdate = undef;

	# PVP戦
	our $k1id = undef; our $k1pass = undef; our $k1name = undef; our $k1sex = undef; our $k1chara = undef;
	our $k1n_0 = undef; our $k1n_1 = undef; our $k1n_2 = undef; our $k1n_3 = undef; our $k1n_4 = undef; our $k1n_5 = undef; our $k1n_6 = undef;
	our $k1hp = undef; our $k1maxhp = undef; our $k1ex = undef; our $k1lv = undef; our $k1ap = undef;our $k1gold = undef; our $k1lp = undef;
	our $k1total = undef; our $k1kati = undef; our $k1host = undef; our $k1date = undef;
	our $k1area = undef; our $k1spot = undef; our $k1pst = undef;
	our $k1item = undef;
	our @k1buff = undef;
	our $k2id = undef; our $k2pass = undef; our $k2name = undef; our $k2sex = undef; our $k2chara = undef;
	our $k2n_0 = undef; our $k2n_1 = undef; our $k2n_2 = undef; our $k2n_3 = undef; our $k2n_4 = undef; our $k2n_5 = undef; our $k2n_6 = undef;
	our $k2hp = undef; our $k2maxhp = undef; our $k2ex = undef; our $k2lv = undef; our $k2ap = undef; our $k2gold = undef; our $k2lp = undef;
	our $k2total = undef; our $k2kati = undef; our $k2host = undef; our $k2date = undef;
	our $k2area = undef; our $k2spot = undef; our $k2pst = undef;
	our $k2item = undef;
	our @k2buff = undef;
	our $k1hp_flg = undef; our $k1d_flg = undef;
	our $k2hp_flg = undef; our $k2d_flg = undef;
	our $comment = undef; our $award1 = undef; our $award2 = undef;
	our $win1 = undef; our $win2 = undef;

	# モンスター戦
	our $mno = undef; our $mname = undef; our $mlv = undef; our $mex = undef; our $mgold = undef;
	our $mhp = undef; our $msp = undef; our $mdmg = undef; our $mdef = undef; our $mspd = undef; our $mtec = undef;
	our $melm = undef; our $mdrop = undef; our $mtype = undef; our @mbuff = undef;
	our $wrsk = undef;

	our $i = undef; our $j = undef;
	our $win = undef;
	our @battle_date = undef; our @battle_header = undef; our @battle_fotter = undef;
	our $turn = undef;
	our $khp_flg = undef; our $kd_flg = undef;
	our $mhp_flg = undef; our $md_flg = undef;
}

1;
