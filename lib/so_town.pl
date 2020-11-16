use utf8;
#----------------------#
#  街データをロード    #
#----------------------#
sub town_load
{
	my @log_town = &load_ini($town_info);
	my $ret = {};

	$ret->{move} = \@town_move;

	foreach(@log_town)
	{
		my ($t_no,$t_info,$t_shop,$t_inn,$t_cost,$t_prize,$t_drop) = split(/<>/);
		if($karea eq "$t_no")
		{
			my $tmp = {};
			$tmp->{id} = $t_no * 1;
			$tmp->{info} = $t_info;
			$tmp->{shop} = $t_shop;
			$tmp->{inn} = $t_inn;
			$tmp->{cost} = $t_cost * 1;
			$tmp->{price} = $t_prize * 1;
			$tmp->{drop} = $t_drop;
			$tmp->{距離} = $ret->{move}->[$karea]->[3];

			if ($kspot == 1)
			{
				$tmp->{距離} -= $kpst;
			}
			else
			{
				$tmp->{距離} += $kpst;
			}

			$tmp->{地名} = $town_name[$tmp->{id}];
			$tmp->{場所} = $area_name[$tmp->{id}];
			$ret->{current} = $tmp;
			last;
		}
	}

	my $farea = 0;

	if($karea > 0)
	{
		$farea = $karea - 1;
	}
	else
	{
		$farea = @town_name - 1;
	}

	foreach(@log_town)
	{
		my ($f_no,$f_info,$f_shop,$f_inn) = split(/<>/);
		if($farea eq "$f_no")
		{
			my $tmp = {};
			$tmp->{id} = $f_no * 1;
			$tmp->{info} = $f_info;
			$tmp->{shop} = $f_shop;
			$tmp->{inn} = $f_inn;
			$tmp->{距離} = $ret->{move}->[$karea]->[2];

			if ($kspot == 2)
			{
				$tmp->{距離} -= $kpst;
			}
			else
			{
				$tmp->{距離} += $kpst;
			}
			$tmp->{地名} = $town_name[$tmp->{id}];
			$tmp->{場所} = $area_name[$tmp->{id}];
			$ret->{next} = $tmp;
			last;
		}
	}

	my $rarea = @town_name - 1;

	if($karea < (@town_name - 1))
	{
		$rarea = $karea + 1;
	}
	else
	{
		$rarea = 0;
	}

	foreach(@log_town)
	{
		my ($r_no,$r_info,$r_shop,$r_inn) = split(/<>/);
		if($rarea eq "$r_no")
		{
			my $tmp = {};
			$tmp->{id} = $r_no * 1;
			$tmp->{info} = $r_info;
			$tmp->{shop} = $r_shop;
			$tmp->{inn} = $r_inn;
			$tmp->{距離} = $ret->{move}->[$karea]->[1];

			if ($kspot == 3)
			{
				$tmp->{距離} -= $kpst;
			}
			else
			{
				$tmp->{距離} += $kpst;
			}
			$tmp->{地名} = $town_name[$tmp->{id}];
			$tmp->{場所} = $area_name[$tmp->{id}];
			$ret->{previous} = $tmp;
			last;
		}
	}

	# warn sprintf("%s = %s, %s", $_, $ret->{$_}->{地名}, $ret->{$_}->{距離}) for (qw|previous next current|);

	delete $ret->{move};

	return $ret;
}

#------------------#
#  メッセージ表示  #
#------------------#
sub get_msg
{
	@townmsg = &load_ini($town_msg[$get_area]);

	foreach(@townmsg){
		($m_id,$m_cnt,$m_msg) = split(/<>/);
		if($m_id eq "$get_id" && $m_cnt eq "$get_cnt" ) {
			$get_msg = "<i>$m_msg</i>";
		}
	}
}

1;
