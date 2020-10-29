use utf8;
#----------------------#
#  街データをロード    #
#----------------------#
sub town_load {

	@log_town = &load_ini($town_info);

	foreach(@log_town){
		($t_no,$t_info,$t_shop,$t_inn,$t_cost,$t_prize,$t_drop) = split(/<>/);
		if($karea eq "$t_no"){ last; }
	}

	$farea = 0;
	if($karea > 0) {
		$farea = $karea - 1;
	} else {
		$farea = @town_name - 1;
	}

	@log_town = &load_ini($town_info);

	foreach(@log_town){
		($f_no,$f_info,$f_shop,$f_inn) = split(/<>/);
		if($farea eq "$f_no"){ last; }
	}

	$rarea = @town_name - 1;
	if($karea < (@town_name - 1)) {
		$rarea = $karea + 1;
	} else {
		$rarea = 0;
	}

	@log_town = &load_ini($town_info);

	foreach(@log_town){
		($r_no,$r_info,$r_shop,$r_inn) = split(/<>/);
		if($rarea eq "$r_no"){ last; }
	}
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
