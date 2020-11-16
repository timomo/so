use utf8;
#--------#
#  移動  #
#--------#

sub move
{
	our $marea = -1;
	our $mspot = -1;
	my $direction = $in{direction};
	my $town = &town_load;

	# warn Dump($town);

	# 場所: 0...街の中、1...郊外、2...フィールド、3...次の街へ、4...前の街へ

	if ($direction eq "explore") # 郊外探索
	{
		$kspot = 0;
		$kpst = 1;
	}
	elsif ($direction eq "town") # 街へ戻る
	{
		$kspot = 0;
		$kpst = 0;
	}
	elsif ($direction eq "field") # フィールド探索
	{
		$kspot = 1;
		$kpst = 0;
	}
	elsif ($direction eq "next") # 次の街へ
	{
		$kspot = 2;
		$kpst = 0;
	}
	elsif ($direction eq "previous") # 前の街へ
	{
		$kspot = 3;
		$kpst = 0;
	}
	elsif ($direction eq "forward") # 先へ進む
	{
		$kpst -= 1;

		my $rest;

		if ($kspot == 2)
		{
			$rest = $town->{next}->{距離};
		}
		elsif ($kspot == 3)
		{
			$rest = $town->{previous}->{距離};
		}
		elsif ($kspot == 1)
		{
			$rest = $town->{current}->{距離};
		}

		if ($rest == 0)
		{
			if ($kspot == 2)
			{
				$karea = $town->{next}->{id};
			}
			elsif ($kspot == 3)
			{
				$karea = $town->{previous}->{id};
			}
			elsif ($kspot == 1)
			{
				$karea = $town->{current}->{id};
			}
		}
	}
	elsif ($direction eq "backward") # 引き返す
	{
		$kpst += 1;

		my $rest;

		if ($kspot == 2)
		{
			$rest = $town->{next}->{距離};
		}
		elsif ($kspot == 3)
		{
			$rest = $town->{previous}->{距離};
		}
		elsif ($kspot == 1)
		{
			$rest = $town->{current}->{距離};
		}

		$rest -= $kspot;

		if ($rest == 0)
		{
			if ($kspot == 2)
			{
				$karea = $town->{next}->{id};
			}
			elsif ($kspot == 3)
			{
				$karea = $town->{previous}->{id};
			}
			elsif ($kspot == 1)
			{
				$karea = $town->{current}->{id};
			}
		}
	}

	&regist;
	&save_dat_append;
	&log_in;

	exit;
}

sub _move {
	$marea = -1;
	$mspot = -1;
	$movemsg = "";
	$get_msg = "";

	if(Scalar::Util::looks_like_number($in{area})) { $marea = int($in{area}) }
	if(Scalar::Util::looks_like_number($in{spot})) { $mspot = int($in{spot}) }

	&town_load;

	if ($marea == -1 || $mspot == -1)
	{
		$logger->error(sprintf("area=%d, spot=%d, pst=%d, m_area=%d, m_spot=%d", $karea, $kspot, $kpst, $marea, $mspot));

		# $kspot = 0;
		# $kpst = 0;

		# &event;
		# &log_in;
	}
	else
	{
		if ($karea == $marea && $kspot == 0) # 街周辺にいた場合
		{
			if($kpst == 0) #街にいた場合
			{
				$kspot = $mspot;
				$kpst = $town_move[$marea][$mspot];

				if($mspot == 0)
				{
					$get_area = $karea;$get_id="04";$get_cnt="0";
					&get_msg;
					$movemsg = "$kname は$town_name[$karea]郊外に移動しました。<p>$get_msg";
				}
				elsif($mspot == 1)
				{
					$get_area = $karea;$get_id="05";$get_cnt="0";
					&get_msg;
					$movemsg = "$kname は$area_name[$karea]に移動しました。<p>$get_msg";
				}
				elsif($mspot == 2)
				{
					$movemsg = "$kname は$town_name[$karea]を出発しました。";
				}

				if(int(rand(2)) == 0)
				{
					&event;
					$mode = "log_in";
					&log_in;
				}
			}
			elsif($kpst == 1) #郊外にいた場合
			{
				if($mspot == 0)
				{
					$get_area=$karea;$get_id="04";$get_cnt=int(rand(4)) + 1;
					&get_msg;
					$movemsg = "$town_name[$karea]郊外にいます。<p>$get_msg";
					if(int(rand(2)) == 0)
					{
						&event;
						$mode = "log_in";
						&log_in;
					}
				}
				elsif($mspot == 1)
				{
					$movemsg = "$town_name[$karea]に帰還しました。";
					$kpst = 0;
					&event;
					$mode = "log_in";
					&log_in;
				}
				elsif($mspot == 2)
				{
					&camp;
				}
			}
		}
		elsif ($karea == $marea && $kspot == 1) #ダンジョンにいた場合
		{
			#先に進む場合
			if($mspot == 0){
				$kpst -= 1;
				if($kpst < 1){
					$get_area=$karea;$get_id="06";$get_cnt="0";
					&get_msg;
					$movemsg = "$area_name[$karea]の最深部に到着しました。<p>$get_msg";
				} else {
					$get_area=$karea;$get_id="05";$get_cnt=$kpst;
					&get_msg;
					$movemsg = "$area_name[$karea]の奥に進んでいきます・・<p>$get_msg";
					if(int(rand(2)) == 0){
						&event;
						$mode = "log_in";
						&log_in;
					}
				}
				#引き返す場合
			} elsif($mspot == 1){
				$kpst += 1;
				if($kpst > $town_move[$karea][$kspot]){
					if(int(rand(2)) == 0){
						$movemsg = "$town_name[$karea]に到着しました。";
						$kspot = 0;
						$kpst = 0;
						&event;
						$mode = "log_in";
						&log_in;
					}
				} else {
					$movemsg = "$town_name[$karea]に引き返しています・・<p>$get_msg";
					if(int(rand(2)) == 0){
						&event;
						$mode = "log_in";
						&log_in;
					}
				}
			} elsif($mspot == 2){
				&camp;
			}
		}
		elsif ($karea == $marea && $kspot == 2) #次の街の道中の場合
		{
			#先に進む場合
			if($mspot == 0){
				$kpst -= 1;
				if($kpst < 1){
					if(int(rand(2)) == 0){
						$get_area=$farea;$get_id="01";$get_cnt="0";
						&get_msg;
						$movemsg = "$town_name[$farea]に到着しました。<p>$get_msg";
						$karea = $farea;
						$kspot = 0;
						$kpst = 0;
						&event;
						$mode = "log_in";
						&log_in;
					}
				} else {
					$movemsg = "$town_name[$farea]に向かって歩いています・・";
					if(int(rand(2)) == 0){
						&event;
						$mode = "log_in";
						&log_in;
					}
				}
				#引き返す場合
			} elsif($mspot == 1){
				$kpst += 1;
				if($kpst > $town_move[$karea][$kspot]){
					if(int(rand(2)) == 0){
						$movemsg = "$town_name[$karea]に到着しました。";
						$kspot = 0;
						$kpst = 0;
						&event;
						$mode = "log_in";
						&log_in;
					}
				} else {
					$movemsg = "$town_name[$karea]に引き返しています・・";
					if(int(rand(2)) == 0){
						&event;
						$mode = "log_in";
						&log_in;
					}
				}
			} elsif($mspot == 2){
				&camp;
			}
		}
		elsif ($karea == $marea && $kspot == 3) #前の街の道中の場合
		{
			#先に進む場合
			if($mspot == 0){
				$kpst -= 1;
				if($kpst < 1){
					if(int(rand(2)) == 0){
						$get_area=$rarea;$get_id="01";$get_cnt="0";
						&get_msg;
						$movemsg = "$town_name[$rarea]に到着しました。<p>$get_msg";
						$karea = $rarea;
						$kspot = 0;
						$kpst = 0;
						&event;
						$mode = "log_in";
						&log_in;
					}
				} else {
					$movemsg = "$town_name[$rarea]に向かって歩いています・・";
					if(int(rand(2)) == 0){
						&event;
						$mode = "log_in";
						&log_in;
					}
				}
				#引き返す場合
			} elsif($mspot == 1){
				$kpst += 1;
				if($kpst > $town_move[$karea][$kspot]){
					if(int(rand(2)) == 0){
						$movemsg = "$town_name[$karea]に到着しました。";
						$kspot = 0;
						$kpst = 0;
						&event;
						$mode = "log_in";
						&log_in;
					}
				} else {
					$movemsg = "$town_name[$karea]に引き返しています・・";
					if(int(rand(2)) == 0){
						&event;
						$mode = "log_in";
						&log_in;
					}
				}
			} elsif($mspot == 2){
				&camp;
			}
		}
	}
}

1;
