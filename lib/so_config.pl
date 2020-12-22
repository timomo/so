use utf8;

#------------------#
#  buffデータ読込  #
#------------------#
sub read_buff
{
	my $buff = $system->load_buff_db($rid);

	if (! defined $buff->{id})
	{
		@buff = &load_ini($buff_file);

		$hit=0;@buff_new=();@rbuf=();
		foreach(@buff){
			my ($bid,$brsk,$batc,$bdef,$bspd) = split(/<>/);
			if($rid eq "$bid") {
				$rrsk = $brsk;
				$rbuf[0] = $batc / 100;
				$rbuf[1] = $bdef / 100;
				$rbuf[2] = $bspd / 100;
				$hit=1;
				last;
			}
		}

		if(!$hit){@rbuf = (1,1,1);}
	}
	else
	{
		our ($rrsk, @rbuf) = @$buff{@{$mojo->config->{キャラバフ}}};
	}
}

sub regist_buff
{
	my $buff = {};
	@$buff{@{$mojo->config->{キャラバフ}}} = ($krsk, @kbuf);
	$system->save_buff_db($kid, $buff);
}

#------------------#
#  buffデータ書込  #
#------------------#
sub _regist_buff {

	# ファイルロック
	if ($lockkey == 1) { &lock1; }
	elsif ($lockkey == 2) { &lock2; }
	elsif ($lockkey == 3) { &file'lock; }

	@buff = &load_ini($buff_file);

	$hit=0;@buff_new=();
	foreach(@buff){
		($bid,$brsk,$batc,$bdef,$bspd) = split(/<>/);
		if($kid eq "$bid") {
			$brsk = $krsk;
			if($buff_flg == 1){
				$batc = $kbuf[0];
				$bdef = $kbuf[1];
				$bspd = $kbuf[2];
			}

			my $mes = "$bid<>$brsk<>$batc<>$bdef<>$bspd<>\n";
			my $utf8 = Encode::encode_utf8($mes);

			unshift(@buff_new,$utf8);
			$hit=1;
		}else{
			push(@buff_new,"$_\n");
		}
	}

	if(!$hit){
		my $mes = "$kid<>$krsk<>$kbuf[0]<>$kbuf[1]<>$kbuf[2]<>\n";
		my $utf8 = Encode::encode_utf8($mes);

		unshift(@buff_new,$utf8);
	}

	open(OUT,">$buff_file");
	print OUT @buff_new;
	close(OUT);

	# ロック解除
	if ($lockkey == 3) { &file'unlock; }
	else { if(-e $lockfile) { unlink($lockfile); } }
}

1;
